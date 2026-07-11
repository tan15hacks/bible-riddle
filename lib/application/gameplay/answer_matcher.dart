String normalizeAnswer(String input) {
  return input
      .toLowerCase()
      .replaceAll(RegExp(r'[’‘`´]'), "'")
      .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

bool isAcceptedAnswer(String input, List<String> acceptedAnswers) {
  final normalized = normalizeAnswer(input);
  return acceptedAnswers.any((answer) => normalizeAnswer(answer) == normalized);
}

bool isVeryCloseAnswer(String input, List<String> acceptedAnswers) {
  final normalized = normalizeAnswer(input);
  if (normalized.length < 3) return false;
  for (final answer in acceptedAnswers.map(normalizeAnswer)) {
    if (answer == normalized) return false;
    if (answer.contains(normalized) || normalized.contains(answer)) return true;
  }
  return false;
}
