# Content authoring

Use `assets/data/riddle_template.csv` as the spreadsheet template.

## Required workflow

1. Author riddles in a spreadsheet using the required columns.
2. Export as CSV.
3. Convert CSV to JSON:

```bash
python tool/import_csv.py riddles.csv assets/data/custom_pack.json
```

4. Validate:

```bash
python tool/validate_content.py assets/data
```

5. Keep generated content marked `needs_review` until reviewed.

## Required production metadata

Every production riddle needs a testament, book, chapter/verse range, story event ID, question type, difficulty, answer, accepted answers, hints, explanation, reference, and `reviewed` content status.
