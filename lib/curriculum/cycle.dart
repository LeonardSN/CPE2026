import 'dart:math';

import 'package:flutter/material.dart';

/// Une question produite par un chapitre.
class Question {
  /// Texte affiché. Le « ? » marque la réponse à trouver (ex : "7 + 5 = ?").
  final String prompt;

  /// Bonne réponse (nombre entier). Les mauvaises réponses proposées
  /// dans les jeux sont générées automatiquement autour de celle-ci.
  final int answer;

  /// Explication pas à pas, affichée quand l'enfant se trompe.
  final String explanation;

  /// Mettre false si la question n'a pas la forme « ... = ? »
  /// (problèmes rédigés, inconnue au milieu...).
  final bool allowTrueFalse;

  /// Facultatif : réponses proposées imposées (ex : « Quel est le plus
  /// grand ? » -> les nombres à comparer). Doit contenir [answer].
  /// Si null, les mauvaises réponses sont générées automatiquement.
  final List<int>? choices;

  const Question({
    required this.prompt,
    required this.answer,
    required this.explanation,
    this.allowTrueFalse = true,
    this.choices,
  });
}

/// Fabrique une question pour un niveau de difficulté (1 = facile, 5 = difficile).
typedef QuestionMaker = Question Function(int level, Random rng);

/// Un chapitre (= une leçon sur la carte).
class Chapter {
  /// Identifiant UNIQUE dans toute l'app (ex : 'add', 'col_relatifs').
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final Color color;

  /// Monstre affronté dans le mini-jeu « Duel ».
  final String monster;
  final String monsterName;

  /// Fabrique les questions. null uniquement pour le Boss
  /// (qui mélange les autres chapitres du cycle).
  final QuestionMaker? generate;
  final bool isBoss;

  const Chapter({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
    required this.generate,
    this.monster = '👾',
    this.monsterName = 'Monstre',
  }) : isBoss = false;

  /// Le chapitre final d'un cycle : tout mélangé, contre un boss.
  const Chapter.boss({
    required this.id,
    this.monster = '🐲',
    this.monsterName = 'Le Grand Dragon',
    this.title = 'Défi du Boss',
    this.subtitle = 'Tout mélangé !',
    this.emoji = '🏆',
    this.color = const Color(0xFFFF4B4B),
  })  : generate = null,
        isBoss = true;
}

/// Un cycle d'études : primaire, collège, lycée.
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

  /// Un cycle sans chapitre s'affiche « Bientôt disponible ».
  bool get isAvailable => chapters.isNotEmpty;

  /// Tous les chapitres affichés sur la carte, boss compris.
  List<Chapter> get map => [...chapters, boss];
}

/// Une « école » : Primaire, Collège, Lycée.
/// Elle peut contenir plusieurs classes (CP, CE1...) : chacune est un [Cycle]
/// avec sa propre carte. Le collège et le lycée n'ont qu'une seule carte.
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

  /// École à une seule carte (collège, lycée).
  School.single(Cycle cycle)
      : id = cycle.id,
        title = cycle.title,
        subtitle = cycle.subtitle,
        emoji = cycle.emoji,
        color = cycle.color,
        grades = [cycle],
        recommendedGradeId = null;

  bool get isAvailable => grades.any((g) => g.isAvailable);
  bool get hasSeveralGrades => grades.length > 1;
}
