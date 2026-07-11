# Environment configuration

Phase B adds `.env.example` for future services. Do not commit production secrets.

## Current example keys

- `ENABLE_ADS`
- `ENABLE_FIREBASE`
- `ENABLE_ANALYTICS`
- `REMOTE_CONTENT_ENDPOINT`
- `ADMOB_REWARDED_ANDROID_TEST_ID`
- Purchase product identifiers

## Recommended use

Use Dart defines for build-time flags:

```bash
flutter run --dart-define=ENABLE_ADS=false
flutter build appbundle --release --dart-define=ENABLE_ADS=false
```

Production AdMob IDs, Firebase files, signing keys, service-account files, and private tokens must stay outside the repository.
