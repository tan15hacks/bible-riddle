import 'testament.dart';

class CampaignSection {
  const CampaignSection({
    required this.id,
    required this.testament,
    required this.title,
    required this.description,
    required this.books,
    required this.orderIndex,
    required this.iconKey,
  });

  final String id;
  final Testament testament;
  final String title;
  final String description;
  final List<String> books;
  final int orderIndex;
  final String iconKey;

  factory CampaignSection.fromJson(Map<String, dynamic> json) {
    return CampaignSection(
      id: json['id'] as String,
      testament: Testament.fromStorage(json['testament'] as String),
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      books: List<String>.from((json['books'] ?? <String>[]) as List<dynamic>),
      orderIndex: json['orderIndex'] as int? ?? 0,
      iconKey: json['iconKey'] as String? ?? 'scroll',
    );
  }
}
