import 'testament.dart';

class Riddle {
  const Riddle({
    required this.id,
    required this.testament,
    required this.book,
    required this.chapterStart,
    required this.chapterEnd,
    required this.verseStart,
    required this.verseEnd,
    required this.sectionId,
    required this.topic,
    required this.storyEventId,
    required this.conceptTags,
    required this.questionType,
    required this.difficulty,
    required this.question,
    required this.answer,
    required this.acceptedAnswers,
    required this.choices,
    required this.hints,
    required this.explanation,
    required this.reference,
    required this.translationNotice,
    required this.contentStatus,
    required this.sortOrder,
    required this.version,
  });

  final String id;
  final Testament testament;
  final String book;
  final int chapterStart;
  final int chapterEnd;
  final int verseStart;
  final int verseEnd;
  final String sectionId;
  final String topic;
  final String storyEventId;
  final List<String> conceptTags;
  final String questionType;
  final int difficulty;
  final String question;
  final String answer;
  final List<String> acceptedAnswers;
  final List<String> choices;
  final List<String> hints;
  final String explanation;
  final String reference;
  final String translationNotice;
  final String contentStatus;
  final int sortOrder;
  final int version;

  bool get isTypedAnswer => choices.isEmpty;
  bool get isReviewed => contentStatus == 'reviewed';

  factory Riddle.fromJson(Map<String, Object?> json) {
    return Riddle(
      id: json['id']! as String,
      testament: Testament.fromKey(json['testament']! as String),
      book: json['book']! as String,
      chapterStart: (json['chapterStart'] ?? json['chapter_start'] ?? 0) as int,
      chapterEnd: (json['chapterEnd'] ?? json['chapter_end'] ?? 0) as int,
      verseStart: (json['verseStart'] ?? json['verse_start'] ?? 0) as int,
      verseEnd: (json['verseEnd'] ?? json['verse_end'] ?? 0) as int,
      sectionId: (json['sectionId'] ?? json['section_id'])! as String,
      topic: json['topic']! as String,
      storyEventId: (json['storyEventId'] ?? json['story_event_id'])! as String,
      conceptTags: List<String>.from((json['conceptTags'] ?? json['concept_tags'] ?? const <String>[]) as List),
      questionType: (json['questionType'] ?? json['question_type'])! as String,
      difficulty: json['difficulty']! as int,
      question: json['question']! as String,
      answer: json['answer']! as String,
      acceptedAnswers: List<String>.from((json['acceptedAnswers'] ?? json['accepted_answers'])! as List),
      choices: List<String>.from((json['choices'] ?? const <String>[]) as List),
      hints: List<String>.from((json['hints'] ?? const <String>[]) as List),
      explanation: json['explanation']! as String,
      reference: json['reference']! as String,
      translationNotice: (json['translationNotice'] ?? json['translation_notice'] ?? '') as String,
      contentStatus: (json['contentStatus'] ?? json['content_status'])! as String,
      sortOrder: (json['sortOrder'] ?? json['sort_order'])! as int,
      version: (json['version'] ?? 1) as int,
    );
  }
}
