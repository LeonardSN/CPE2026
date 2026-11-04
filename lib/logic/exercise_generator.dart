import 'dart:math';

import '../models/exercise.dart';
import '../models/skill.dart';

/// Génère des exercices à la volée selon la compétence et le niveau (1 à 5).
/// Pas besoin de banque d'exercices : les nombres sont tirés au hasard
/// dans des plages qui correspondent à chaque niveau de difficulté.
class ExerciseGenerator {
  final Random _rng;

  ExerciseGenerator([Random? rng]) : _rng = rng ?? Random();

  T _pick<T>(List<T> list) => list[_rng.nextInt(list.length)];

  Exercise generate(String skillId, int level) {
    level = level.clamp(1, 5);
    return _wrap(skillId, level, _coreFor(skillId, level));
  }

  /// Version « mini-jeu » : toujours un choix parmi [count] réponses
  /// (ballons, fruits, voitures, cartes...).
  Exercise generateChoices(String skillId, int level, int count) {
    level = level.clamp(1, 5);
    final core = _coreFor(skillId, level);
    return Exercise(
      skillId: skillId,
      level: level,
      type: ExerciseType.multipleChoice,
      prompt: core.text,
      answer: '${core.value}',
      choices: _choices(core.value, count, core.preset),
      explanation: core.explanation,
    );
  }

  /// Demande au chapitre (primaire.dart, college.dart, lycee.dart...)
  /// de fabriquer une question du niveau voulu.
  _Core _coreFor(String skillId, int level) {
    final chapter = Skills.byId(skillId);
    final q = chapter.generate!(level, _rng);
    return _Core(q.prompt, q.answer, q.explanation,
        allowTrueFalse: q.allowTrueFalse, preset: q.choices);
  }

  // ---------------------------------------------------------------------
  // Mise en forme : QCM, saisie ou vrai/faux
  // ---------------------------------------------------------------------
  Exercise _wrap(String skillId, int level, _Core core) {
    final roll = _rng.nextDouble();
    ExerciseType type;
    if (roll < 0.5) {
      type = ExerciseType.multipleChoice;
    } else if (roll < 0.8 || !core.allowTrueFalse) {
      type = ExerciseType.input;
    } else {
      type = ExerciseType.trueFalse;
    }
    // Au niveau 1 on évite la saisie libre (trop dur pour les plus petits).
    if (level == 1 && type == ExerciseType.input) {
      type = ExerciseType.multipleChoice;
    }

    switch (type) {
      case ExerciseType.multipleChoice:
        return Exercise(
          skillId: skillId,
          level: level,
          type: type,
          prompt: core.text,
          answer: '${core.value}',
          choices: _choices(core.value, 4, core.preset),
          explanation: core.explanation,
        );
      case ExerciseType.input:
        return Exercise(
          skillId: skillId,
          level: level,
          type: type,
          prompt: core.text,
          answer: '${core.value}',
          explanation: core.explanation,
        );
      case ExerciseType.trueFalse:
        final isTrue = _rng.nextBool();
        final shown = isTrue ? core.value : _wrongValue(core.value);
        final statement = core.text.replaceFirst('?', '$shown');
        return Exercise(
          skillId: skillId,
          level: level,
          type: type,
          prompt: statement,
          answer: isTrue ? 'vrai' : 'faux',
          explanation: isTrue
              ? 'C\'est bien vrai !\n${core.explanation}'
              : 'C\'est faux : la bonne réponse est ${core.value}.\n'
                  '${core.explanation}',
        );
    }
  }

  int _wrongValue(int v) {
    final options = [v + 1, v - 1, v + 2, v + 10, v - 10]
        .where((x) => (v < 0 || x >= 0) && x != v)
        .toList();
    return _pick(options);
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

class _Core {
  final String text;
  final int value;
  final String explanation;
  final bool allowTrueFalse;

  final List<int>? preset;

  _Core(this.text, this.value, this.explanation,
      {this.allowTrueFalse = true, this.preset});
}
