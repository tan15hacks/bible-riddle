# Database

The app uses Drift with SQLite for structured offline storage.

## Tables

- `riddles`: imported Bible riddle content and metadata.
- `campaign_sections`: Old and New Testament section metadata.
- `level_progress_rows`: completion, stars, attempts, hints, and timing per riddle.
- `player_profiles`: local player profile without required account creation.
- `player_economy_rows`: coin balance and lifetime earned/spent counts.
- `player_statistics_rows`: answer totals, streaks, play time, and challenge score JSON.
- `achievement_rows`: achievement progress and unlock timestamps.
- `daily_riddle_progress_rows`: daily completion and reward state.
- `purchase_rows`: local purchase entitlement cache.
- `app_settings_rows`: persisted settings.

## Migration rule

Future migrations must preserve completed levels, stars, purchases, profile data, and player economy. Content updates should upsert riddles by ID without resetting progress.

## Code generation

```bash
dart run build_runner build --delete-conflicting-outputs
```
