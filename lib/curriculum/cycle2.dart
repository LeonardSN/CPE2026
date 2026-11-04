import 'dart:math';

import 'package:flutter/material.dart';

import 'cycle.dart';
import 'helpers.dart';

// =====================================================================
//  CYCLE 2 : CP, CE1, CE2  (programme du cycle 2)
//  Nombres et calcul, fractions (dès le CE1), grandeurs et mesures,
//  espace et géométrie.
// =====================================================================

final cycle2 = School(
  id: 'cycle2',
  title: 'Cycle 2',
  subtitle: 'CP · CE1 · CE2',
  emoji: '🎒',
  color: Color(0xFFFF8C38),
  grades: [cp, ce1, ce2],
  recommendedGradeId: 'ce1',
);

// Couleurs réutilisées
const _green = Color(0xFF58CC02);
const _blue = Color(0xFF2A5C96);
const _orange = Color(0xFFFF8C38);
const _purple = Color(0xFFCE82FF);
const _red = Color(0xFFFF4B4B);
const _gold = Color(0xFFFFC800);
const _teal = Color(0xFF00C2A8);

final cp = Cycle(
  id: 'cp',
  title: 'CP',
  subtitle: 'Compter, ajouter, enlever jusqu\'à 20',
  emoji: '🐣',
  color: _gold,
  chapters: [
    Chapter(
      id: 'cp_count', title: 'Compter', subtitle: 'Combien y en a-t-il ?',
      emoji: '🍎', color: _red, monster: '🐛', monsterName: 'Chenille Gourmande',
      generate: _cpCount,
    ),
    Chapter(
      id: 'cp_cmp', title: 'Le plus grand', subtitle: 'Comparer des nombres',
      emoji: '🐘', color: _blue, monster: '🐭', monsterName: 'Petite Souris',
      generate: _cpCompare,
    ),
    Chapter(
      id: 'cp_add', title: 'Additions', subtitle: 'Ajouter jusqu\'à 20',
      emoji: '➕', color: _green, monster: '🐸', monsterName: 'Grenouille Plus',
      generate: (l, r) => additionQ(r, switch (l) {
        1 => AddSpec(1, 4, 1, 4, maxSum: 5),
        2 => AddSpec(1, 9, 1, 9, maxSum: 10),
        3 => AddSpec(5, 9, 2, 9, minSum: 11, maxSum: 15),
        4 => AddSpec(3, 9, 3, 9, minSum: 11, maxSum: 18),
        _ => AddSpec(10, 15, 2, 5, maxSum: 20),
      }),
    ),
    Chapter(
      id: 'cp_sub', title: 'Soustractions', subtitle: 'Enlever jusqu\'à 20',
      emoji: '➖', color: _orange, monster: '🦊', monsterName: 'Renard Moins',
      generate: (l, r) => subtractionQ(r, switch (l) {
        1 => SubSpec(2, 5, 1, 4),
        2 => SubSpec(5, 10, 1, 9),
        3 => SubSpec(11, 19, 1, 9, borrow: false),
        4 => SubSpec(11, 18, 2, 9, borrow: true),
        _ => SubSpec(15, 20, 3, 12),
      }),
    ),
    Chapter(
      id: 'cp_c10', title: 'Faire 10', subtitle: 'Compléments à 10 et à 20',
      emoji: '🔟', color: _purple, monster: '🐙', monsterName: 'Poulpe Dix-Bras',
      generate: _cpComplements,
    ),
    Chapter(
      id: 'cp_line', title: 'La droite graduée', subtitle: 'Placer un nombre',
      emoji: '📏', color: _teal, monster: '🐌', monsterName: 'Escargot Rapide',
      generate: (l, r) => numberLineQ(r, l <= 2 ? 10 : 20, 1, maxLevelBig: l >= 4),
      exerciseOnly: true,
    ),
    Chapter(
      id: 'cp_shape', title: 'Les formes', subtitle: 'Carré, triangle, rond',
      emoji: '🔺', color: _purple, monster: '🧊', monsterName: 'Cube Rigolo',
      generate: _cpShapes,
    ),
  ],
  boss: const Chapter.boss(id: 'boss_cp', monster: '🐲', monsterName: 'Bébé Dragon'),
);

final ce1 = Cycle(
  id: 'ce1',
  title: 'CE1',
  subtitle: 'Nombres jusqu\'à 1000, tables, monnaie',
  emoji: '🎒',
  color: _green,
  chapters: [
    Chapter(
      id: 'ce1_num', title: 'Nombres jusqu\'à 1000', subtitle: 'Centaines, dizaines, unités',
      emoji: '🧱', color: _blue, monster: '🧌', monsterName: 'Troll des Centaines',
      generate: _ce1Numbers,
    ),
    Chapter(
      id: 'ce1_add', title: 'Additions', subtitle: 'Avec et sans retenue',
      emoji: '➕', color: _green, monster: '👾', monsterName: 'Additor',
      generate: (l, r) => additionQ(r, switch (l) {
        1 => AddSpec(10, 89, 1, 9, carry: false),
        2 => AddSpec(15, 89, 2, 9, carry: true),
        3 => AddSpec(10, 79, 10, 49, carry: false),
        4 => AddSpec(15, 79, 11, 49, carry: true),
        _ => AddSpec(100, 899, 11, 99),
      }),
    ),
    Chapter(
      id: 'ce1_sub', title: 'Soustractions', subtitle: 'Avec et sans retenue',
      emoji: '➖', color: _orange, monster: '🐙', monsterName: 'Soustracto',
      generate: (l, r) => subtractionQ(r, switch (l) {
        1 => SubSpec(20, 99, 1, 9, borrow: false),
        2 => SubSpec(20, 99, 2, 9, borrow: true),
        3 => SubSpec(30, 99, 10, 60, borrow: false),
        4 => SubSpec(30, 99, 11, 60, borrow: true),
        _ => SubSpec(120, 999, 11, 99),
      }),
    ),
    Chapter(
      id: 'ce1_mul', title: 'Tables 2, 3, 4, 5, 10', subtitle: 'Les premières tables',
      emoji: '✖️', color: _purple, monster: '🦖', monsterName: 'Multisaure',
      generate: (l, r) => tableQ(r, switch (l) {
        1 => [2, 10],
        2 => [5],
        3 => [3],
        4 => [4],
        _ => [2, 3, 4, 5, 10],
      }, missingFactor: l == 5),
    ),
    Chapter(
      id: 'ce1_dbl', title: 'Doubles et moitiés', subtitle: 'Calcul mental',
      emoji: '👯', color: _teal, monster: '👥', monsterName: 'Les Jumeaux',
      generate: _ce1Doubles,
    ),
    Chapter(
      id: 'ce1_money', title: 'La monnaie', subtitle: 'Compter les euros',
      emoji: '💶', color: _gold, monster: '🦝', monsterName: 'Raton Voleur',
      generate: _ce1Money,
    ),
    Chapter(
      id: 'ce1_pb', title: 'Petits problèmes', subtitle: 'Les maths de la vie',
      emoji: '🧩', color: _red, monster: '👻', monsterName: 'Problémo',
      generate: (l, r) => problemQ(r, l, grade: 1),
    ),
    Chapter(
      id: 'ce1_frac', title: 'Les fractions', subtitle: 'Parts d\'un tout',
      emoji: '🍕', color: _orange, monster: '🍕', monsterName: 'Pizzator',
      generate: (l, r) => fractionOfWholeQ(r, l, [2, 3, 4, 5, 6, 8, 10]),
    ),
    Chapter(
      id: 'ce1_line', title: 'La droite graduée', subtitle: 'Jusqu\'à 1000',
      emoji: '📏', color: _teal, monster: '🐌', monsterName: 'Escargot Rapide',
      generate: (l, r) => numberLineQ(r, l <= 2 ? 100 : 1000, l <= 2 ? 10 : 100,
          maxLevelBig: l >= 4),
      exerciseOnly: true,
    ),
    Chapter(
      id: 'ce1_time', title: 'L\'heure et les durées', subtitle: 'Heures, minutes',
      emoji: '⏰', color: _blue, monster: '🦉', monsterName: 'Hibou du Temps',
      generate: _ce1Time,
    ),
    Chapter(
      id: 'ce1_len', title: 'Les longueurs', subtitle: 'm, cm',
      emoji: '📐', color: _green, monster: '🦒', monsterName: 'Girafe Géante',
      generate: _ce1Lengths,
    ),
  ],
  boss: const Chapter.boss(id: 'boss_ce1', monster: '🐲', monsterName: 'Le Grand Dragon'),
);

final ce2 = Cycle(
  id: 'ce2',
  title: 'CE2',
  subtitle: 'Toutes les tables, partages',
  emoji: '🎒',
  color: _blue,
  chapters: [
    Chapter(
      id: 'ce2_add', title: 'Additions', subtitle: 'Nombres à 3 chiffres',
      emoji: '➕', color: _green, monster: '👾', monsterName: 'Additor Géant',
      generate: (l, r) => additionQ(r, switch (l) {
        1 => AddSpec(100, 800, 10, 99, carry: false),
        2 => AddSpec(100, 800, 11, 99, carry: true),
        3 => AddSpec(100, 500, 100, 400, carry: false),
        4 => AddSpec(100, 600, 100, 399, carry: true),
        _ => AddSpec(300, 999, 200, 999),
      }),
    ),
    Chapter(
      id: 'ce2_sub', title: 'Soustractions', subtitle: 'Nombres à 3 chiffres',
      emoji: '➖', color: _orange, monster: '🐙', monsterName: 'Soustracto Géant',
      generate: (l, r) => subtractionQ(r, switch (l) {
        1 => SubSpec(120, 999, 11, 99, borrow: false),
        2 => SubSpec(120, 999, 11, 99, borrow: true),
        3 => SubSpec(300, 999, 100, 299, borrow: false),
        4 => SubSpec(300, 999, 100, 299, borrow: true),
        _ => SubSpec(500, 999, 150, 499),
      }),
    ),
    Chapter(
      id: 'ce2_mul', title: 'Toutes les tables', subtitle: 'De 2 à 9',
      emoji: '✖️', color: _purple, monster: '🦖', monsterName: 'Multisaure',
      generate: (l, r) => tableQ(r, switch (l) {
        1 => [2, 5, 10],
        2 => [3, 4],
        3 => [6, 7],
        4 => [8, 9],
        _ => [3, 4, 6, 7, 8, 9],
      }, missingFactor: l == 5),
    ),
    Chapter(
      id: 'ce2_mulp', title: 'Multiplier', subtitle: '× 10, × 100, 2 chiffres',
      emoji: '🚀', color: _blue, monster: '🤖', monsterName: 'Robot Fois',
      generate: _ce2Multiply,
    ),
    Chapter(
      id: 'ce2_div', title: 'Partager', subtitle: 'Premières divisions',
      emoji: '🍰', color: _teal, monster: '🍰', monsterName: 'Gâteau Géant',
      generate: _ce2Divide,
    ),
    Chapter(
      id: 'ce2_pb', title: 'Problèmes', subtitle: 'Les maths de la vie',
      emoji: '🧩', color: _red, monster: '👻', monsterName: 'Problémo',
      generate: (l, r) => problemQ(r, l, grade: 2),
    ),
    Chapter(
      id: 'ce2_frac', title: 'Fractions égales', subtitle: 'Une moitié = deux quarts',
      emoji: '🍫', color: _orange, monster: '🍫', monsterName: 'Chocolatus',
      generate: _ce2Fractions,
    ),
    Chapter(
      id: 'ce2_mes', title: 'Masses et contenances', subtitle: 'g, kg, L, cL',
      emoji: '⚖️', color: _green, monster: '🐘', monsterName: 'Éléphant Pesant',
      generate: _ce2Measures,
    ),
  ],
  boss: const Chapter.boss(id: 'boss_ce2', monster: '🐲', monsterName: 'Le Dragon de Feu'),
);

// =====================================================================
//  GÉNÉRATEURS
// =====================================================================
// ---------------- CP ----------------
Question _cpCount(int level, Random rng) {
  final n = switch (level) {
    1 => rnd(rng, 1, 5),
    2 => rnd(rng, 3, 8),
    3 => rnd(rng, 6, 10),
    4 => rnd(rng, 9, 14),
    _ => rnd(rng, 12, 20),
  };
  final e = pick(rng, ['🍎', '⭐', '🐟', '🌸', '🚗', '🎈']);
  // groupes de 5 pour que ce soit lisible
  final groups = <String>[];
  for (var i = 0; i < n; i += 5) {
    groups.add(List.filled(min(5, n - i), e).join());
  }
  return Question(
    prompt: 'Combien de $e ?\n${groups.join(' ')}',
    answer: n,
    explanation: n > 5
        ? 'Les $e sont rangés par paquets de 5. '
            '${n ~/ 5} paquet(s) de 5 = ${(n ~/ 5) * 5}, plus ${n % 5} : il y en a $n.'
        : 'Compte-les un par un en touchant chaque $e : il y en a $n.',
    allowTrueFalse: false,
  );
}

Question _cpCompare(int level, Random rng) {
  final maxN = switch (level) { 1 => 10, 2 => 20, 3 => 50, 4 => 99, _ => 99 };
  final nums = <int>{};
  if (level >= 4) {
    // pièges : 47 et 74
    final d = rnd(rng, 1, 8), u = rnd(rng, d + 1, 9);
    nums.addAll([d * 10 + u, u * 10 + d]);
  }
  while (nums.length < 4) {
    nums.add(rnd(rng, 0, maxN));
  }
  final list = nums.toList()..shuffle(rng);
  final big = list.reduce(max);
  return Question(
    prompt: 'Quel est le plus grand nombre ?',
    answer: big,
    choices: list,
    explanation: big >= 10
        ? 'On compare d\'abord les dizaines : celui qui en a le plus est le plus grand. '
            'Ici, c\'est $big.'
        : 'Sur la file des nombres, le plus grand est le plus à droite : $big.',
    allowTrueFalse: false,
  );
}

Question _cpComplements(int level, Random rng) {
  final (int target, int a) = switch (level) {
    1 => (5, rnd(rng, 0, 5)),
    2 => (10, rnd(rng, 1, 9)),
    3 => (10, rnd(rng, 0, 10)),
    4 => (20, rnd(rng, 10, 19)),
    _ => (20, rnd(rng, 2, 18)),
  };
  final r = target - a;
  return Question(
    prompt: '$a + ? = $target',
    answer: r,
    explanation: 'Pour aller de $a à $target, il manque $r : $a + $r = $target.\n'
        '(C\'est aussi $target − $a = $r.)',
    allowTrueFalse: false,
  );
}

// ---------------- CE1 ----------------
Question _ce1Numbers(int level, Random rng) {
  switch (level) {
    case 1: {
      final d = rnd(rng, 1, 9), u = rnd(rng, 0, 9);
      return Question(
        prompt: '$d dizaines et $u unités = ?',
        answer: d * 10 + u,
        explanation: '$d dizaines = ${d * 10}, plus $u unités : ${d * 10} + $u = ${d * 10 + u}.',
        allowTrueFalse: false,
      );
    }
    case 2: {
      final d = rnd(rng, 1, 9), u = rnd(rng, 1, 9);
      return Question(
        prompt: '$u unités et $d dizaines = ?',
        answer: d * 10 + u,
        explanation: 'Attention à l\'ordre ! Les dizaines s\'écrivent à gauche :\n'
            '$d dizaines = ${d * 10}, + $u unités = ${d * 10 + u}.',
        allowTrueFalse: false,
      );
    }
    case 3: {
      final c = rnd(rng, 1, 9), d = rnd(rng, 0, 9), u = rnd(rng, 0, 9);
      final n = c * 100 + d * 10 + u;
      return Question(
        prompt: '$c centaines, $d dizaines\net $u unités = ?',
        answer: n,
        explanation: '${c * 100} + ${d * 10} + $u = $n.\n'
            '(centaines | dizaines | unités : $c | $d | $u)',
        allowTrueFalse: false,
      );
    }
    case 4: {
      final c = rnd(rng, 1, 9), u = rnd(rng, 1, 9);
      final n = c * 100 + u;
      return Question(
        prompt: '$c centaines et $u unités = ?',
        answer: n,
        explanation: 'Il n\'y a pas de dizaines : on écrit un 0 au milieu !\n'
            '${c * 100} + $u = $n.',
        allowTrueFalse: false,
      );
    }
    default: {
      final n = rnd(rng, 11, 99) * 10;
      return Question(
        prompt: 'Combien de dizaines\ndans $n ?',
        answer: n ~/ 10,
        explanation: '$n = ${n ~/ 10} × 10. Il y a donc ${n ~/ 10} dizaines '
            '(on cache le chiffre des unités).',
        allowTrueFalse: false,
      );
    }
  }
}

Question _ce1Doubles(int level, Random rng) {
  switch (level) {
    case 1: {
      final n = rnd(rng, 1, 5);
      return Question(
        prompt: 'Le double de $n = ?',
        answer: 2 * n,
        explanation: 'Le double, c\'est le nombre ajouté à lui-même : $n + $n = ${2 * n}.',
      );
    }
    case 2: {
      final n = rnd(rng, 6, 10);
      return Question(
        prompt: 'Le double de $n = ?',
        answer: 2 * n,
        explanation: '$n + $n = ${2 * n}.',
      );
    }
    case 3: {
      final n = rnd(rng, 1, 10) * 2;
      return Question(
        prompt: 'La moitié de $n = ?',
        answer: n ~/ 2,
        explanation: 'La moitié, c\'est partager en 2 parts égales : '
            '${n ~/ 2} + ${n ~/ 2} = $n, donc la moitié de $n est ${n ~/ 2}.',
      );
    }
    case 4: {
      final n = rnd(rng, 11, 45);
      final d = (n ~/ 10) * 10, u = n % 10;
      return Question(
        prompt: 'Le double de $n = ?',
        answer: 2 * n,
        explanation: 'Double des dizaines + double des unités :\n'
            '$d + $d = ${2 * d} et $u + $u = ${2 * u}, donc ${2 * n}.',
      );
    }
    default: {
      final n = rnd(rng, 6, 50) * 2;
      return Question(
        prompt: 'La moitié de $n = ?',
        answer: n ~/ 2,
        explanation: 'Vérifie avec le double : ${n ~/ 2} + ${n ~/ 2} = $n.\n'
            'La moitié de $n est donc ${n ~/ 2}.',
      );
    }
  }
}

Question _ce1Money(int level, Random rng) {
  if (level == 5) {
    final price = rnd(rng, 3, 18);
    final paid = price <= 5 ? 5 : (price <= 10 ? 10 : 20);
    final item = pick(rng, ['un jouet', 'un livre', 'un ballon', 'une glace', 'un stylo']);
    return Question(
      prompt: 'J\'achète $item à $price €.\nJe paie avec $paid €.\nOn me rend ? €',
      answer: paid - price,
      explanation: 'On cherche ce qui manque pour aller de $price à $paid :\n'
          '$paid − $price = ${paid - price} €.',
      allowTrueFalse: false,
    );
  }
  final values = switch (level) {
    1 => [1, 2],
    2 => [1, 2, 5],
    3 => [2, 5, 10],
    _ => [5, 10, 20],
  };
  final count = level <= 2 ? rnd(rng, 2, 3) : rnd(rng, 3, 4);
  final items = [for (var i = 0; i < count; i++) pick(rng, values)]
    ..sort((a, b) => b.compareTo(a));
  final total = items.fold(0, (a, b) => a + b);
  String show(int v) => v >= 5 ? '💶$v€' : '🪙$v€';
  return Question(
    prompt: '${items.map(show).join(' + ')}\n= ? €',
    answer: total,
    explanation: 'On commence par les plus gros : ${items.join(' + ')} = $total €.',
    allowTrueFalse: false,
  );
}

// ---------------- CE2 ----------------
Question _ce2Multiply(int level, Random rng) {
  switch (level) {
    case 1: {
      final n = rnd(rng, 2, 99);
      return Question(
        prompt: '$n × 10 = ?',
        answer: n * 10,
        explanation: 'Multiplier par 10 : on ajoute un zéro à droite. $n → ${n * 10}.',
      );
    }
    case 2: {
      final n = rnd(rng, 2, 99);
      return Question(
        prompt: '$n × 100 = ?',
        answer: n * 100,
        explanation: 'Multiplier par 100 : on ajoute deux zéros. $n → ${n * 100}.',
      );
    }
    case 3: {
      final t = rnd(rng, 2, 9), f = rnd(rng, 2, 9);
      return Question(
        prompt: '${t * 10} × $f = ?',
        answer: t * 10 * f,
        explanation: '${t * 10} × $f = ($t × $f) × 10 = ${t * f} × 10 = ${t * f * 10}.',
      );
    }
    default: {
      final n = level == 4 ? rnd(rng, 12, 49) : rnd(rng, 51, 99);
      final f = rnd(rng, 2, level == 4 ? 5 : 9);
      final d = (n ~/ 10) * 10, u = n % 10;
      return Question(
        prompt: '$n × $f = ?',
        answer: n * f,
        explanation: 'Décompose $n = $d + $u :\n'
            '$d × $f = ${d * f} et $u × $f = ${u * f}\n'
            'puis ${d * f} + ${u * f} = ${n * f}.',
      );
    }
  }
}

Question _ce2Divide(int level, Random rng) {
  final tables = switch (level) {
    1 => [2],
    2 => [5, 10],
    3 => [3, 4],
    4 => [6, 7, 8, 9],
    _ => [3, 4, 6, 7, 8, 9],
  };
  final d = pick(rng, tables);
  final q = rnd(rng, 2, 10);
  final n = d * q;
  if (level == 5) {
    final obj = pick(rng, ['œufs', 'gâteaux', 'billes', 'crayons']);
    return Question(
      prompt: 'On range $n $obj\npar boîtes de $d.\nCombien de boîtes ?',
      answer: q,
      explanation: 'On cherche combien de fois $d dans $n : $d × $q = $n, donc $q boîtes.',
      allowTrueFalse: false,
    );
  }
  return Question(
    prompt: '$n ÷ $d = ?',
    answer: q,
    explanation: 'Partager $n en $d parts égales.\n'
        'Cherche dans la table de $d : $d × $q = $n, donc $n ÷ $d = $q.',
  );
}


Question _cpShapes(int level, Random rng) {
  const shapes = [
    ('triangle', '🔺', 3),
    ('carré', '🟥', 4),
    ('rectangle', '▬', 4),
    ('pentagone', '⬟', 5),
    ('hexagone', '⬢', 6),
  ];
  if (level <= 2) {
    final (name, emoji, sides) = pick(rng, shapes.sublist(0, 2));
    return Question(
      prompt: 'Combien de côtés\na un $name $emoji ?',
      answer: sides,
      explanation: 'Compte les traits droits qui font le tour : un $name a $sides côtés.',
      allowTrueFalse: false,
    );
  }
  if (level <= 4) {
    final (name, emoji, sides) = pick(rng, shapes);
    return Question(
      prompt: 'Combien de sommets\na un $name $emoji ?',
      answer: sides,
      explanation: 'Les sommets sont les « coins ». Un $name a autant de sommets '
          'que de côtés : $sides.',
      allowTrueFalse: false,
    );
  }
  final (name, _, _) = pick(rng, shapes);
  final names = shapes.map((s) => s.$1).toList();
  final emojis = {for (final s in shapes) s.$1: s.$2};
  return Question.text(
    prompt: 'Lequel est un $name ?',
    answer: emojis[name]!,
    choices: [for (final n in names) emojis[n]!],
    explanation: 'Un $name : ${emojis[name]}.',
  );
}

Question _ce1Time(int level, Random rng) {
  switch (level) {
    case 1: {
      final h = rnd(rng, 1, 9), d = rnd(rng, 1, 3);
      return Question(
        prompt: 'Il est $h h.\nDans $d h, il sera ? h',
        answer: h + d,
        explanation: 'On avance de $d heure(s) : $h + $d = ${h + d} h.',
        allowTrueFalse: false,
      );
    }
    case 2:
      return const Question(
        prompt: '1 heure = ? minutes',
        answer: 60,
        explanation: 'Une heure, c\'est 60 minutes : la grande aiguille fait un tour complet.',
        allowTrueFalse: false,
      );
    case 3: {
      final h = rnd(rng, 7, 11), m = pick(rng, [15, 30, 45]);
      final d = pick(rng, [15, 30]);
      final total = m + d;
      final rh = h + total ~/ 60, rm = total % 60;
      return Question(
        prompt: 'Il est $h h $m.\nDans $d minutes,\nil sera $rh h ?',
        answer: rm,
        explanation: '$m + $d = $total minutes'
            '${total >= 60 ? ' = 1 h ${total - 60}' : ''}.\nIl sera $rh h $rm.',
        allowTrueFalse: false,
      );
    }
    case 4: {
      final start = rnd(rng, 8, 14), dur = rnd(rng, 2, 5);
      return Question(
        prompt: 'Le match commence à $start h\net finit à ${start + dur} h.\nIl dure ? h',
        answer: dur,
        explanation: 'Durée = fin − début = ${start + dur} − $start = $dur h.',
        allowTrueFalse: false,
      );
    }
    default: {
      final h = rnd(rng, 2, 3);
      return Question(
        prompt: '$h heures = ? minutes',
        answer: h * 60,
        explanation: '1 h = 60 min, donc $h h = $h × 60 = ${h * 60} min.',
        allowTrueFalse: false,
      );
    }
  }
}

Question _ce1Lengths(int level, Random rng) {
  switch (level) {
    case 1:
      return const Question(
        prompt: '1 m = ? cm',
        answer: 100,
        explanation: 'Un mètre, c\'est 100 centimètres (comme 100 petits carreaux de règle).',
        allowTrueFalse: false,
      );
    case 2: {
      final m = rnd(rng, 2, 9);
      return Question(
        prompt: '$m m = ? cm',
        answer: m * 100,
        explanation: '1 m = 100 cm, donc $m m = $m × 100 = ${m * 100} cm.',
        allowTrueFalse: false,
      );
    }
    case 3: {
      final m = rnd(rng, 1, 5), c = rnd(rng, 5, 95);
      return Question(
        prompt: '$m m $c cm = ? cm',
        answer: m * 100 + c,
        explanation: '$m m = ${m * 100} cm, plus $c cm : ${m * 100 + c} cm.',
        allowTrueFalse: false,
      );
    }
    case 4: {
      final a = rnd(rng, 12, 60), b = rnd(rng, 10, 39);
      return Question(
        prompt: 'Un crayon mesure $a cm,\nune gomme $b cm.\nEnsemble : ? cm',
        answer: a + b,
        explanation: 'On ajoute les longueurs : $a + $b = ${a + b} cm.',
        allowTrueFalse: false,
      );
    }
    default: {
      final total = rnd(rng, 2, 6) * 100 + rnd(rng, 10, 90);
      return Question(
        prompt: '$total cm = ${total ~/ 100} m ? cm',
        answer: total % 100,
        explanation: '$total cm = ${total ~/ 100} × 100 cm + ${total % 100} cm '
            '= ${total ~/ 100} m ${total % 100} cm.',
        allowTrueFalse: false,
      );
    }
  }
}

Question _ce2Fractions(int level, Random rng) {
  if (level <= 2) {
    final d = pick(rng, level == 1 ? [2, 4] : [3, 4, 5, 6]);
    return Question(
      prompt: 'Dans une unité, il y a\ncombien de \\frac{1}{$d} ?',
      answer: d,
      explanation: 'Une unité partagée en $d parts égales : il faut $d fois \\frac{1}{$d} pour faire 1.',
      allowTrueFalse: false,
    );
  }
  final d = pick(rng, [2, 3, 4, 5, 6]);
  final n = level == 3 ? 1 : rnd(rng, 1, d - 1);
  final k = level == 5 ? pick(rng, [2, 3]) : 2;
  return Question(
    prompt: '\\frac{$n}{$d} = \\frac{?}{${d * k}}',
    answer: n * k,
    explanation: 'On multiplie le haut ET le bas par le même nombre ($k) :\n'
        '\\frac{$n}{$d} = \\frac{$n × $k}{$d × $k} = \\frac{${n * k}}{${d * k}}.',
    allowTrueFalse: false,
  );
}

Question _ce2Measures(int level, Random rng) {
  switch (level) {
    case 1:
      return const Question(
        prompt: '1 kg = ? g',
        answer: 1000,
        explanation: '1 kilogramme = 1000 grammes (« kilo » veut dire mille).',
        allowTrueFalse: false,
      );
    case 2:
      return const Question(
        prompt: '1 L = ? cL',
        answer: 100,
        explanation: '1 litre = 100 centilitres (« centi » = centième).',
        allowTrueFalse: false,
      );
    case 3: {
      final k = rnd(rng, 2, 5);
      return Question(
        prompt: '$k kg = ? g',
        answer: k * 1000,
        explanation: '1 kg = 1000 g, donc $k kg = ${k * 1000} g.',
        allowTrueFalse: false,
      );
    }
    case 4: {
      final a = rnd(rng, 2, 8) * 100, b = rnd(rng, 1, 9) * 50;
      return Question(
        prompt: 'Un sac de $a g et\nun sac de $b g.\nTotal : ? g',
        answer: a + b,
        explanation: '$a + $b = ${a + b} g.',
        allowTrueFalse: false,
      );
    }
    default: {
      final cl = pick(rng, [10, 20, 25, 50]);
      final n = 100 ~/ cl;
      return Question(
        prompt: 'Combien de verres de $cl cL\npour remplir 1 L ?',
        answer: n,
        explanation: '1 L = 100 cL, et 100 ÷ $cl = $n verres.',
        allowTrueFalse: false,
      );
    }
  }
}
