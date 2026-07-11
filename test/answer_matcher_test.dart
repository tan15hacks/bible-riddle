import 'package:bible_riddle/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizes answers', () {
    expect(normalizeAnswer('  John   the Baptist! '), 'john the baptist');
  });

  test('matches accepted answers exactly after normalization', () {
    expect(isAcceptedAnswer('king david', ['David', 'King David']), isTrue);
    expect(isAcceptedAnswer('Daniel', ['David', 'King David']), isFalse);
  });

  test('calculates rewards', () {
    expect(calculateStars(attempts: 1, hintsUsed: 0), 3);
    expect(calculateStars(attempts: 2, hintsUsed: 1), 2);
    expect(calculateCoins(difficulty: 4, stars: 3), 20);
  });
}
