import 'dart:math';

import 'package:flutter/material.dart';

import 'cycle.dart';

// =====================================================================
//  📐 COLLÈGE  —  à compléter par l'équipe Collège
//
//  Comment ajouter un chapitre :
//   1. Copier le modèle ci-dessous dans la liste `chapters`.
//   2. Donner un id UNIQUE (ex : 'col_xxx').
//   3. Écrire la fonction qui fabrique une question selon le niveau
//      (1 = facile ... 5 = difficile). La réponse est un nombre entier.
//   4. Sauvegarder : le chapitre apparaît sur la carte, dans les
//      4 mini-jeux et dans l'espace parent. Rien d'autre à toucher !
//
//  Modèle :
//
//    Chapter(
//      id: 'col_exemple',
//      title: 'Titre du chapitre',
//      subtitle: 'Petite description',
//      emoji: '⭐',
//      color: const Color(0xFF1CB0F6),
//      monster: '👾',              // monstre du mini-jeu Duel
//      monsterName: 'Nom du monstre',
//      generate: _exemple,
//    ),
//
//    Question _exemple(int level, Random rng) {
//      final a = 1 + rng.nextInt(10 * level);
//      final b = 1 + rng.nextInt(10 * level);
//      return Question(
//        prompt: '$a + $b = ?',
//        answer: a + b,
//        explanation: 'On additionne : $a + $b = ${a + b}.',
//      );
//    }
//
//  Voir lib/curriculum/primaire.dart pour des exemples complets.
// =====================================================================

final college = Cycle(
  id: 'college',
  title: 'Collège',
  subtitle: '6e → 3e',
  emoji: '📐',
  color: const Color(0xFF1CB0F6),
  chapters: [
    // ➕ Ajouter les chapitres ici
  ],
  boss: const Chapter.boss(
      id: 'boss_col', monster: '🦑', monsterName: 'Le Kraken des Maths'),
);

// Les fonctions qui fabriquent les questions vont en dessous.
// (`Random` sert à tirer des nombres au hasard : rng.nextInt(10) -> 0..9)
// ignore: unused_element
int _rnd(Random rng, int a, int b) => a + rng.nextInt(b - a + 1);
