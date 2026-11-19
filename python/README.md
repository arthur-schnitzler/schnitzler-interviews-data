# PMB-Nummern prüfen und aktualisieren

`pmb_nummern_aktualisieren.py` prüft alle PMB-Nummern in den XML-Dateien eines
Projekts. Wenn eine Nummer durch einen Merge in der PMB in einem anderen Eintrag
aufgegangen ist, wird sie auf die aktuelle Nummer umgeschrieben. Nummern, die es
in der PMB gar nicht mehr gibt, werden gemeldet.

Grundlage ist der täglich erzeugte Gesamtexport der PMB
(`https://pmb.acdh.oeaw.ac.at/media/list*.xml`, ca. 210 MB): Jede Entität
führt dort die Nummern der in sie gemergten Einträge als
`<idno subtype="pmb">`. Download und Auswertung dauern zusammen unter einer
Minute, auch bei großen Projekten. Nummern, die im Export fehlen, werden
einzeln online nachgeprüft, weil der Export bis zu einem Tag alt sein kann.

Das Skript braucht nur Python 3.9+ ohne zusätzliche Pakete und funktioniert in
jedem Projekt, das PMB-Entitäten als `pmb123`, `#pmb123` oder
`https://pmb.acdh.oeaw.ac.at/entity/123/` in Attributen referenziert.

## Lokal ausführen

```bash
python3 pmb_nummern_aktualisieren.py --dry-run        # nur berichten
python3 pmb_nummern_aktualisieren.py                  # umschreiben (./data, sonst .)
python3 pmb_nummern_aktualisieren.py editions indices # nur bestimmte Ordner
```

Weitere Optionen zeigt `--help`, unter anderem:

| Option | Zweck |
|---|---|
| `--export-dir ORDNER` | PMB-Export dort ablegen und bei weiteren Läufen wiederverwenden (`--refresh` lädt neu) |
| `--source online` | jede Nummer einzeln bei der PMB abfragen statt den Export zu nutzen (langsam) |
| `--report alt-neu.csv` | Zuordnung alt → neu als Tabelle |
| `--exclude-element NAME` | Elemente ignorieren (Standard: `occupation`, deren Refs auf Vokabulare zeigen) |
| `--keep-prefix` | Schreibweisen wie `pmbperson__123` beibehalten (Standard: zu `pmb123` vereinheitlichen) |

## Monatliche Prüfung in einem anderen Repository

Datei `.github/workflows/pmb-nummern-pruefen.yml` anlegen:

```yaml
name: PMB-Nummern prüfen

on:
  schedule:
    - cron: '0 4 1 * *' # am 1. jedes Monats
  workflow_dispatch:

jobs:
  pmb:
    uses: arthur-schnitzler/schnitzler-interviews-data/.github/workflows/pmb-nummern-pruefen.yml@main
    permissions:
      contents: write
      pull-requests: write
    # optional:
    # with:
    #   paths: editions indices      # Standard: ./data, sonst das ganze Repository
    #   args: --keep-prefix
    #   pull-request: true           # Pull-Request statt direktem Commit
```

Ablauf:

- Gibt es veraltete Nummern, committet der Workflow die Änderungen direkt
  („Veraltete PMB-Nummern aktualisiert“). Mit `pull-request: true` legt er
  stattdessen einen Pull-Request an, dessen Beschreibung alle Ersetzungen listet.
- Gibt es Nummern, die in der PMB nicht mehr existieren, schlägt der Lauf fehl.
  Dadurch kommt eine Benachrichtigung per E-Mail, und die Liste steht in der
  Zusammenfassung des Laufs.

Damit der Workflow mit `pull-request: true` Pull-Requests anlegen darf, muss unter *Settings → Actions →
General* die Option **Allow GitHub Actions to create and approve pull requests**
aktiviert sein. Bei Repositories einer Organisation muss sie auch in den
Einstellungen der Organisation erlaubt sein.

Wenn Index-Dateien (`list*.xml`) geändert wurden, sollten danach die Einträge
neu aus der PMB geladen werden, z. B. mit dem Workflow `update-from-pmb`.
