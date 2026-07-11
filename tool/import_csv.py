#!/usr/bin/env python3
"""Convert the Bible Riddle authoring CSV format into JSON content."""

from __future__ import annotations

import csv
import json
import sys
from pathlib import Path

REQUIRED_COLUMNS = [
    "id",
    "testament",
    "book",
    "chapter_start",
    "chapter_end",
    "verse_start",
    "verse_end",
    "section_id",
    "topic",
    "story_event_id",
    "concept_tags",
    "question_type",
    "difficulty",
    "question",
    "answer",
    "accepted_answers",
    "choice_a",
    "choice_b",
    "choice_c",
    "choice_d",
    "hint_1",
    "hint_2",
    "hint_3",
    "explanation",
    "reference",
    "translation_notice",
    "content_status",
    "sort_order",
]


def split_list(value: str) -> list[str]:
    return [item.strip() for item in value.split("|") if item.strip()]


def convert_row(row: dict[str, str]) -> dict[str, object]:
    choices = [row.get(key, "").strip() for key in ("choice_a", "choice_b", "choice_c", "choice_d")]
    choices = [choice for choice in choices if choice]
    return {
        "id": row["id"].strip(),
        "testament": row["testament"].strip(),
        "book": row["book"].strip(),
        "chapterStart": int(row.get("chapter_start") or 0),
        "chapterEnd": int(row.get("chapter_end") or 0),
        "verseStart": int(row.get("verse_start") or 0),
        "verseEnd": int(row.get("verse_end") or 0),
        "sectionId": row["section_id"].strip(),
        "topic": row["topic"].strip(),
        "storyEventId": row["story_event_id"].strip(),
        "conceptTags": split_list(row.get("concept_tags", "")),
        "questionType": row["question_type"].strip(),
        "difficulty": int(row["difficulty"]),
        "question": row["question"].strip(),
        "answer": row["answer"].strip(),
        "acceptedAnswers": split_list(row.get("accepted_answers", "")) or [row["answer"].strip()],
        "choices": choices,
        "hints": [row.get("hint_1", "").strip(), row.get("hint_2", "").strip(), row.get("hint_3", "").strip()],
        "explanation": row["explanation"].strip(),
        "reference": row["reference"].strip(),
        "translationNotice": row.get("translation_notice", "").strip(),
        "contentStatus": row["content_status"].strip(),
        "sortOrder": int(row["sort_order"]),
        "version": 1,
    }


def main() -> int:
    if len(sys.argv) != 3:
        print("Usage: python tool/import_csv.py input.csv output.json", file=sys.stderr)
        return 2

    input_path = Path(sys.argv[1])
    output_path = Path(sys.argv[2])
    with input_path.open(newline="", encoding="utf-8") as handle:
        reader = csv.DictReader(handle)
        missing = [column for column in REQUIRED_COLUMNS if column not in (reader.fieldnames or [])]
        if missing:
            print(f"Missing required columns: {', '.join(missing)}", file=sys.stderr)
            return 1
        riddles = [convert_row(row) for row in reader]

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps({"riddles": riddles}, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"Wrote {len(riddles)} riddles to {output_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
