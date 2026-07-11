# Phase C — Runtime Repository Services

Phase C begins moving gameplay logic out of the Phase A monolithic screen file and into replaceable services.

## Added

- `AssetContentRepository` loads bundled JSON content through the `ContentRepository` contract.
- `SharedPreferencesProgressRepository` implements the `ProgressRepository` contract as a temporary runtime bridge.
- `GameplayRuntime` handles answer submission, close-answer feedback, star rewards, coin rewards, progress saves, economy updates, and streak/statistics updates through repositories.
- `answer_matcher.dart` and `reward_rules.dart` isolate reusable gameplay rules.
- `runtime_providers.dart` exposes repository and runtime services through Riverpod.
- `gameplay_runtime_test.dart` validates repository-backed answer submission, hint spending, coin rewards, and streak updates.

## Why this still uses SharedPreferences

Phase B adds Drift schema and generated database requirements. Full Drift runtime use should happen locally after running `build_runner`, because generated files cannot be produced in the assistant environment. This phase keeps the app runnable while moving the architecture to repository boundaries.

## Next step

Wire the existing Phase A `GameState` UI methods to these providers, then replace the SharedPreferences progress implementation with a Drift-backed implementation.

Expected local checks:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
flutter analyze
```
