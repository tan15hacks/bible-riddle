# Phase C — Runtime Repository Wiring

Phase C starts moving gameplay runtime logic out of the Phase A monolithic `main.dart` file and into application/data layers.

## Added in this phase

- `AssetContentRepository` loads bundled JSON content through the `ContentRepository` contract.
- `SharedPreferencesProgressRepository` implements the `ProgressRepository` contract as a bridge layer before full Drift runtime migration.
- `GameplayRuntime` handles answer submission, star calculation, coin rewards, level progress, economy updates, and streak/statistics updates through repositories.
- Reusable answer matching and reward rules are moved to application-layer files.
- Riverpod runtime providers expose repositories and gameplay runtime services.
- Tests cover repository-backed answer submission, rewards, streaks, close-answer feedback, and hint spending.

## Why SharedPreferences remains temporarily

Phase B introduced Drift schema and generated database requirements, but generated `.g.dart` files should be produced locally with Flutter/Dart tooling. Because the assistant environment cannot run Flutter/Dart, this phase uses a repository-backed SharedPreferences adapter to keep the app runnable while the storage boundary becomes replaceable.

Phase C therefore improves architecture without breaking Phase A gameplay.

## Next integration step

Replace the direct state methods in `GameState` with calls to:

- `contentRepositoryProvider`
- `progressRepositoryProvider`
- `gameplayRuntimeProvider`

Then migrate the progress repository implementation from `SharedPreferencesProgressRepository` to a Drift-backed implementation after running:

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test
flutter analyze
```

## Acceptance checklist

- Existing Phase A screens still compile.
- New gameplay runtime tests pass.
- UI progress behavior remains unchanged from the player perspective.
- Future Drift migration requires swapping repository implementations, not rewriting screens.
