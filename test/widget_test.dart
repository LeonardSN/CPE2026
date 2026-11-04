import 'package:flutter_test/flutter_test.dart';
import 'package:mathou/curriculum/curriculum.dart';
import 'package:mathou/logic/adaptive_engine.dart';
import 'package:mathou/logic/exercise_generator.dart';

/// Lancer avec : flutter test
/// Vérifie que TOUS les chapitres de TOUTES les classes génèrent des
/// questions valides à chaque niveau (bonne réponse présente, pas de doublon).
void main() {
  final gen = ExerciseGenerator();

  for (final cycle in Curriculum.allCycles) {
    for (final chapter in cycle.chapters) {
      test('${cycle.title} · ${chapter.title}', () {
        for (var level = 1; level <= 5; level++) {
          for (var i = 0; i < 150; i++) {
            for (final count in [3, 4]) {
              final ex = gen.generateChoices(chapter.id, level, count);
              expect(ex.prompt, isNotEmpty);
              expect(ex.choices.length, count,
                  reason: '${ex.prompt} -> ${ex.choices}');
              expect(ex.choices.toSet().length, count,
                  reason: 'doublon : ${ex.prompt} -> ${ex.choices}');
              expect(ex.choices, contains(ex.answer));
            }
            final quiz = gen.generate(chapter.id, level);
            expect(quiz.answer, isNotEmpty);
          }
        }
      });
    }
  }

  test('Le moteur adaptatif monte de niveau après des bonnes réponses', () {
    var theta = AdaptiveEngine.initialRating;
    expect(AdaptiveEngine.chooseLevel(theta), 1);
    for (var i = 0; i < 10; i++) {
      theta = AdaptiveEngine.update(theta, AdaptiveEngine.chooseLevel(theta), true);
    }
    expect(AdaptiveEngine.chooseLevel(theta), greaterThan(1));
  });
}
