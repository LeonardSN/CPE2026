import 'dart:math';

import 'package:flutter/material.dart';

// =====================================================================
//  MODÈLE DU CONTENU PÉDAGOGIQUE
//  École (cycle) > Classe (carte) > Chapitre > Question
// =====================================================================

/// Placement sur un graphique (mode « Exercices » uniquement).
enum GraphKind { numberLine, grid }

class GraphSpec {
  final GraphKind kind;

  // --- Droite graduée ---
  final double min;
  final double max;

  /// Nombre d'intervalles entre [min] et [max] (ex : 10 graduations).
  final int divisions;

  /// Graduation à trouver (0 = min, divisions = max).
  final int targetTick;

  /// Libellés affichés sous certaines graduations (index -> texte).
  final Map<int, String> labels;

  // --- Repère ---
  /// Le repère va de -range à +range sur les deux axes.
  final int range;
  final int x;
  final int y;

  const GraphSpec.numberLine({
    required this.min,
    required this.max,
    required this.divisions,
    required this.targetTick,
    this.labels = const {},
  })  : kind = GraphKind.numberLine,
        range = 0,
        x = 0,
        y = 0;

  const GraphSpec.grid({required this.range, required this.x, required this.y})
      : kind = GraphKind.grid,
        min = 0,
        max = 0,
        divisions = 0,
        targetTick = 0,
        labels = const {};

  /// Réponse attendue sous forme de texte (comparée à celle de l'élève).
  String get answerKey => kind == GraphKind.numberLine ? '$targetTick' : '$x;$y';
}

/// Une question produite par un chapitre.
///
/// Écriture mathématique dans [prompt], [explanation] et les réponses :
///   \frac{3}{4}  ->  fraction   ·   x^{2} ou x^2  ->  puissance
///   u_{n}        ->  indice     ·   \sqrt{16}     ->  racine carrée
class Question {
  /// Texte affiché. Le « ? » marque la réponse à trouver (ex : "7 + 5 = ?").
  final String prompt;

  /// Bonne réponse (nombre entier, peut être négatif). Les mauvaises
  /// réponses des jeux sont générées automatiquement autour de celle-ci.
  final int answer;

  /// Explication pas à pas, affichée quand l'élève se trompe.
  final String explanation;

  /// Mettre false si la question n'a pas la forme « ... = ? ».
  final bool allowTrueFalse;

  /// Facultatif : réponses numériques proposées (doit contenir [answer]).
  final List<int>? choices;

  /// Facultatif : réponse en TEXTE (fraction, forme, mot...).
  /// Dans ce cas [textChoices] doit contenir la bonne réponse et des pièges,
  /// et la question se joue en QCM (pas de saisie au clavier).
  final String? answerText;
  final List<String>? textChoices;

  /// Facultatif : question à résoudre en plaçant un point sur un graphique.
  final GraphSpec? graph;

  const Question({
    required this.prompt,
    required this.answer,
    required this.explanation,
    this.allowTrueFalse = true,
    this.choices,
    this.answerText,
    this.textChoices,
    this.graph,
  });

  /// Question à réponse texte (QCM).
  const Question.text({
    required this.prompt,
    required String answer,
    required List<String> choices,
    required this.explanation,
  })  : answer = 0,
        answerText = answer,
        textChoices = choices,
        allowTrueFalse = false,
        choices = null,
        graph = null;

  /// Question à placer sur un graphique.
  const Question.graph({
    required this.prompt,
    required GraphSpec this.graph,
    required this.explanation,
  })  : answer = 0,
        answerText = null,
        textChoices = null,
        allowTrueFalse = false,
        choices = null;

  bool get isText => answerText != null;
  bool get isGraph => graph != null;
}

/// Fabrique une question pour un niveau de difficulté (1 = facile, 5 = difficile).
typedef QuestionMaker = Question Function(int level, Random rng);

/// Un chapitre (= une leçon sur la carte).
class Chapter {
  /// Identifiant UNIQUE dans toute l'app (ex : 'ce1_add', 'c4_pyth').
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final Color color;

  /// Monstre affronté dans le mini-jeu « Duel ».
  final String monster;
  final String monsterName;

  /// Fabrique les questions. null pour le Boss et la Révision
  /// (qui mélangent les autres chapitres).
  final QuestionMaker? generate;
  final bool isBoss;
  final bool isReview;

  /// true si le chapitre se fait uniquement en mode « Exercices »
  /// (placement sur une droite graduée ou dans un repère).
  final bool exerciseOnly;

  const Chapter({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
    required this.generate,
    this.monster = '👾',
    this.monsterName = 'Monstre',
    this.exerciseOnly = false,
  })  : isBoss = false,
        isReview = false;

  /// Le chapitre final d'une classe : tout mélangé, contre un boss.
  const Chapter.boss({
    required this.id,
    this.monster = '🐲',
    this.monsterName = 'Le Grand Dragon',
    this.title = 'Défi du Boss',
    this.subtitle = 'Tout mélangé !',
    this.emoji = '🏆',
    this.color = const Color(0xFFFF4B4B),
  })  : generate = null,
        isBoss = true,
        isReview = false,
        exerciseOnly = false;

  /// Révision express : cible les points faibles et ce qui n'a pas été revu.
  const Chapter.review({required this.id})
      : title = 'Révision express',
        subtitle = 'Tes points faibles en priorité',
        emoji = '🔁',
        color = const Color(0xFF2A5C96),
        monster = '🧠',
        monsterName = 'Le Cerveau Oublieux',
        generate = null,
        isBoss = true,
        isReview = true,
        exerciseOnly = false;
}

/// Une classe (PS, CE1, 5e, Terminale...) = une carte de chapitres.
class Cycle {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final Color color;
  final List<Chapter> chapters;
  final Chapter boss;

  const Cycle({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
    required this.chapters,
    required this.boss,
  });

  /// Une classe sans chapitre s'affiche « Bientôt disponible ».
  bool get isAvailable => chapters.isNotEmpty;

  /// Tous les chapitres affichés sur la carte, boss compris.
  List<Chapter> get map => [...chapters, boss];

  /// Chapitre « Révision » propre à cette classe.
  Chapter get review => Chapter.review(id: 'review_$id');
}

/// Un cycle d'études officiel : Cycle 1, 2, 3, 4, Lycée.
/// Il contient plusieurs classes ; chacune a sa propre carte.
/// Le thème visuel de l'app change selon le cycle.
class School {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final Color color;
  final List<Cycle> grades;

  /// Classe mise en avant (ex : CE1).
  final String? recommendedGradeId;

  const School({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
    required this.grades,
    this.recommendedGradeId,
  });

  bool get isAvailable => grades.any((g) => g.isAvailable);
  bool get hasSeveralGrades => grades.length > 1;
}
