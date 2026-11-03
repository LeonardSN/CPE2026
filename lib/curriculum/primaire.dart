import 'dart:math';

import 'package:flutter/material.dart';

import 'cycle.dart';

// =====================================================================
//  🎒 PRIMAIRE (CE1 - CE2)
//  Chaque chapitre = une fonction (niveau 1..5, hasard) -> Question.
// =====================================================================

final primaire = Cycle(
  id: 'primaire',
  title: 'Primaire',
  subtitle: 'CE1 · CE2',
  emoji: '🎒',
  color: const Color(0xFF58CC02),
  chapters: [
    Chapter(
      id: 'add',
      title: 'Additions',
      subtitle: 'Ajouter des nombres',
      emoji: '➕',
      color: const Color(0xFF58CC02),
      monster: '👾',
      monsterName: 'Additor',
      generate: _Primaire.addition,
    ),
    Chapter(
      id: 'sub',
      title: 'Soustractions',
      subtitle: 'Enlever, retirer',
      emoji: '➖',
      color: const Color(0xFF1CB0F6),
      monster: '🐙',
      monsterName: 'Soustracto',
      generate: _Primaire.subtraction,
    ),
    Chapter(
      id: 'mul',
      title: 'Tables de multiplication',
      subtitle: 'De 2 à 10',
      emoji: '✖️',
      color: const Color(0xFFFF9600),
      monster: '🦖',
      monsterName: 'Multisaure',
      generate: _Primaire.multiplication,
    ),
    Chapter(
      id: 'pb',
      title: 'Petits problèmes',
      subtitle: 'Les maths de la vie',
      emoji: '🧩',
      color: const Color(0xFFCE82FF),
      monster: '👻',
      monsterName: 'Problémo',
      generate: _Primaire.problem,
    ),
  ],
  boss: Chapter.boss(id: 'boss', monster: '🐲', monsterName: 'Le Grand Dragon'),
);

Question _q(String prompt, int answer, String explanation,
        {bool allowTrueFalse = true}) =>
    Question(
      prompt: prompt,
      answer: answer,
      explanation: explanation,
      allowTrueFalse: allowTrueFalse,
    );

class _Primaire {
  // ---------------------------------------------------------------------
  // Additions
  // ---------------------------------------------------------------------
  static Question addition(int level, Random rng) {
    int rnd(int a, int b) => a + rng.nextInt(b - a + 1);
    late int a, b;
    switch (level) {
      case 1: // résultat <= 10
        a = rnd(1, 9);
        b = rnd(1, 10 - a);
        break;
      case 2: // passage de la dizaine (ex : 8 + 5)
        a = rnd(2, 9);
        b = rnd(11 - a, 9);
        break;
      case 3: // deux chiffres sans retenue
        do {
          a = rnd(10, 79);
          b = rnd(10, 99 - a);
        } while (a % 10 + b % 10 >= 10);
        break;
      case 4: // deux chiffres avec retenue
        do {
          a = rnd(15, 79);
          b = rnd(11, 99 - a);
        } while (a % 10 + b % 10 < 10);
        break;
      default: // trois chiffres + deux chiffres
        a = rnd(100, 880);
        b = rnd(11, 99);
    }
    final s = a + b;
    String expl;
    if (b < 10) {
      final toTen = 10 - a % 10;
      if (a < 10 && b > toTen) {
        expl = 'Astuce : complète jusqu\'à 10 !\n'
            '$a + $toTen = 10, puis 10 + ${b - toTen} = $s.';
      } else {
        expl = 'Compte sur tes doigts à partir de $a : '
            'tu avances de $b et tu arrives à $s.';
      }
    } else {
      final d = (b ~/ 10) * 10, u = b % 10;
      expl = 'Décompose $b en $d + $u.\n'
          'D\'abord les dizaines : $a + $d = ${a + d}.\n'
          '${u > 0 ? 'Puis les unités : ${a + d} + $u = $s.' : 'Résultat : $s.'}';
    }
    return _q('$a + $b = ?', s, expl);
  }

  // ---------------------------------------------------------------------
  // Soustractions
  // ---------------------------------------------------------------------
  static Question subtraction(int level, Random rng) {
    int rnd(int a, int b) => a + rng.nextInt(b - a + 1);
    late int a, b;
    switch (level) {
      case 1:
        a = rnd(2, 10);
        b = rnd(1, a);
        break;
      case 2: // passage de la dizaine (ex : 13 - 5)
        a = rnd(11, 18);
        b = rnd(a - 9, 9);
        if (b <= a - 10) b = a - 9;
        break;
      case 3: // deux chiffres sans retenue
        do {
          a = rnd(25, 99);
          b = rnd(10, a - 1);
        } while (b % 10 > a % 10);
        break;
      case 4: // deux chiffres avec retenue
        do {
          a = rnd(30, 99);
          b = rnd(11, a - 1);
        } while (b % 10 <= a % 10);
        break;
      default:
        a = rnd(120, 999);
        b = rnd(11, 99);
    }
    final r = a - b;
    String expl;
    if (b < 10) {
      final toTen = a - 10;
      if (a > 10 && b > toTen && toTen > 0) {
        expl = 'Astuce : redescends d\'abord à 10 !\n'
            '$a − $toTen = 10, puis 10 − ${b - toTen} = $r.';
      } else {
        expl = 'Pars de $a et recule de $b : tu arrives à $r.';
      }
    } else {
      final d = (b ~/ 10) * 10, u = b % 10;
      expl = 'Décompose $b en $d + $u.\n'
          'Enlève d\'abord les dizaines : $a − $d = ${a - d}.\n'
          '${u > 0 ? 'Puis les unités : ${a - d} − $u = $r.' : 'Résultat : $r.'}';
    }
    expl += '\nVérifie : $r + $b = $a ✔';
    return _q('$a − $b = ?', r, expl);
  }

  // ---------------------------------------------------------------------
  // Tables de multiplication
  // ---------------------------------------------------------------------
  static Question multiplication(int level, Random rng) {
    int rnd(int a, int b) => a + rng.nextInt(b - a + 1);
    T pick<T>(List<T> l) => l[rng.nextInt(l.length)];
    final tables = switch (level) {
      1 => [2, 5, 10],
      2 => [3, 4],
      3 => [6, 7],
      4 => [8, 9],
      _ => [3, 4, 6, 7, 8, 9],
    };
    final t = pick(tables);
    final f = rnd(2, 10);
    final p = t * f;

    String expl;
    if (f == 10) {
      expl = 'Multiplier par 10, c\'est ajouter un zéro : $t × 10 = $p.';
    } else if (f <= 5) {
      expl = '$t × $f, c\'est $t ajouté $f fois :\n'
          '${List.filled(f, '$t').join(' + ')} = $p.';
    } else {
      expl = 'Coupe en deux : $t × $f = ($t × 5) + ($t × ${f - 5})\n'
          '= ${t * 5} + ${t * (f - 5)} = $p.';
    }

    if (level == 5 && rng.nextBool()) {
      // facteur manquant : 7 × ? = 56
      return _q('$t × ? = $p', f,
          'Cherche dans la table de $t : $t × $f = $p.\nLa réponse est $f.',
          allowTrueFalse: false);
    }
    return _q('$t × $f = ?', p, expl);
  }

  // ---------------------------------------------------------------------
  // Petits problèmes
  // ---------------------------------------------------------------------
  static const _names = [
    ('Awa', 'elle'),
    ('Lucas', 'il'),
    ('Fatou', 'elle'),
    ('Léo', 'il'),
    ('Inès', 'elle'),
    ('Moussa', 'il'),
  ];
  static const _objects = ['billes', 'bonbons', 'mangues', 'crayons', 'images'];

  static Question problem(int level, Random rng) {
    int rnd(int a, int b) => a + rng.nextInt(b - a + 1);
    T pick<T>(List<T> l) => l[rng.nextInt(l.length)];
    final (name, pron) = pick(_names);
    final obj = pick(_objects);
    final kinds = level >= 4 ? ['add', 'sub', 'mul'] : ['add', 'sub'];
    final kind = pick(kinds);

    if (kind == 'mul') {
      final n = rnd(2, level == 5 ? 9 : 5);
      final k = rnd(2, level == 5 ? 9 : 6);
      return _q(
        '$name achète $n paquets de $k $obj.\nCombien de $obj en tout ?',
        n * k,
        '$n paquets de $k, c\'est $n fois $k :\n$n × $k = ${n * k} $obj.',
        allowTrueFalse: false,
      );
    }

    final (int a, int b) = switch (level) {
      1 => (rnd(3, 9), rnd(1, 3)),
      2 => (rnd(10, 20), rnd(3, 9)),
      3 => (rnd(20, 60), rnd(10, 19)),
      4 => (rnd(40, 90), rnd(11, 39)),
      _ => (rnd(100, 500), rnd(20, 99)),
    };

    if (kind == 'add') {
      return _q(
        '$name a $a $obj. On lui en donne $b.\n'
            'Combien en a-t-$pron maintenant ?',
        a + b,
        'On lui en DONNE : ça augmente, donc on fait une addition.\n'
            '$a + $b = ${a + b} $obj.',
        allowTrueFalse: false,
      );
    }
    final pronCap = pron[0].toUpperCase() + pron.substring(1);
    return _q(
      '$name a $a $obj. $pronCap en donne $b à son ami.\n'
          'Combien lui en reste-t-il ?',
      a - b,
      '$pronCap en DONNE : ça diminue, donc on fait une soustraction.\n'
          '$a − $b = ${a - b} $obj.',
      allowTrueFalse: false,
    );
  }

}
