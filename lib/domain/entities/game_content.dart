import 'campaign_section.dart';
import 'riddle.dart';
import 'testament.dart';

class GameContent {
  const GameContent({required this.sections, required this.riddles});

  final List<CampaignSection> sections;
  final List<Riddle> riddles;

  List<CampaignSection> sectionsFor(Testament testament) {
    return sections.where((section) => section.testament == testament).toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  }

  List<Riddle> riddlesForSection(String sectionId) {
    return riddles.where((riddle) => riddle.sectionId == sectionId).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  List<Riddle> riddlesForTestament(Testament testament) {
    return riddles.where((riddle) => riddle.testament == testament).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  Riddle? byId(String id) {
    for (final riddle in riddles) {
      if (riddle.id == id) return riddle;
    }
    return null;
  }
}
