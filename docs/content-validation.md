# Content Validation

Validation exists to prevent repetitive, inaccurate, or broken riddle content from entering the local database.

## Critical errors

- Duplicate riddle IDs
- Duplicate normalized questions
- Repeated `storyEventId`
- Missing Bible references
- Missing explanations
- Invalid difficulty values
- Multiple correct answer choices
- Answer missing from choices
- Invalid content status

## Warnings

- Unreviewed content
- Repeated reference and question type
- Duplicate explanations
- Fewer than three hints

## Commands

```bash
python tool/validate_content.py assets/data
flutter test test/content_validator_test.dart
```
