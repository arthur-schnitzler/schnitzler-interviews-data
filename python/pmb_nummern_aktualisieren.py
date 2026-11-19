#!/usr/bin/env python3
"""
Überprüft alle PMB-Nummern im Repository auf Aktualität und schreibt
veraltete Nummern (z. B. nach einem Merge in der PMB) auf die aktuelle um.

Ermittlung der aktuellen Nummer
-------------------------------
* online (Standard): Für jede gefundene Nummer N wird
  https://pmb.acdh.oeaw.ac.at/entity/N/ abgefragt. Die PMB leitet weiter auf
  /apis/entities/entity/<typ>/<aktuelle-nummer>/detail – auch für Nummern, die
  durch einen Merge in einem anderen Eintrag aufgegangen sind.
* offline (--offline): Nur aus den Index-Dateien (data/indices/list*.xml).
  Ein Eintrag mit @xml:id="pmbX", der zusätzliche <idno subtype="pmb"> mit
  anderen Nummern Y enthält, ergibt die Zuordnung Y -> X.
  Achtung: Bei listPerson übernimmt die Update-XSLT die lokale @xml:id, dort
  ist die @xml:id also nicht zwingend die aktuelle Nummer. Online ist sicherer.

Was umgeschrieben wird
----------------------
* Attributwerte von ref, corresp, sameAs, target, source, who und xml:id,
  sofern sie Token der Form "pmb123" oder "#pmb123" enthalten
  (auch mehrere, durch Leerzeichen getrennt). Doppelte Token werden entfernt.
* Ausgenommen sind <occupation>-Elemente: deren @ref verweist auf
  PMB-Vokabulare mit eigenem Nummernkreis, nicht auf Entitäten.
* Textinhalte (z. B. <idno>-URLs zu anderen Projekten) bleiben unverändert,
  ebenso @key (PMB-interne Schlüssel für Berufe, Events u. ä.).
* Gibt es in einer Datei sowohl ein Element mit @xml:id="pmbALT" als auch eines
  mit @xml:id="pmbNEU", wird das Element mit der alten Nummer entfernt
  (Dublette nach Merge). Sonst wird nur die @xml:id umbenannt.

Die Dateien werden textbasiert bearbeitet, die Formatierung bleibt erhalten.

Aufruf
------
    python python/pmb_nummern_aktualisieren.py --dry-run     # nur berichten
    python python/pmb_nummern_aktualisieren.py               # umschreiben
    python python/pmb_nummern_aktualisieren.py --offline     # ohne Netz
    python python/pmb_nummern_aktualisieren.py --cache pmb-cache.json

Nach dem Umschreiben sollte der Workflow "update-from-pmb" laufen, damit
umbenannte Index-Einträge mit den aktuellen PMB-Daten befüllt werden.
"""

from __future__ import annotations

import argparse
import csv
import json
import re
import sys
import time
import urllib.error
import urllib.request
from collections import Counter, defaultdict
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
DATA = REPO / "data"
INDICES = DATA / "indices"

PMB_ENTITY_URL = "https://pmb.acdh.oeaw.ac.at/entity/{}/"
LOCATION_RE = re.compile(r"/entity/(?:[a-z]+/)?(\d+)/")

ATTRS = ("ref", "corresp", "sameAs", "target", "source", "who", "xml:id")
# Elemente, deren pmb-Refs auf PMB-Vokabulare zeigen (eigener Nummernkreis)
EXCLUDED_ELEMENTS = {"occupation"}
START_TAG_RE = re.compile(
    r"<([\w.-]+(?::[\w.-]+)?)((?:\s+[\w:.-]+\s*=\s*(?:\"[^\"]*\"|'[^']*'))*)(\s*/?>)"
)
ATTR_RE = re.compile(
    r"(\s(?:" + "|".join(re.escape(a) for a in ATTRS) + r")\s*=\s*)([\"'])(.*?)\2",
    re.DOTALL,
)
# "pmb123" oder "#pmb123" als eigenständiges Token (nicht Teil einer URL)
TOKEN_RE = re.compile(r"(?<![\w/.#-])(#?)pmb(\d+)(?![\w.])")
XMLID_RE = re.compile(r"\sxml:id\s*=\s*[\"']pmb(\d+)[\"']")
IDNO_PMB_RE = re.compile(r"entity/(\d+)")


# --------------------------------------------------------------------------
# Sammeln
# --------------------------------------------------------------------------

def iter_attr_values(text: str):
    """Liefert (Start-Tag-Match, Attribut-Match) für alle relevanten Attribute."""
    for tag in START_TAG_RE.finditer(text):
        if tag.group(1).split(":")[-1] in EXCLUDED_ELEMENTS:
            continue
        for attr in ATTR_RE.finditer(tag.group(2)):
            yield tag, attr


def xml_files(root: Path) -> list[Path]:
    return sorted(p for p in root.rglob("*.xml") if p.is_file())


def collect_numbers(files: list[Path]) -> set[str]:
    """Alle PMB-Nummern, die in relevanten Attributen vorkommen."""
    numbers: set[str] = set()
    for f in files:
        text = f.read_text(encoding="utf-8")
        for _, attr in iter_attr_values(text):
            numbers.update(n for _, n in TOKEN_RE.findall(attr.group(3)))
    return numbers


def offline_mapping() -> dict[str, str]:
    """Y -> X aus den Index-Dateien (xml:id=pmbX, idno subtype=pmb mit Y)."""
    from lxml import etree

    ns = {"tei": "http://www.tei-c.org/ns/1.0"}
    xml_id = "{http://www.w3.org/XML/1998/namespace}id"
    mapping: dict[str, str] = {}
    for f in sorted(INDICES.glob("list*.xml")):
        tree = etree.parse(str(f))
        for el in tree.xpath("//tei:body//*[starts-with(@xml:id, 'pmb')]", namespaces=ns):
            current = el.get(xml_id)[3:]
            for idno in el.xpath("tei:idno[@subtype='pmb']", namespaces=ns):
                m = IDNO_PMB_RE.search(idno.text or "")
                if m and m.group(1) != current:
                    if m.group(1) in mapping and mapping[m.group(1)] != current:
                        print(
                            f"WARNUNG: pmb{m.group(1)} ist mehreren Einträgen zugeordnet "
                            f"(pmb{mapping[m.group(1)]}, pmb{current}) – übersprungen",
                            file=sys.stderr,
                        )
                        continue
                    mapping[m.group(1)] = current
    return mapping


# --------------------------------------------------------------------------
# Online-Prüfung
# --------------------------------------------------------------------------

class _NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, *args, **kwargs):  # noqa: D401
        return None


_OPENER = urllib.request.build_opener(_NoRedirect)


def resolve_online(number: str, retries: int = 3) -> tuple[str, str | None]:
    """Gibt (status, aktuelle Nummer) zurück. status: ok | missing | error."""
    url = PMB_ENTITY_URL.format(number)
    req = urllib.request.Request(
        url, method="HEAD", headers={"User-Agent": "pmb-id-check/1.0"}
    )
    for attempt in range(retries):
        try:
            resp = _OPENER.open(req, timeout=30)
            location = resp.headers.get("Location", "")
            code = resp.status
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


def online_mapping(
    numbers: set[str], workers: int, cache_path: Path | None
) -> tuple[dict[str, str], list[str], list[str]]:
    cache: dict[str, list] = {}
    if cache_path and cache_path.exists():
        cache = json.loads(cache_path.read_text(encoding="utf-8"))

    todo = sorted((n for n in numbers if n not in cache), key=int)
    print(f"Prüfe {len(todo)} Nummern online ({len(numbers) - len(todo)} aus Cache) …")
    errors: list[str] = []
    with ThreadPoolExecutor(max_workers=workers) as pool:
        futures = {pool.submit(resolve_online, n): n for n in todo}
        for done, fut in enumerate(as_completed(futures), 1):
            n = futures[fut]
            status, current = fut.result()
            if status == "error":  # nicht cachen, beim nächsten Lauf neu versuchen
                errors.append(n)
            else:
                cache[n] = [status, current]
            if done % 250 == 0:
                print(f"  … {done}/{len(todo)}")
    errors.sort(key=int)

    if cache_path:
        cache_path.write_text(json.dumps(cache, indent=1, sort_keys=True), encoding="utf-8")

    mapping: dict[str, str] = {}
    missing: list[str] = []
    for n in numbers:
        if n not in cache:
            continue
        status, current = cache[n]
        if status == "missing":
            missing.append(n)
        elif status == "ok" and current and current != n:
            mapping[n] = current
    return mapping, sorted(missing, key=int), errors


def resolve_chains(mapping: dict[str, str]) -> dict[str, str]:
    """A -> B, B -> C  ==>  A -> C."""
    resolved = {}
    for old in mapping:
        seen = {old}
        new = mapping[old]
        while new in mapping and new not in seen:
            seen.add(new)
            new = mapping[new]
        if new != old:
            resolved[old] = new
    return resolved


# --------------------------------------------------------------------------
# Umschreiben
# --------------------------------------------------------------------------

def find_element_span(text: str, start: int) -> tuple[int, int] | None:
    """Span des Elements, dessen Start-Tag bei `start` ('<') beginnt."""
    m = re.compile(r"<([\w:.-]+)\b[^>]*?(/?)>", re.DOTALL).match(text, start)
    if not m:
        return None
    name = m.group(1)
    if m.group(2) == "/":
        end = m.end()
    else:
        tag_re = re.compile(r"<(/?)" + re.escape(name) + r"\b[^>]*?(/?)>", re.DOTALL)
        depth = 1
        pos = m.end()
        while depth:
            t = tag_re.search(text, pos)
            if not t:
                return None
            if t.group(1) == "/":
                depth -= 1
            elif t.group(2) != "/":
                depth += 1
            pos = t.end()
        end = pos
    # vorangehende Einrückung und nachfolgenden Zeilenumbruch mitnehmen
    line_start = text.rfind("\n", 0, start) + 1
    if text[line_start:start].strip() == "":
        start = line_start
        if text.startswith("\n", end):
            end += 1
    return start, end


def remove_duplicates(text: str, mapping: dict[str, str]) -> tuple[str, list[str]]:
    """Entfernt Elemente mit xml:id=pmbALT, wenn pmbNEU in derselben Datei existiert."""
    ids = {m.group(1) for m in XMLID_RE.finditer(text)}
    removed = []
    for old in sorted(ids, key=int):
        new = mapping.get(old)
        if not new or new not in ids:
            continue
        m = re.search(r"\sxml:id\s*=\s*[\"']pmb" + old + r"[\"']", text)
        if not m:
            continue
        tag_start = text.rfind("<", 0, m.start())
        span = find_element_span(text, tag_start)
        if not span:
            print(f"WARNUNG: Element pmb{old} konnte nicht entfernt werden", file=sys.stderr)
            continue
        text = text[: span[0]] + text[span[1]:]
        removed.append(f"pmb{old} (Dublette von pmb{new})")
    return text, removed


def rewrite_attrs(text: str, mapping: dict[str, str], counter: Counter) -> str:
    def repl_value(value: str) -> str:
        def repl_token(t: re.Match) -> str:
            hash_, num = t.group(1), t.group(2)
            if num in mapping:
                counter[(num, mapping[num])] += 1
                return f"{hash_}pmb{mapping[num]}"
            return t.group(0)

        new_value = TOKEN_RE.sub(repl_token, value)
        if new_value != value and " " in new_value.strip():
            # doppelte Token entfernen (Reihenfolge beibehalten)
            tokens = new_value.split()
            new_value = " ".join(dict.fromkeys(tokens))
        return new_value

    def repl_attr(m: re.Match) -> str:
        return f"{m.group(1)}{m.group(2)}{repl_value(m.group(3))}{m.group(2)}"

    def repl_tag(tag: re.Match) -> str:
        if tag.group(1).split(":")[-1] in EXCLUDED_ELEMENTS:
            return tag.group(0)
        return f"<{tag.group(1)}{ATTR_RE.sub(repl_attr, tag.group(2))}{tag.group(3)}"

    return START_TAG_RE.sub(repl_tag, text)


def process_files(files, mapping, dry_run):
    report = []
    for f in files:
        original = f.read_text(encoding="utf-8")
        text, removed = remove_duplicates(original, mapping)
        counter: Counter = Counter()
        text = rewrite_attrs(text, mapping, counter)
        if text == original:
            continue
        report.append((f, counter, removed))
        if not dry_run:
            f.write_text(text, encoding="utf-8")
    return report


# --------------------------------------------------------------------------
# main
# --------------------------------------------------------------------------

def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--dry-run", action="store_true", help="nichts schreiben, nur berichten")
    ap.add_argument("--offline", action="store_true", help="nur Index-Dateien auswerten, keine PMB-Abfrage")
    ap.add_argument("--workers", type=int, default=8, help="parallele Anfragen an die PMB (Standard: 8)")
    ap.add_argument("--cache", type=Path, help="JSON-Datei zum Zwischenspeichern der PMB-Antworten")
    ap.add_argument("--report", type=Path, help="Zuordnung alt -> neu als CSV schreiben")
    ap.add_argument("--data", type=Path, default=DATA, help=f"Datenverzeichnis (Standard: {DATA})")
    args = ap.parse_args()

    files = xml_files(args.data)
    numbers = collect_numbers(files)
    print(f"{len(files)} XML-Dateien, {len(numbers)} verschiedene PMB-Nummern gefunden.")

    missing: list[str] = []
    errors: list[str] = []
    if args.offline:
        mapping = offline_mapping()
    else:
        mapping, missing, errors = online_mapping(numbers, args.workers, args.cache)
    mapping = resolve_chains(mapping)

    used = {k: v for k, v in mapping.items() if k in numbers}
    print(f"\n{len(used)} veraltete Nummern im Bestand:")
    for old, new in sorted(used.items(), key=lambda kv: int(kv[0])):
        print(f"  pmb{old} -> pmb{new}")

    if args.report:
        with args.report.open("w", newline="", encoding="utf-8") as fh:
            w = csv.writer(fh)
            w.writerow(["alt", "neu"])
            for old, new in sorted(used.items(), key=lambda kv: int(kv[0])):
                w.writerow([f"pmb{old}", f"pmb{new}"])

    report = process_files(files, used, args.dry_run) if used else []

    verb = "würden geändert" if args.dry_run else "geändert"
    print(f"\n{len(report)} Dateien {verb}:")
    for f, counter, removed in report:
        n = sum(counter.values())
        print(f"  {f.relative_to(REPO) if f.is_relative_to(REPO) else f}: {n} Referenzen", end="")
        print(f", entfernt: {', '.join(removed)}" if removed else "")

    if missing:
        print(f"\n{len(missing)} Nummern in der PMB nicht gefunden (404) – bitte manuell prüfen:")
        where = defaultdict(set)
        for f in files:
            text = f.read_text(encoding="utf-8")
            for _, attr in iter_attr_values(text):
                for _, n in TOKEN_RE.findall(attr.group(3)):
                    if n in missing:
                        where[n].add(f.name)
        for n in missing:
            fs = sorted(where[n])
            print(f"  pmb{n}: {', '.join(fs[:5])}{' …' if len(fs) > 5 else ''}")

    if errors:
        print(f"\n{len(errors)} Nummern konnten nicht abgefragt werden (Netzwerk/Serverfehler): "
              + ", ".join(f"pmb{n}" for n in errors[:20]) + (" …" if len(errors) > 20 else ""))

    if report and not args.dry_run and any(INDICES in f.parents for f, _, _ in report):
        print("\nHinweis: Index-Dateien wurden geändert. Danach den Workflow "
              "'update-from-pmb' laufen lassen, um die Einträge zu aktualisieren.")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
