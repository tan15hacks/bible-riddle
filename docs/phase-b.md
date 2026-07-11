# Phase B — Data Layer and Content System

Phase B adds the production-facing data architecture required by the master spec while preserving the Phase A playable loop.

## Added

- Drift-ready SQLite schema
- Domain entities for content and progress
- Repository contracts for content and progress
- Dart content validator and import gate
- CSV-to-JSON import tool
- CI workflow for code generation, validation, analysis, and tests
- Environment example for ads, Firebase flags, remote content, and purchases

## Not yet wired into runtime

The Phase A UI still uses SharedPreferences directly. Phase C should migrate runtime gameplay state to repository-backed persistence.

## Acceptance checklist

- `flutter pub get`
- `dart run build_runner build --delete-conflicting-outputs`
- `python tool/validate_content.py assets/data`
- `flutter test`
- `flutter analyze`

Flutter is not installed in the assistant environment, so these checks must run locally or in GitHub Actions.
