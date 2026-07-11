# Bible Riddle — Phase B

A peaceful, minimalist, offline-first Bible riddle game foundation built with Flutter and Dart.

## Current scope

Phase B builds on the playable Phase A loop and adds the production-oriented local data architecture required by the master specification.

### Phase A playable loop

- Splash/loading flow
- First-run onboarding
- Home screen
- Separate Old Testament and New Testament campaigns
- Section and level selection
- Locked/unlocked level progression
- Multiple-choice and typed-answer riddles
- Accepted-answer matching
- Hint reveal with coin cost
- Star and coin rewards
- Local progress persistence with SharedPreferences
- Progress/statistics screen
- Settings with reset progress
- Bundled JSON content
- Python content validator
- Basic unit test

### Phase B additions

- Drift/SQLite dependency configuration
- Drift-ready schema for riddles, campaign sections, level progress, profile, economy, statistics, achievements, daily riddles, purchases, and app settings
- Domain entity files for future repository-based architecture
- Content and progress repository interfaces
- App-level content validator and import gate
- CSV-to-JSON import tool for spreadsheet-authored riddles
- Database, import, and Phase B documentation
- CI workflow prepared to run Drift code generation before analysis/tests

## Production honesty

This is still not the final production release. The included sample riddles are marked `needs_review`; only reviewed Bible content should ship.

## Run locally

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
python tool/validate_content.py assets/data
flutter test
flutter run
```

If the Android/iOS platform folders are missing, generate them first:

```bash
flutter create --platforms=android,ios,web .
```

## Content authoring

Convert spreadsheet CSV exports into JSON packs:

```bash
python tool/import_csv.py path/to/riddles.csv assets/data/custom_pack.json
python tool/validate_content.py assets/data
```

## Next phases

- Phase C: Wire runtime providers to Drift, migrate SharedPreferences progress into SQLite, and add achievement/daily-riddle persistence.
- Phase D: Challenge modes and deeper statistics.
- Phase E: Optional rewarded ads, purchases, privacy controls, QA, 1,000+ reviewed content pipeline, and Google Play release preparation.
