import '../../domain/entities/game_content.dart';
import 'content_import_report.dart';
import 'content_validator.dart';

abstract interface class ContentImportTarget {
  Future<void> upsertContent(GameContent content);
}

class ContentImporter {
  ContentImporter({required this.validator, required this.target});

  final ContentValidator validator;
  final ContentImportTarget target;

  Future<ContentImportReport> importContent(GameContent content) async {
    final result = validator.validate(content);
    if (result.hasCriticalErrors) {
      return ContentImportReport(
        totalRiddles: content.riddles.length,
        insertedRiddles: 0,
        updatedRiddles: 0,
        skippedRiddles: content.riddles.length,
        criticalErrors: result.criticalErrors,
        warnings: result.warnings,
      );
    }

    await target.upsertContent(content);
    return ContentImportReport(
      totalRiddles: content.riddles.length,
      insertedRiddles: content.riddles.length,
      updatedRiddles: 0,
      skippedRiddles: 0,
      criticalErrors: const [],
      warnings: result.warnings,
    );
  }
}
