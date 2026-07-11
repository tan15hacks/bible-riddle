# Testing

## Current tests

- Answer normalization and accepted-answer checks.
- Dart content validator behavior.
- Python JSON content validation through CI.

## Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
python tool/validate_content.py assets/data
```

## Next tests

Phase C should add widget tests for campaign navigation, gameplay, hints, result states, settings reset, and persistence migration.
