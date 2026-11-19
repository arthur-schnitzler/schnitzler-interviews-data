#!/usr/bin/env python3
"""
Überprüft alle PMB-Nummern in TEI/XML-Dateien auf Aktualität und schreibt
veraltete Nummern (z. B. nach einem Merge in der PMB) auf die aktuelle um.

Projektunabhängig: läuft in jedem Repository, das PMB-Entitäten als
"pmb123", "#pmb123" oder https://pmb.acdh.oeaw.ac.at/entity/123/ in
Attributen referenziert. Benötigt nur die Python-Standardbibliothek.

Ermittlung der aktuellen Nummer
-------------------------------
* export (Standard): Die täglich erzeugten TEI-Exporte der PMB
  (https://pmb.acdh.oeaw.ac.at/media/list{person,place,org,bibl,event}.xml,
  zusammen ca. 210 MB) werden geladen. Jede Entität führt neben ihrer eigenen
  Nummer die Nummern der in sie gemergten Einträge als
  <idno subtype="pmb">. Daraus ergibt sich alt -> neu. Nummern, die im
  Export gar nicht vorkommen, werden einzeln online nachgeprüft (der Export
  kann bis zu einem Tag alt sein).
* online (--source online): Für jede Nummer N wird
  https://pmb.acdh.oeaw.ac.at/entity/N/ abgefragt; die PMB leitet auf die
  aktuelle Nummer weiter. Genau, aber langsam (ca. 1 Minute je 3000 Nummern).

Was umgeschrieben wird
----------------------
* In den Attributen ref, corresp, sameAs, target, source, who, key, xml:id
  (änderbar mit --attrs) alle Token der Form
    pmb123, #pmb123, pmbperson__123 (wird zu pmb123 vereinheitlicht,
    außer mit --keep-prefix)
    https://pmb.acdh.oeaw.ac.at/entity/123/
  auch mehrere pro Attribut (durch Leerzeichen getrennt); doppelte Token
  werden danach entfernt.
* Nicht angetastet: Textinhalte (z. B. <idno>-URLs zu anderen Projekten),
  Attribute ohne "pmb"-Präfix (z. B. key="123") und Elemente aus
  --exclude-element (Standard: occupation – deren Refs zeigen auf
  PMB-Vokabulare mit eigenem Nummernkreis).
* Gibt es in einer Datei sowohl ein Element mit @xml:id="pmbALT" als auch eines
  mit @xml:id="pmbNEU", wird das Element mit der alten Nummer entfernt
  (Dublette nach Merge). Sonst wird nur die @xml:id umbenannt.

Die Dateien werden textbasiert bearbeitet, die Formatierung bleibt erhalten.

Aufruf
------
    python pmb_nummern_aktualisieren.py --dry-run          # nur berichten
    python pmb_nummern_aktualisieren.py                    # umschreiben (./data oder .)
    python pmb_nummern_aktualisieren.py editions indices   # bestimmte Ordner/Dateien
    python pmb_nummern_aktualisieren.py --export-dir pmb-export   # Export behalten/wiederverwenden
    python pmb_nummern_aktualisieren.py --source online --report alt-neu.csv

Exit-Codes: 0 = ok, 1 = PMB nicht erreichbar für einzelne Nummern,
2 = nicht gefundene Nummern (nur mit --fail-on-missing).

In GitHub Actions wird automatisch eine Zusammenfassung in
$GITHUB_STEP_SUMMARY geschrieben sowie die Outputs outdated, changed_files
und missing in $GITHUB_OUTPUT gesetzt.
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import re
import shutil
import sys
import tempfile
import time
import xml.etree.ElementTree as ET
import urllib.error
import urllib.request
from collections import Counter, defaultdict
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

PMB_ENTITY_URL = "https://pmb.acdh.oeaw.ac.at/entity/{}/"
LOCATION_RE = re.compile(r"/entity/(?:[a-z]+/)?(\d+)/")

DEFAULT_ATTRS = ("ref", "corresp", "sameAs", "target", "source", "who", "key", "xml:id")
DEFAULT_EXCLUDED = ("occupation",)
SKIP_DIRS = {".git", "node_modules", ".venv", "venv", "__pycache__"}

START_TAG_RE = re.compile(
    r"<([\w.-]+(?::[\w.-]+)?)((?:\s+[\w:.-]+\s*=\s*(?:\"[^\"]*\"|'[^']*'))*)(\s*/?>)"
)
# pmb123, #pmb123, pmbperson__123 als eigenständiges Token (nicht Teil einer URL)
TOKEN_RE = re.compile(r"(?<![\w/.#-])(#?pmb(?:[a-z]+__)?)(\d+)(?![\w.])")
# https://pmb.acdh.oeaw.ac.at/entity/123/
URL_RE = re.compile(r"(https?://pmb\.acdh\.oeaw\.ac\.at/entity/)(\d+)(?!\d)")
XMLID_RE = re.compile(r"\sxml:id\s*=\s*[\"']pmb(\d+)[\"']")
IDNO_PMB_RE = re.compile(r"entity/(\d+)")
NORMALIZED = "_vereinheitlicht"  # Zählerschlüssel für pmbperson__123 -> pmb123


# --------------------------------------------------------------------------
# Dateien und Attribute
# --------------------------------------------------------------------------

def xml_files(paths: list[Path]) -> list[Path]:
    files: set[Path] = set()
    for p in paths:
        if p.is_file():
            files.add(p)
            continue
        for root, dirs, names in os.walk(p):
            dirs[:] = [d for d in dirs if d not in SKIP_DIRS and not d.startswith(".")]
            files.update(Path(root) / n for n in names if n.endswith(".xml"))
    return sorted(files)


class Scanner:
    def __init__(self, attrs: list[str], excluded: list[str]):
        self.excluded = set(excluded)
        self.attr_re = re.compile(
            r"(\s(?:" + "|".join(re.escape(a) for a in attrs) + r")\s*=\s*)([\"'])(.*?)\2",
            re.DOTALL,
        )

    def _skip(self, tag: re.Match) -> bool:
        return tag.group(1).split(":")[-1] in self.excluded

    def numbers(self, text: str):
        for tag in START_TAG_RE.finditer(text):
            if self._skip(tag):
                continue
            for attr in self.attr_re.finditer(tag.group(2)):
                value = attr.group(3)
                for m in TOKEN_RE.finditer(value):
                    yield m.group(2)
                for m in URL_RE.finditer(value):
                    yield m.group(2)

    def rewrite(self, text: str, mapping: dict[str, str], normalize: bool, counter: Counter) -> str:
        def repl_token(m: re.Match) -> str:
            prefix, num = m.group(1), m.group(2)
            new_prefix = ("#pmb" if prefix.startswith("#") else "pmb") if normalize else prefix
            if new_prefix != prefix:
                counter[NORMALIZED] += 1
            new_num = mapping.get(num, num)
            if new_num != num:
                counter[(num, new_num)] += 1
            return f"{new_prefix}{new_num}"

        def repl_url(m: re.Match) -> str:
            num = m.group(2)
            if num in mapping:
                counter[(num, mapping[num])] += 1
                return f"{m.group(1)}{mapping[num]}"
            return m.group(0)

        def repl_value(value: str) -> str:
            new = URL_RE.sub(repl_url, TOKEN_RE.sub(repl_token, value))
            if new != value and " " in new.strip():
                new = " ".join(dict.fromkeys(new.split()))  # Dubletten entfernen
            return new

        def repl_attr(m: re.Match) -> str:
            return f"{m.group(1)}{m.group(2)}{repl_value(m.group(3))}{m.group(2)}"

        def repl_tag(tag: re.Match) -> str:
            if self._skip(tag):
                return tag.group(0)
            return f"<{tag.group(1)}{self.attr_re.sub(repl_attr, tag.group(2))}{tag.group(3)}"

        return START_TAG_RE.sub(repl_tag, text)


# --------------------------------------------------------------------------
# Aktuelle Nummern ermitteln
# --------------------------------------------------------------------------

EXPORT_URL = "https://pmb.acdh.oeaw.ac.at/media/{}.xml"
EXPORT_FILES = ("listperson", "listplace", "listorg", "listbibl", "listevent")
TEI_NS = "{http://www.tei-c.org/ns/1.0}"
XML_ID = "{http://www.w3.org/XML/1998/namespace}id"
LIST_ELEMENTS = {"listPerson", "listPlace", "listOrg", "listBibl", "listEvent"}
EXPORT_ID_RE = re.compile(r"(?:^|__|pmb)(\d+)$")


def download_exports(target: Path, refresh: bool) -> list[Path]:
    target.mkdir(parents=True, exist_ok=True)
    files = []
    for name in EXPORT_FILES:
        dest = target / f"{name}.xml"
        if refresh or not dest.exists():
            print(f"Lade {EXPORT_URL.format(name)} …", flush=True)
            for attempt in range(4):
                try:
                    req = urllib.request.Request(
                        EXPORT_URL.format(name), headers={"User-Agent": "pmb-id-check/1.0"})
                    with urllib.request.urlopen(req, timeout=300) as resp, \
                            open(dest.with_suffix(".part"), "wb") as fh:
                        shutil.copyfileobj(resp, fh, 1 << 20)
                    dest.with_suffix(".part").replace(dest)
                    break
                except (urllib.error.URLError, TimeoutError, OSError) as e:
                    if attempt == 3:
                        raise SystemExit(f"Download fehlgeschlagen: {EXPORT_URL.format(name)}: {e}")
                    time.sleep(5 * 2 ** attempt)
        files.append(dest)
    return files


def export_mapping(files: list[Path]) -> tuple[set[str], dict[str, str]]:
    """Liest die PMB-Exporte: (aktuelle Nummern, alt -> neu)."""
    current: set[str] = set()
    merged: dict[str, str] = {}
    for f in files:
        stack: list[str] = []  # "list", "entity" oder "other"
        for event, el in ET.iterparse(f, events=("start", "end")):
            if event == "start":
                name = el.tag.rsplit("}", 1)[-1]
                if stack and stack[-1] == "list":
                    stack.append("entity")
                elif name in LIST_ELEMENTS and "entity" not in stack:
                    stack.append("list")
                else:
                    stack.append("other")
                continue
            if stack.pop() != "entity":
                continue
            m = EXPORT_ID_RE.search(el.get(XML_ID, ""))
            if m:
                cur = m.group(1)
                current.add(cur)
                for idno in el.findall(TEI_NS + "idno"):
                    if idno.get("subtype") == "pmb":
                        mm = IDNO_PMB_RE.search(idno.text or "")
                        if mm and mm.group(1) != cur:
                            merged[mm.group(1)] = cur
            el.clear()
    # eine aktuelle Nummer wird nie umgeschrieben (PMB-Unstimmigkeiten)
    return current, {k: v for k, v in merged.items() if k not in current}


class _NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, *args, **kwargs):
        return None


_OPENER = urllib.request.build_opener(_NoRedirect)


def resolve_online(number: str, retries: int = 4) -> tuple[str, str | None]:
    """(status, aktuelle Nummer); status: ok | missing | error."""
    req = urllib.request.Request(
        PMB_ENTITY_URL.format(number), method="HEAD", headers={"User-Agent": "pmb-id-check/1.0"}
    )
    for attempt in range(retries):
        try:
            resp = _OPENER.open(req, timeout=30)
            code, location = resp.status, resp.headers.get("Location", "")
        except urllib.error.HTTPError as e:
            code = e.code
            location = e.headers.get("Location", "") if e.headers else ""
        except (urllib.error.URLError, TimeoutError, OSError):
            time.sleep(2 ** attempt)
            continue
        if code in (301, 302, 303, 307, 308):
            m = LOCATION_RE.search(location)
            return ("ok", m.group(1)) if m else ("error", None)
        if code == 404:
            return "missing", None
        if code == 200:
            return "ok", number
        if code >= 500 or code == 429:
            time.sleep(2 ** attempt)
            continue
        return "error", None
    return "error", None


def online_mapping(numbers: set[str], workers: int):
    """Fragt jede Nummer einzeln ab: (alt -> neu, nicht gefunden, Fehler)."""
    todo = sorted(numbers, key=int)
    print(f"Prüfe {len(todo)} Nummern online …", flush=True)
    mapping: dict[str, str] = {}
    missing: list[str] = []
    errors: list[str] = []
    with ThreadPoolExecutor(max_workers=workers) as pool:
        futures = {pool.submit(resolve_online, n): n for n in todo}
        for done, fut in enumerate(as_completed(futures), 1):
            n = futures[fut]
            status, current = fut.result()
            if status == "error":
                errors.append(n)
            elif status == "missing":
                missing.append(n)
            elif current != n:
                mapping[n] = current
            if done % 500 == 0:
                print(f"  … {done}/{len(todo)}", flush=True)
    return mapping, sorted(missing, key=int), sorted(errors, key=int)


def resolve_chains(mapping: dict[str, str]) -> dict[str, str]:
    """A -> B, B -> C  ==>  A -> C."""
    resolved = {}
    for old, new in mapping.items():
        seen = {old}
        while new in mapping and new not in seen:
            seen.add(new)
            new = mapping[new]
        if new != old:
            resolved[old] = new
    return resolved


# --------------------------------------------------------------------------
# Dubletten entfernen
# --------------------------------------------------------------------------

def find_element_span(text: str, start: int) -> tuple[int, int] | None:
    """Span des Elements, dessen Start-Tag bei `start` ('<') beginnt."""
    m = re.compile(r"<([\w:.-]+)\b[^>]*?(/?)>", re.DOTALL).match(text, start)
    if not m:
        return None
    name, end = m.group(1), m.end()
    if m.group(2) != "/":
        tag_re = re.compile(r"<(/?)" + re.escape(name) + r"\b[^>]*?(/?)>", re.DOTALL)
        depth = 1
        while depth:
            t = tag_re.search(text, end)
            if not t:
                return None
            if t.group(1) == "/":
                depth -= 1
            elif t.group(2) != "/":
                depth += 1
            end = t.end()
    line_start = text.rfind("\n", 0, start) + 1
    if text[line_start:start].strip() == "":
        start = line_start
        if text.startswith("\n", end):
            end += 1
    return start, end


def remove_duplicates(text: str, mapping: dict[str, str]) -> tuple[str, list[str]]:
    ids = {m.group(1) for m in XMLID_RE.finditer(text)}
    removed = []
    for old in sorted(ids, key=int):
        new = mapping.get(old)
        if not new or new not in ids:
            continue
        m = re.search(r"\sxml:id\s*=\s*[\"']pmb" + old + r"[\"']", text)
        span = find_element_span(text, text.rfind("<", 0, m.start())) if m else None
        if not span:
            print(f"WARNUNG: Dublette pmb{old} konnte nicht entfernt werden", file=sys.stderr)
            continue
        text = text[: span[0]] + text[span[1]:]
        removed.append(f"pmb{old} (Dublette von pmb{new})")
    return text, removed


# --------------------------------------------------------------------------
# Bericht
# --------------------------------------------------------------------------

def rel(p: Path) -> str:
    try:
        return str(p.resolve().relative_to(Path.cwd()))
    except ValueError:
        return str(p)


def markdown_report(used, report, missing, where, errors, dry_run) -> str:
    out = ["## PMB-Nummern-Prüfung", ""]
    if not used and not report and not missing and not errors:
        out.append("Alle PMB-Nummern sind aktuell. ✅")
        return "\n".join(out) + "\n"
    if used:
        out += [f"### {len(used)} veraltete Nummern", "", "| alt | neu |", "|---|---|"]
        out += [f"| pmb{o} | pmb{n} |" for o, n in sorted(used.items(), key=lambda kv: int(kv[0]))]
        out.append("")
    if report:
        verb = "würden geändert" if dry_run else "geändert"
        normalized = sum(c[NORMALIZED] for _, c, _ in report)
        if normalized:
            out += [f"{normalized} Verweise wie `pmbperson__123` zu `pmb123` vereinheitlicht.", ""]
        out += [f"**{len(report)} Dateien {verb}:**", ""]
        for f, counter, removed in report:
            parts = []
            refs = sum(v for k, v in counter.items() if k != NORMALIZED)
            if refs:
                parts.append(f"{refs} Referenzen aktualisiert")
            if counter[NORMALIZED]:
                parts.append(f"{counter[NORMALIZED]} vereinheitlicht")
            if removed:
                parts.append(f"entfernt: {', '.join(removed)}")
            out.append(f"- `{rel(f)}`: " + "; ".join(parts))
        out.append("")
    if missing:
        out += [f"### {len(missing)} Nummern in der PMB nicht gefunden (404)", "",
                "Diese müssen manuell korrigiert werden:", ""]
        for n in missing:
            fs = sorted(rel(f) for f in where[n])
            out.append(f"- pmb{n}: " + ", ".join(f"`{x}`" for x in fs[:8]) + (" …" if len(fs) > 8 else ""))
        out.append("")
    if errors:
        out += [f"### {len(errors)} Nummern nicht abfragbar (Netzwerk/Serverfehler)", "",
                ", ".join(f"pmb{n}" for n in errors[:50]) + (" …" if len(errors) > 50 else ""), ""]
    return "\n".join(out) + "\n"


def set_github_output(**values):
    path = os.environ.get("GITHUB_OUTPUT")
    if path:
        with open(path, "a", encoding="utf-8") as fh:
            for k, v in values.items():
                fh.write(f"{k}={v}\n")


# --------------------------------------------------------------------------
# main
# --------------------------------------------------------------------------

def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("paths", nargs="*", type=Path,
                    help="Ordner oder Dateien (Standard: ./data, falls vorhanden, sonst .)")
    ap.add_argument("--dry-run", action="store_true", help="nichts schreiben, nur berichten")
    ap.add_argument("--source", choices=("export", "online"), default="export",
                    help="export: PMB-Gesamtexport (schnell, Standard); online: jede Nummer einzeln abfragen")
    ap.add_argument("--export-dir", type=Path,
                    help="Ordner für den PMB-Export; vorhandene Dateien werden wiederverwendet "
                         "(Standard: temporär, wird danach gelöscht)")
    ap.add_argument("--refresh", action="store_true", help="Export auch dann neu laden, wenn er im --export-dir liegt")
    ap.add_argument("--no-verify", action="store_true",
                    help="im Export fehlende Nummern nicht online nachprüfen")
    ap.add_argument("--index", default="list*.xml",
                    help="Dateimuster der Index-Dateien, für den Hinweis nach dem Umschreiben (Standard: list*.xml)")
    ap.add_argument("--attrs", default=",".join(DEFAULT_ATTRS),
                    help=f"zu prüfende Attribute (Standard: {','.join(DEFAULT_ATTRS)})")
    ap.add_argument("--exclude-element", action="append", default=None, metavar="NAME",
                    help="Elemente ignorieren (mehrfach möglich; Standard: occupation)")
    ap.add_argument("--keep-prefix", action="store_true",
                    help="Schreibweisen wie pmbperson__123 beibehalten (Standard: zu pmb123 vereinheitlichen)")
    ap.add_argument("--workers", type=int, default=8, help="parallele Anfragen an die PMB (Standard: 8)")
    ap.add_argument("--report", type=Path, help="Zuordnung alt -> neu als CSV schreiben")
    ap.add_argument("--summary", type=Path, help="Bericht als Markdown schreiben")
    ap.add_argument("--fail-on-missing", action="store_true",
                    help="Exit-Code 2, wenn Nummern in der PMB nicht existieren")
    args = ap.parse_args()

    paths = args.paths or [Path("data") if Path("data").is_dir() else Path(".")]
    excluded = args.exclude_element if args.exclude_element is not None else list(DEFAULT_EXCLUDED)
    scanner = Scanner([a.strip() for a in args.attrs.split(",") if a.strip()], excluded)

    files = xml_files(paths)
    where: dict[str, set[Path]] = defaultdict(set)
    for f in files:
        for n in scanner.numbers(f.read_text(encoding="utf-8")):
            where[n].add(f)
    numbers = set(where)
    print(f"{len(files)} XML-Dateien, {len(numbers)} verschiedene PMB-Nummern gefunden.")

    missing: list[str] = []
    errors: list[str] = []
    if args.source == "online":
        mapping, missing, errors = online_mapping(numbers, args.workers)
    else:
        tmp = None if args.export_dir else tempfile.mkdtemp(prefix="pmb-export-")
        try:
            export_files = download_exports(args.export_dir or Path(tmp), args.refresh)
            print("Lese PMB-Export …", flush=True)
            current, mapping = export_mapping(export_files)
        finally:
            if tmp:
                shutil.rmtree(tmp, ignore_errors=True)
        print(f"  {len(current)} Entitäten, {len(mapping)} gemergte Nummern.")
        unknown = {n for n in numbers if n not in current and n not in mapping}
        if unknown and not args.no_verify:
            print(f"{len(unknown)} Nummern nicht im Export – prüfe online nach.")
            extra, missing, errors = online_mapping(unknown, args.workers)
            mapping.update(extra)
        else:
            missing = sorted(unknown, key=int)
    used = {k: v for k, v in resolve_chains(mapping).items() if k in numbers}

    report = []
    if used or not args.keep_prefix:
        for f in files:
            original = f.read_text(encoding="utf-8")
            text, removed = remove_duplicates(original, used)
            counter: Counter = Counter()
            text = scanner.rewrite(text, used, not args.keep_prefix, counter)
            if text != original:
                report.append((f, counter, removed))
                if not args.dry_run:
                    f.write_text(text, encoding="utf-8")

    md = markdown_report(used, report, missing, where, errors, args.dry_run)
    print("\n" + md)
    if args.summary:
        args.summary.write_text(md, encoding="utf-8")
    if os.environ.get("GITHUB_STEP_SUMMARY"):
        with open(os.environ["GITHUB_STEP_SUMMARY"], "a", encoding="utf-8") as fh:
            fh.write(md)
    if args.report:
        with args.report.open("w", newline="", encoding="utf-8") as fh:
            w = csv.writer(fh)
            w.writerow(["alt", "neu"])
            for old, new in sorted(used.items(), key=lambda kv: int(kv[0])):
                w.writerow([f"pmb{old}", f"pmb{new}"])
    set_github_output(outdated=len(used), changed_files=len(report),
                      missing=len(missing), errors=len(errors))

    if report and not args.dry_run and any(f.match(args.index) for f, _, _ in report):
        print("Hinweis: Index-Dateien wurden geändert – danach die Einträge aus der PMB "
              "neu laden (z. B. Workflow 'update-from-pmb').")
    if errors:
        return 1
    if missing and args.fail_on_missing:
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
