import '../entities/campaign_section.dart';
import '../entities/riddle.dart';
import '../entities/testament.dart';

abstract interface class ContentRepository {
  Future<List<Riddle>> getRiddles({Testament? testament});
  Future<Riddle?> getRiddleById(String id);
  Future<List<CampaignSection>> getSections(Testament testament);
  Future<void> importRiddles(List<Riddle> riddles);
}
