# Phase B merge notes

After merging Phase B, run these locally:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
python tool/validate_content.py assets/data
flutter analyze
flutter test
```

Then proceed to Phase C: wire runtime providers to Drift and migrate existing SharedPreferences progress into SQLite.
