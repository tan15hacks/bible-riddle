# Phase D — Drift progress persistence

Phase D replaces the temporary SharedPreferences runtime store with Drift/SQLite while preserving existing player saves.

## Added

- `AppDatabase.open()` creates the local SQLite database in the application documents directory and runs it in a background isolate.
- `ContentDatabaseSeeder` upserts bundled riddles before progress rows are written, satisfying the progress foreign key.
- `DriftProgressRepository` stores level progress, stars, economy, statistics, streaks, and reset operations in SQLite.
- `ProgressMigrationService` migrates both the original Phase A keys and the repository-based SharedPreferences keys.
- `RuntimeBootstrap` loads content, opens Drift, seeds content, migrates saves, and provides the runtime dependencies.
- A safe SharedPreferences fallback remains available only when SQLite initialization fails.
- In-memory Drift tests validate persistence, best-star merging, resets, and migration idempotency.

## Migration safety

The migration flag is written only after level progress, economy, and statistics are successfully copied. Legacy keys are not deleted, so recovery remains possible if an application update is interrupted.

## Build generation

The database generated file is intentionally produced by build runner:

```bash
dart run build_runner build --delete-conflicting-outputs
```

GitHub Actions runs generation before tests and analysis.

## Expected validation

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
python tool/validate_content.py assets/data
flutter test
flutter analyze
flutter run
```
