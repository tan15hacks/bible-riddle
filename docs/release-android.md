# Android release notes

Phase B is not release-ready yet, but this file tracks the release path.

## Required before release

- Generate Android platform folder with `flutter create --platforms=android .` if missing.
- Add final package/application ID.
- Configure launcher icons and splash assets.
- Add release signing through local `key.properties`; never commit signing keys.
- Run content validation and ship only reviewed content.
- Build and test an Android App Bundle.

## Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
python tool/validate_content.py assets/data
flutter test
flutter build appbundle --release --dart-define=ENABLE_ADS=false
```

## Google Play checklist

- Privacy policy URL
- Data Safety form
- Ads declaration if rewarded ads are enabled later
- Content rating questionnaire
- Screenshots and feature graphic
- Internal testing track before production rollout
