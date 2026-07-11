# Phase E — Daily Riddle and Achievements

This phase adds persistent engagement systems that work completely offline.

## Daily Riddle

- Selects one deterministic riddle per local calendar date.
- Stores the selected riddle and completion in Drift.
- Awards a one-time 25-coin daily bonus.
- Prevents duplicate reward claims.
- Calculates consecutive-day streaks from stored completion dates.
- Uses the safe SharedPreferences engagement adapter when SQLite is unavailable.

## Achievements

Seven achievements track completed levels, total stars, correct answers, best streak, total coins earned, and Daily Riddle streaks.

- Progress is recalculated from authoritative player statistics.
- Unlocks are persisted.
- Coin rewards are granted exactly once when an achievement first unlocks.
- The home, progress, and achievements screens show current status.

## Architecture cleanup

The former monolithic `lib/main.dart` is split into:

- `lib/app/bible_riddle_app.dart`
- `lib/app/game_controller.dart`
- `lib/app/game_screens.dart`

`lib/main.dart` is now only the application entrypoint.

## Validation

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
python tool/validate_content.py assets/data
flutter test
flutter analyze
```
