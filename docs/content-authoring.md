# Content Authoring

Use original paraphrases plus references unless a legally distributable public-domain translation is intentionally included.

## Required CSV columns

```text
id,testament,book,chapter_start,chapter_end,verse_start,verse_end,section_id,topic,story_event_id,concept_tags,question_type,difficulty,question,answer,accepted_answers,choice_a,choice_b,choice_c,choice_d,hint_1,hint_2,hint_3,explanation,reference,translation_notice,content_status,sort_order
```

## List fields

Use `|` to separate list values:

```text
David|King David
```

## Status values

- `needs_review`: generated or unverified development content.
- `reviewed`: approved for production release.

Only reviewed content should be included in production builds.
