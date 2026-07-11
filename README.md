# Bible Riddle

A peaceful, minimalist, offline-first Bible riddle game built with Flutter.

> Status: Phase 1–2 foundation. The repository contains the playable campaign foundation, local Drift schema, JSON content import, duplicate/content validation, answer matching, rewards, sample content, tests, CI, and architecture documentation. The full 1,000+ reviewed content pack and later gameplay systems must be completed through the documented phases before a production release.

## Product rules

- Old Testament and New Testament progress are independent.
- Campaign content is stored as versioned JSON assets and imported into SQLite.
- Core gameplay works without Firebase, ads, purchases, or internet access.
- Rewarded ads are optional and accessed only through an abstraction.
- No core Bible content is paywalled.
- Repeated answers are allowed only when the tested event or concept is genuinely different.
- AI-generated sample content remains `needs_review` until a qualified human reviewer approves it.

## Stack

- Flutter + Dart
- Material 3
- Riverpod
- GoRouter
- Drift / SQLite
- SharedPreferences for lightweight preferences only
- Optional Firebase Analytics and Crashlytics
- Optional Google Mobile Ads rewarded ads
- Optional in-app purchases

## Setup

1. Install the current Flutter stable SDK and Android Studio.
2. Clone the repository.
3. Generate platform folders if this checkout does not contain them yet:

   ```bash
   flutter create --platforms=android,ios,web .
   ```

4. Fetch packages and generate Drift code:

   ```bash
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   ```

5. Validate content:

   ```bash
   python tool/validate_content.py assets/data
   ```

6. Run the app:

   ```bash
   flutter run
   ```

## Quality commands

```bash
dart format --set-exit-if-changed lib test tool
flutter analyze
flutter test
python tool/validate_content.py assets/data
```

## Environment configuration

Copy `.env.example` values into CI secrets or pass them with `--dart-define`. No production secrets, signing keys, Firebase service files, or AdMob IDs belong in Git.

## Content authoring

Use `assets/data/riddle_template.csv` and follow:

- `docs/content-authoring.md`
- `docs/content-validation.md`
- `docs/bible-content-review.md`

The included 20 riddles are development samples. They are structurally validated but intentionally marked `needs_review`; they are not represented as theologically verified production content.

## Architecture

See `docs/architecture.md`.

## Android release

See `docs/release-android.md`.
