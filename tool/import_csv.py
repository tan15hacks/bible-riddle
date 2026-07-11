#!/usr/bin/env python3
import csv
import json
import sys
from pathlib import Path

REQUIRED_COLUMNS = [
    'id','testament','book','chapter_start','chapter_end','verse_start','verse_end','section_id','topic',
    'story_event_id','concept_tags','question_type','difficulty','question','answer','accepted_answers',
    'choice_a','choice_b','choice_c','choice_d','hint_1','hint_2','hint_3','explanation','reference',
    'translation_notice','content_status','sort_order'
]


def split_list(value: str):
    if not value:
        return []
    return [item.strip() for item in value.replace('|', ';').split(';') if item.strip()]


def int_value(value: str, default: int = 0):
    value = (value or '').strip()
    return int(value) if value else default


def convert_row(row):
    choices = [row.get(f'choice_{letter}', '').strip() for letter in ['a', 'b', 'c', 'd']]
    choices = [choice for choice in choices if choice]
    return {
        'id': row['id'].strip(),
        'testament': row['testament'].strip(),
        'book': row['book'].strip(),
        'chapterStart': int_value(row.get('chapter_start', '')),
        'chapterEnd': int_value(row.get('chapter_end', '')),
        'verseStart': int_value(row.get('verse_start', '')),
        'verseEnd': int_value(row.get('verse_end', '')),
        'sectionId': row['section_id'].strip(),
        'topic': row['topic'].strip(),
        'storyEventId': row['story_event_id'].strip(),
        'conceptTags': split_list(row.get('concept_tags', '')),
        'questionType': row['question_type'].strip(),
        'difficulty': int_value(row.get('difficulty', ''), 1),
        'question': row['question'].strip(),
        'answer': row['answer'].strip(),
        'acceptedAnswers': split_list(row.get('accepted_answers', '')) or [row['answer'].strip()],
        'choices': choices,
        'hints': [row.get('hint_1', '').strip(), row.get('hint_2', '').strip(), row.get('hint_3', '').strip()],
        'explanation': row['explanation'].strip(),
        'reference': row['reference'].strip(),
        'translationNotice': row.get('translation_notice', '').strip(),
        'contentStatus': row.get('content_status', 'needs_review').strip() or 'needs_review',
        'sortOrder': int_value(row.get('sort_order', ''), 0),
    }


def main():
    if len(sys.argv) != 3:
        print('Usage: python tool/import_csv.py input.csv output.json')
        raise SystemExit(2)
    input_path = Path(sys.argv[1])
    output_path = Path(sys.argv[2])
    with input_path.open(newline='', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        missing = [column for column in REQUIRED_COLUMNS if column not in (reader.fieldnames or [])]
        if missing:
            print('Missing columns: ' + ', '.join(missing))
            raise SystemExit(1)
        riddles = [convert_row(row) for row in reader]
    output = {'version': 1, 'contentStatus': 'needs_review', 'riddles': riddles}
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(output, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
    print(f'Converted {len(riddles)} riddles to {output_path}')


if __name__ == '__main__':
    main()
