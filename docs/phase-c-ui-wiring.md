# Phase C UI runtime wiring

This branch connects the playable Flutter UI to the repository-backed runtime services.

## What changed

- `lib/main.dart` loads content through `AssetContentRepository` instead of reading JSON directly in the UI state object.
- Progress, economy, and statistics save through `SharedPreferencesProgressRepository`.
- Answer submission goes through `GameplayRuntime.submitAnswer`.
- Wrong answers go through `GameplayRuntime.recordWrongAnswer`.
- Hint spending goes through `GameplayRuntime.spendHint`.
- Reusable answer matching and reward rules replace duplicate Phase A helper logic.

## Why this matters

The app remains playable offline, but the gameplay flow now uses repository contracts and application services. The next migration to a Drift-backed repository can happen without rewriting the screens.

## Remaining work

- Generate Drift code with `build_runner`.
- Implement a Drift-backed `ProgressRepository`.
- Swap the provider implementation from SharedPreferences to Drift.
- Add widget tests around the repository-backed gameplay flow.

## Expected local validation

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
flutter analyze
flutter run
```
