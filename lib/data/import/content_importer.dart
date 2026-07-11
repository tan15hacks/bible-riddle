import '../../domain/entities/riddle.dart';
import '../../domain/repositories/content_repository.dart';
import 'content_import_report.dart';
import 'content_validator.dart';

class ContentImporter {
  const ContentImporter({
    required ContentValidator validator,
    required ContentRepository repository,
  })  : _validator = validator,
        _repository = repository;

  final ContentValidator _validator;
  final ContentRepository _repository;

  Future<ContentImportReport> validateAndImport(List<Riddle> riddles) async {
    final report = _validator.validate(riddles);
    if (!report.canImport) {
      return report;
    }
    await _repository.importRiddles(riddles);
    return report;
  }
}
