import 'package:flutter_test/flutter_test.dart';
import 'package:mathou/logic/adaptive_engine.dart';
import 'package:mathou/logic/exercise_generator.dart';
import 'package:mathou/models/skill.dart';

void main() {
  test('Le générateur produit des exercices valides pour chaque niveau', () {
    final gen = ExerciseGenerator();
    for (final s in Skills.tracked) {
      for (var level = 1; level <= 5; level++) {
        for (var i = 0; i < 200; i++) {
          final ex = gen.generate(s.id, level);
          expect(ex.prompt, isNotEmpty);
          expect(ex.answer, isNotEmpty);
          if (ex.choices.isNotEmpty) {
            expect(ex.choices.length, 4);
            expect(ex.choices.toSet().length, 4);
            expect(ex.choices, contains(ex.answer));
          }
        }
      }
    }
  });

  test('Le moteur adaptatif monte de niveau après des bonnes réponses', () {
    var theta = AdaptiveEngine.initialRating;
    expect(AdaptiveEngine.chooseLevel(theta), 1);
    for (var i = 0; i < 10; i++) {
      theta = AdaptiveEngine.update(theta, AdaptiveEngine.chooseLevel(theta), true);
    }
    expect(AdaptiveEngine.chooseLevel(theta), greaterThan(1));
  });
}
