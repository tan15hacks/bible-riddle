# QA checklist

## Phase B manual checks

- App still launches after dependency changes.
- Build runner generates Drift files.
- Python validator runs with zero critical errors.
- CSV importer rejects missing columns.
- Existing Phase A gameplay still works.
- Sample content remains marked `needs_review`.

## Later checks

- Progress migration preserves completion.
- SQLite import refuses critical validation errors.
- Large text does not clip gameplay controls.
- Offline mode works with no internet.
- Optional services failing do not crash the app.
