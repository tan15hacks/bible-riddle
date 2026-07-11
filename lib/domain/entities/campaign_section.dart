import 'testament.dart';

class CampaignSection {
  const CampaignSection({
    required this.id,
    required this.testament,
    required this.title,
    required this.description,
    required this.orderIndex,
    required this.requiredLevels,
    required this.iconKey,
  });

  final String id;
  final Testament testament;
  final String title;
  final String description;
  final int orderIndex;
  final int requiredLevels;
  final String iconKey;
}
