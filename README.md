# Bible Riddle — Phase B

A peaceful, minimalist, offline-first Bible riddle game foundation built with Flutter and Dart.

Phase A is merged. Phase B adds the production-facing data architecture needed before expanding features and content.

## Included now

- Playable offline Phase A game loop
- Splash, onboarding, home, campaign, level, gameplay, progress, and settings screens
- Separate Old Testament and New Testament campaigns
- Bundled JSON sample content marked `needs_review`
- Python content validator
- Drift-ready SQLite schema
- Domain entities and repository contracts
- Content import and validation services
- CSV-to-JSON import tooling
- CI workflow for validation, generation, analysis, and tests
- Documentation for database, content import, review, testing, and release preparation

## Why Phase B matters

The master specification requires more than static screens. The app must support offline persistence, scalable content imports, validation gates, progress-safe updates, and future 1,000+ reviewed riddles. Phase B creates those boundaries while keeping the Phase A gameplay intact.

## Run locally

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
python tool/validate_content.py assets/data
flutter test
flutter run
```

If platform folders are missing:

```bash
flutter create --platforms=android,ios,web .
```

## Content workflow

1. Author content using the documented columns.
2. Convert CSV when needed:

   ```bash
   python tool/import_csv.py content.csv assets/data/generated_content.json
   ```

3. Validate content:

   ```bash
   python tool/validate_content.py assets/data
   ```

4. Import only when there are no critical validation errors.

## Production note

Generated Bible riddles remain `needs_review` until a qualified review process marks them `reviewed`. Do not ship unreviewed generated content as verified production content.

## Next phase

Phase C wires the runtime gameplay flow to the repository/data layer, then adds achievements, daily-riddle persistence, challenge records, and richer statistics.
