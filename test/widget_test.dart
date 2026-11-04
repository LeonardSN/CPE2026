import 'package:flutter_test/flutter_test.dart';
import 'package:mathou/curriculum/curriculum.dart';
import 'package:mathou/logic/adaptive_engine.dart';
import 'package:mathou/logic/exercise_generator.dart';
import 'package:mathou/models/exercise.dart';

/// Lancer avec : flutter test
/// Vérifie que TOUS les chapitres de TOUTES les classes (PS → Terminale)
/// génèrent des questions valides à chaque niveau.
void main() {
  final gen = ExerciseGenerator();

  int count(String s, String c) => c.allMatches(s).length;

  void checkMath(String s) {
    expect(count(s, '{'), count(s, '}'), reason: 'accolades : $s');
  }

  test('Identifiants de chapitres uniques', () {
    final ids = <String>{};
    for (final cycle in Curriculum.allCycles) {
      for (final ch in cycle.map) {
        expect(ids.add(ch.id), isTrue, reason: 'id en double : ${ch.id}');
      }
    }
  });

  for (final cycle in Curriculum.allCycles) {
    for (final chapter in cycle.chapters) {
      test('${cycle.title} · ${chapter.title}', () {
        for (var level = 1; level <= 5; level++) {
          for (var i = 0; i < 120; i++) {
            if (!chapter.exerciseOnly) {
              for (final n in [3, 4]) {
                final ex = gen.generateChoices(chapter.id, level, n);
                expect(ex.prompt, isNotEmpty);
                checkMath(ex.prompt);
                checkMath(ex.explanation);
                expect(ex.choices.length, n, reason: '${ex.prompt} -> ${ex.choices}');
                expect(ex.choices.toSet().length, n,
                    reason: 'doublon : ${ex.prompt} -> ${ex.choices}');
                expect(ex.choices, contains(ex.answer));
              }
            }
            final ex = gen.generate(chapter.id, level, allowTrueFalse: true);
            expect(ex.answer, isNotEmpty);
            checkMath(ex.prompt);
            switch (ex.type) {
              case ExerciseType.numberLine:
                final g = ex.graph!;
                expect(g.targetTick, inInclusiveRange(0, g.divisions));
              case ExerciseType.grid:
                final g = ex.graph!;
                expect(g.x.abs() <= g.range && g.y.abs() <= g.range, isTrue,
                    reason: 'point hors du repère : ${ex.prompt}');
              case ExerciseType.multipleChoice:
                expect(ex.choices, contains(ex.answer));
              case ExerciseType.input:
                expect(int.tryParse(ex.answer), isNotNull, reason: ex.prompt);
              case ExerciseType.trueFalse:
                expect(['vrai', 'faux'], contains(ex.answer));
            }
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
