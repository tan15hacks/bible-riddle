# Bible Riddle — Phase A

A peaceful, minimalist, offline-first Bible riddle game foundation built with Flutter and Dart.

## What this branch contains

Phase A is a playable offline foundation, not the full 1,000+ reviewed-level production release yet.

Included now:

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

## Why this is Phase A

The master specification requires a complete production app with Drift, optional ads, purchases, achievements, challenge modes, statistics, Google Play release setup, automated tests, and 1,000+ reviewed Bible riddles. Phase A focuses on the core offline game loop first so the project can be run, tested, and expanded safely.

The included sample riddles are marked `needs_review`. They are development content and should not be presented as a verified Bible-content release.

## Run locally

```bash
flutter pub get
python tool/validate_content.py assets/data
flutter test
flutter run
```

If the Android/iOS platform folders are missing, generate them first:

```bash
flutter create --platforms=android,ios,web .
```

## Next phases

- Phase B: Replace lightweight progress storage with Drift/SQLite, add generated models, and expand repository abstractions.
- Phase C: Achievements, deeper statistics, daily riddle persistence, and challenge modes.
- Phase D: Optional rewarded ads and purchase abstractions.
- Phase E: 1,000+ content pipeline, review workflow, QA, and Google Play release preparation.
