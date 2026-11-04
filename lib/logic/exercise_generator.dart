import 'dart:math';

import '../models/exercise.dart';
import '../models/skill.dart';

/// Transforme les questions des chapitres en exercices affichables :
/// - generateChoices : pour les mini-jeux (toujours un choix parmi N)
/// - generate        : pour le mode Exercices (case à remplir, QCM, graphique)
class ExerciseGenerator {
  final Random _rng;

  ExerciseGenerator([Random? rng]) : _rng = rng ?? Random();

  T _pick<T>(List<T> list) => list[_rng.nextInt(list.length)];

  Question _question(String skillId, int level) {
    final chapter = Skills.byId(skillId);
    return chapter.generate!(level.clamp(1, 5), _rng);
  }

  /// Version « mini-jeu » : un choix parmi [count] réponses
  /// (ballons, fruits, voitures, cartes...).
  Exercise generateChoices(String skillId, int level, int count) {
    level = level.clamp(1, 5);
    var q = _question(skillId, level);
    // Les questions à graphique ne se jouent pas en mini-jeu.
    for (var i = 0; i < 5 && q.isGraph; i++) {
      q = _question(skillId, level);
    }
    return Exercise(
      skillId: skillId,
      level: level,
      type: ExerciseType.multipleChoice,
      prompt: q.prompt,
      answer: q.isText ? q.answerText! : '${q.answer}',
      choices: q.isText
          ? _textChoices(q.answerText!, q.textChoices!, count)
          : _choices(q.answer, count, q.choices),
      explanation: q.explanation,
    );
  }

  /// Version « Exercices » (façon Mathraining) : on écrit sa réponse dans
  /// une case, ou on place un point sur un graphique.
  Exercise generate(String skillId, int level, {bool allowTrueFalse = false}) {
    level = level.clamp(1, 5);
    final q = _question(skillId, level);

    if (q.isGraph) {
      return Exercise(
        skillId: skillId,
        level: level,
        type: q.graph!.kind == GraphKind.numberLine
            ? ExerciseType.numberLine
            : ExerciseType.grid,
        prompt: q.prompt,
        answer: q.graph!.answerKey,
        explanation: q.explanation,
        graph: q.graph,
      );
    }
    if (q.isText) {
      return Exercise(
        skillId: skillId,
        level: level,
        type: ExerciseType.multipleChoice,
        prompt: q.prompt,
        answer: q.answerText!,
        choices: _textChoices(q.answerText!, q.textChoices!, 4),
        explanation: q.explanation,
      );
    }

    // Réponse numérique : surtout la case à remplir, un peu de QCM
    // (plus de QCM au niveau 1, pour les plus jeunes).
    final roll = _rng.nextDouble();
    final qcmShare = level == 1 ? 0.6 : 0.25;
    if (allowTrueFalse && q.allowTrueFalse && roll > 0.9) {
      final isTrue = _rng.nextBool();
      final shown = isTrue ? q.answer : _wrongValue(q.answer);
      return Exercise(
        skillId: skillId,
        level: level,
        type: ExerciseType.trueFalse,
        prompt: q.prompt.replaceFirst('?', '$shown'),
        answer: isTrue ? 'vrai' : 'faux',
        explanation: isTrue
            ? 'C\'est bien vrai !\n${q.explanation}'
            : 'C\'est faux : la bonne réponse est ${q.answer}.\n${q.explanation}',
      );
    }
    if (roll < qcmShare) {
      return Exercise(
        skillId: skillId,
        level: level,
        type: ExerciseType.multipleChoice,
        prompt: q.prompt,
        answer: '${q.answer}',
        choices: _choices(q.answer, 4, q.choices),
        explanation: q.explanation,
      );
    }
    return Exercise(
      skillId: skillId,
      level: level,
      type: ExerciseType.input,
      prompt: q.prompt,
      answer: '${q.answer}',
      explanation: q.explanation,
    );
  }

  int _wrongValue(int v) {
    final options = [v + 1, v - 1, v + 2, v + 10, v - 10]
        .where((x) => (v < 0 || x >= 0) && x != v)
        .toList();
    return _pick(options);
  }

  List<String> _textChoices(String answer, List<String> pool, int count) {
    final others = pool.where((x) => x != answer).toSet().toList()..shuffle(_rng);
    final list = [answer, ...others.take(count - 1)]..shuffle(_rng);
    return list;
  }

  List<String> _choices(int v, [int count = 4, List<int>? preset]) {
    if (preset != null) {
      // Réponses imposées par le chapitre : on garde la bonne + des autres.
      final others = preset.where((x) => x != v).toSet().toList()..shuffle(_rng);
      final list = <int>[v, ...others.take(count - 1)];
      // On complète si le chapitre n'en a pas fourni assez.
      for (final x in [v + 1, v + 2, v + 10, v - 1, v + 3, v + 4]) {
        if (list.length >= count) break;
        if (!list.contains(x) && (v < 0 || x >= 0)) list.add(x);
      }
      list.shuffle(_rng);
      return list.map((e) => '$e').toList();
    }
    final candidates = {v + 1, v - 1, v + 2, v - 2, v + 10, v - 10, -v}
        .where((x) => (v < 0 || x >= 0) && x != v)
        .toList()
      ..shuffle(_rng);
    final list = [v, ...candidates.take(count - 1)]..shuffle(_rng);
    return list.map((e) => '$e').toList();
  }
}
