# Content validation

Run the Python validator before importing or releasing content:

```bash
python tool/validate_content.py assets/data
```

The validator checks duplicate IDs, duplicate questions, normalized duplicate wording, repeated story events, missing required fields, invalid Bible book/testament combinations, answer-choice validity, duplicate choices, repeated references, duplicate explanations, and nearby repeated answers.

Critical errors must block import and release.

Warnings may be allowed during development, but production content should be clean and marked `reviewed`.
