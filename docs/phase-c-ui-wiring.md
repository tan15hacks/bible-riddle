# Phase C UI runtime wiring

This branch connects the existing playable Phase A UI to the Phase C runtime services.

## What changed

- `lib/main.dart` no longer reads bundled JSON directly with `rootBundle`.
- Content now loads through `AssetContentRepository`.
- Progress, economy, and statistics now save through `SharedPreferencesProgressRepository`.
- Answer submission now goes through `GameplayRuntime.submitAnswer`.
- Wrong answers now go through `GameplayRuntime.recordWrongAnswer`.
- Hint spending now goes through `GameplayRuntime.spendHint`.
- Reusable answer matching and reward rules replace the duplicate local helpers from Phase A.

## Why SharedPreferences remains

The repository adapter still uses SharedPreferences as a bridge so the playable loop remains usable before Drift generated files are produced locally. The next storage phase should add a Drift-backed `ProgressRepository` and swap the provider implementation.

## Expected validation

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
flutter analyze
flutter run
```

Flutter checks were not run in the assistant environment because Flutter is not installed here.
