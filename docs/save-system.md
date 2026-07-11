# Save system

Phase A stores progress with SharedPreferences. Phase B introduces the SQLite tables needed for a safer long-term save system.

## Current save data

- Coins
- Total answers
- Correct answers
- Current streak
- Best streak
- Stars by riddle

## Phase C migration target

- `level_progress` for per-riddle completion and stars
- `player_economy_rows` for coin balance and totals
- `player_statistics_rows` for answer counts and streaks
- `app_settings` for settings

## Migration rule

On first launch after the Drift integration, copy existing SharedPreferences progress into SQLite, then mark migration complete. Do not delete the old preferences until the SQLite save is confirmed.
