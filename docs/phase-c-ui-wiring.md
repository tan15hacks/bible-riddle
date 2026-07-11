# Phase C UI runtime wiring

This branch connects the playable Flutter UI to the repository-backed runtime services.

## What changed

- `lib/main.dart` now loads content through `AssetContentRepository` instead of reading JSON directly in the UI state object.
- Progress, economy, and statistics now save through `SharedPreferencesProgressRepository`.
- Answer submission now goes through `GameplayRuntime.submitAnswer`.
- Wrong answers now go through `GameplayRuntime.recordWrongAnswer`.
- Hint spending now goes through `GameplayRuntime.spendHint`.
- Reusable answer matching and reward rules replace the duplicate Phase A helper logic.

## Why this matters

The app is still playable offline, but the gameplay flow now uses repository contracts and application services. This makes the next migration to a Drift-backed repository much safer because the UI no longer owns the persistence logic directly.

## Remaining work

- Generate Drift code locally with `build_runner`.
- Implement a Drift-backed `ProgressRepository`.
- Swap the provider implementation from the SharedPreferences adapter to the Drift adapter.
- Add widget tests around the repository-backed gameplay flow.

## Expected local validation

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
flutter analyze
flutter run
```

Flutter checks were not run in the assistant environment because Flutter is not installed here.
