# Phase C next steps

Phase C should turn the Phase B architecture into runtime behavior.

## Implementation tasks

1. Generate Drift code with build_runner.
2. Add Riverpod providers for `AppDatabase`, `ContentRepository`, and `ProgressRepository`.
3. Import bundled JSON content into SQLite on first launch.
4. Add content version checks using `manifest.json`.
5. Migrate existing SharedPreferences progress into SQLite once.
6. Replace direct SharedPreferences gameplay writes with progress repository calls.
7. Add achievement persistence and unlock checks.
8. Add daily riddle persistence.
9. Add widget tests for campaign, level, gameplay, hints, result, and settings flows.

## Acceptance criteria

- Existing Phase A gameplay still works.
- Content imports into SQLite and refuses critical validation errors.
- Progress persists through Drift, not SharedPreferences.
- Migration does not erase existing Phase A progress.
