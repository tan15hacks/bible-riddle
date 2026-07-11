# Content Import

Phase B supports a safe import path for JSON and spreadsheet-exported CSV.

## CSV to JSON

```bash
python tool/import_csv.py content.csv assets/data/generated_content.json
```

## Validate before import

```bash
python tool/validate_content.py assets/data
```

The Flutter-side `ContentImporter` runs the Dart validator before calling a repository import method. If the report contains critical errors, the importer refuses to write content.

## Content updates

Future import implementations should upsert by riddle ID and preserve existing player progress, stars, achievements, purchases, and profile data.
