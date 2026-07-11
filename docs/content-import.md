# Content import

Content can be authored in spreadsheets and exported as CSV, then converted to JSON packs.

## CSV conversion

```bash
python tool/import_csv.py path/to/riddles.csv assets/data/custom_pack.json
python tool/validate_content.py assets/data
```

The importer expects the columns listed in `assets/data/riddle_template.csv`.

## Import safety

The app-level `ContentImporter` validates content before writing to the storage target. Critical errors block import. Warnings are allowed for development, but production release should include only reviewed content.

## Production content rule

Generated riddles must stay marked `needs_review` until reviewed for biblical accuracy, references, answer correctness, and denominational neutrality.
