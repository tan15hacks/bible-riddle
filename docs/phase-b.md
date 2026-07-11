# Phase B — Local data layer and content pipeline

Phase B introduces the production storage architecture while keeping the Phase A offline loop usable.

## Added in this phase

- Drift/SQLite schema covering riddles, sections, level progress, profile, economy, statistics, achievements, daily riddles, purchases, and app settings.
- Repository interfaces for content and progress.
- Import gate that validates content before it is written to local storage.
- CSV-to-JSON conversion tooling for spreadsheet-authored riddle packs.
- CI code-generation step for Drift generated files.

## Not yet completed

The running Phase A UI still uses bundled JSON plus SharedPreferences. The next integration step is to wire providers to `AppDatabase`, run Drift code generation, and migrate existing SharedPreferences progress into SQLite.

## Local commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
python tool/validate_content.py assets/data
flutter test
```
