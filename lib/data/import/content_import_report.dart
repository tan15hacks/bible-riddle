class ContentImportReport {
  const ContentImportReport({
    required this.totalRiddles,
    required this.insertedRiddles,
    required this.updatedRiddles,
    required this.skippedRiddles,
    required this.criticalErrors,
    required this.warnings,
  });

  final int totalRiddles;
  final int insertedRiddles;
  final int updatedRiddles;
  final int skippedRiddles;
  final List<String> criticalErrors;
  final List<String> warnings;

  bool get hasCriticalErrors => criticalErrors.isNotEmpty;
}
