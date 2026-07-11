class ContentImportReport {
  const ContentImportReport({
    required this.totalRiddles,
    required this.criticalErrors,
    required this.warnings,
  });

  final int totalRiddles;
  final List<String> criticalErrors;
  final List<String> warnings;

  bool get canImport => criticalErrors.isEmpty;

  String toReadableString() {
    return [
      'Validation complete',
      'Total riddles: $totalRiddles',
      'Critical errors: ${criticalErrors.length}',
      'Warnings: ${warnings.length}',
      ...criticalErrors.map((error) => 'ERROR: $error'),
      ...warnings.map((warning) => 'WARNING: $warning'),
    ].join('\n');
  }
}
