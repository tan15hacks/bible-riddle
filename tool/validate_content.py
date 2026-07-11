#!/usr/bin/env python3
import json
import re
import sys
from collections import Counter
from pathlib import Path

REQUIRED = [
    'id', 'testament', 'book', 'reference', 'topic', 'storyEventId', 'questionType',
    'difficulty', 'question', 'answer', 'acceptedAnswers', 'choices', 'hints',
    'explanation', 'contentStatus', 'sortOrder'
]
VALID_TESTAMENTS = {'old', 'new'}


def norm(text):
    return re.sub(r'\s+', ' ', re.sub(r'[^a-z0-9 ]', ' ', text.lower())).strip()


def load_riddles(root):
    root = Path(root)
    manifest = json.loads((root / 'manifest.json').read_text(encoding='utf-8'))
    riddles = []
    for pack in manifest['packs']:
        data = json.loads((root / pack).read_text(encoding='utf-8'))
        riddles.extend(data['riddles'])
    return riddles


def validate(riddles):
    errors = []
    warnings = []
    ids = Counter(r['id'] for r in riddles)
    questions = Counter(norm(r['question']) for r in riddles)
    events = Counter(r['storyEventId'] for r in riddles)

    for value, count in ids.items():
        if count > 1:
            errors.append(f'Duplicate id: {value}')
    for value, count in questions.items():
        if count > 1:
            errors.append(f'Duplicate normalized question: {value}')
    for value, count in events.items():
        if count > 1:
            errors.append(f'Repeated storyEventId: {value}')

    for riddle in riddles:
        missing = [field for field in REQUIRED if field not in riddle]
        if missing:
            errors.append(f"{riddle.get('id', '<missing id>')} missing fields: {', '.join(missing)}")
            continue
        if riddle['testament'] not in VALID_TESTAMENTS:
            errors.append(f"{riddle['id']} has invalid testament")
        if not riddle['reference']:
            errors.append(f"{riddle['id']} missing reference")
        if not riddle['explanation']:
            errors.append(f"{riddle['id']} missing explanation")
        if len(riddle['hints']) < 3:
            errors.append(f"{riddle['id']} must include at least three hints")
        if not 1 <= int(riddle['difficulty']) <= 10:
            errors.append(f"{riddle['id']} difficulty must be 1-10")
        if riddle['choices'] and riddle['answer'] not in riddle['choices']:
            errors.append(f"{riddle['id']} answer not present in choices")
        if riddle['contentStatus'] != 'reviewed':
            warnings.append(f"{riddle['id']} contentStatus is {riddle['contentStatus']}")

    return errors, warnings


def main():
    root = sys.argv[1] if len(sys.argv) > 1 else 'assets/data'
    riddles = load_riddles(root)
    errors, warnings = validate(riddles)
    print('Validation complete')
    print(f'Total riddles: {len(riddles)}')
    print(f'Critical errors: {len(errors)}')
    print(f'Warnings: {len(warnings)}')
    for item in errors:
        print(f'ERROR: {item}')
    for item in warnings[:20]:
        print(f'WARN: {item}')
    if errors:
        raise SystemExit(1)


if __name__ == '__main__':
    main()
