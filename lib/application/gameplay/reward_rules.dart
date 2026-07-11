int calculateStars({required int attempts, required int hintsUsed, bool revealedAnswer = false}) {
  if (revealedAnswer) return 1;
  if (attempts <= 1 && hintsUsed == 0) return 3;
  if (attempts <= 2 && hintsUsed <= 1) return 2;
  return 1;
}

int calculateCoins({required int difficulty, required int stars, bool firstCompletion = true}) {
  final base = firstCompletion ? 10 : 4;
  final difficultyBonus = difficulty >= 7 ? 15 : difficulty >= 4 ? 5 : 0;
  final perfectBonus = stars == 3 ? 5 : 0;
  return base + difficultyBonus + perfectBonus;
}

const hintCoinCost = 30;
