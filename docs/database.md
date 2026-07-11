# Database

The app uses Drift with SQLite as the production local database target.

## Tables

- `riddles` — versioned Bible riddle content with metadata for validation and duplicate detection.
- `campaign_sections` — Old/New Testament section definitions.
- `level_progress` — completion, stars, attempts, hints, and timing per riddle.
- `player_profile_rows` — local profile data without requiring accounts.
- `player_economy_rows` — coin balance and earned/spent totals.
- `player_statistics_rows` — answer counts, streaks, play time, and challenge score JSON.
- `achievements` — progress toward unlockable achievements.
- `daily_riddle_progress_rows` — local daily riddle state by date.
- `purchases` — locally cached purchase entitlement states.
- `app_settings` — simple key/value settings.

## Migration rule

Never change a riddle ID after release. Progress is keyed by `riddle_id`, so content updates must preserve IDs and only add or carefully revise records.

## Code generation

Run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Generated Drift files are intentionally not edited by hand.
