import '../entities/game_content.dart';
import '../entities/riddle.dart';
import '../entities/testament.dart';

abstract interface class ContentRepository {
  Future<GameContent> loadContent();
  Future<List<Riddle>> riddlesForTestament(Testament testament);
  Future<Riddle?> findRiddle(String id);
}
