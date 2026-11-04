import 'dart:math';

import 'package:flutter/material.dart';

import 'cycle.dart';

// =====================================================================
//  🎒 PRIMAIRE : CP, CE1, CE2, CM1, CM2
//  Chaque classe = une carte de chapitres + un boss.
//  Chaque chapitre = une fonction (niveau 1..5, hasard) -> Question.
// =====================================================================

final primaire = School(
  id: 'primaire',
  title: 'Primaire',
  subtitle: 'Du CP au CM2',
  emoji: '🎒',
  color: const Color(0xFF58CC02),
  grades: [cp, ce1, ce2, cm1, cm2],
  recommendedGradeId: 'ce1',
);

// Couleurs réutilisées
const _green = Color(0xFF58CC02);
const _blue = Color(0xFF1CB0F6);
const _orange = Color(0xFFFF9600);
const _purple = Color(0xFFCE82FF);
const _red = Color(0xFFFF4B4B);
const _gold = Color(0xFFFFC800);
const _teal = Color(0xFF00C2A8);

// =====================================================================
//  CP
// =====================================================================
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
      generate: (l, r) => _additionQ(r, switch (l) {
        1 => _AddSpec(1, 4, 1, 4, maxSum: 5),
        2 => _AddSpec(1, 9, 1, 9, maxSum: 10),
        3 => _AddSpec(5, 9, 2, 9, minSum: 11, maxSum: 15),
        4 => _AddSpec(3, 9, 3, 9, minSum: 11, maxSum: 18),
        _ => _AddSpec(10, 15, 2, 5, maxSum: 20),
      }),
    ),
    Chapter(
      id: 'cp_sub', title: 'Soustractions', subtitle: 'Enlever jusqu\'à 20',
      emoji: '➖', color: _orange, monster: '🦊', monsterName: 'Renard Moins',
      generate: (l, r) => _subtractionQ(r, switch (l) {
        1 => _SubSpec(2, 5, 1, 4),
        2 => _SubSpec(5, 10, 1, 9),
        3 => _SubSpec(11, 19, 1, 9, borrow: false),
        4 => _SubSpec(11, 18, 2, 9, borrow: true),
        _ => _SubSpec(15, 20, 3, 12),
      }),
    ),
    Chapter(
      id: 'cp_c10', title: 'Faire 10', subtitle: 'Compléments à 10 et à 20',
      emoji: '🔟', color: _purple, monster: '🐙', monsterName: 'Poulpe Dix-Bras',
      generate: _cpComplements,
    ),
  ],
  boss: const Chapter.boss(id: 'boss_cp', monster: '🐲', monsterName: 'Bébé Dragon'),
);

// =====================================================================
//  CE1  (classe la plus travaillée pour la démo)
// =====================================================================
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
      generate: (l, r) => _additionQ(r, switch (l) {
        1 => _AddSpec(10, 89, 1, 9, carry: false),
        2 => _AddSpec(15, 89, 2, 9, carry: true),
        3 => _AddSpec(10, 79, 10, 49, carry: false),
        4 => _AddSpec(15, 79, 11, 49, carry: true),
        _ => _AddSpec(100, 899, 11, 99),
      }),
    ),
    Chapter(
      id: 'ce1_sub', title: 'Soustractions', subtitle: 'Avec et sans retenue',
      emoji: '➖', color: _orange, monster: '🐙', monsterName: 'Soustracto',
      generate: (l, r) => _subtractionQ(r, switch (l) {
        1 => _SubSpec(20, 99, 1, 9, borrow: false),
        2 => _SubSpec(20, 99, 2, 9, borrow: true),
        3 => _SubSpec(30, 99, 10, 60, borrow: false),
        4 => _SubSpec(30, 99, 11, 60, borrow: true),
        _ => _SubSpec(120, 999, 11, 99),
      }),
    ),
    Chapter(
      id: 'ce1_mul', title: 'Tables 2, 3, 4, 5, 10', subtitle: 'Les premières tables',
      emoji: '✖️', color: _purple, monster: '🦖', monsterName: 'Multisaure',
      generate: (l, r) => _tableQ(r, switch (l) {
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
      generate: (l, r) => _problemQ(r, l, grade: 1),
    ),
  ],
  boss: const Chapter.boss(id: 'boss_ce1', monster: '🐲', monsterName: 'Le Grand Dragon'),
);

// =====================================================================
//  CE2
// =====================================================================
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
      generate: (l, r) => _additionQ(r, switch (l) {
        1 => _AddSpec(100, 800, 10, 99, carry: false),
        2 => _AddSpec(100, 800, 11, 99, carry: true),
        3 => _AddSpec(100, 500, 100, 400, carry: false),
        4 => _AddSpec(100, 600, 100, 399, carry: true),
        _ => _AddSpec(300, 999, 200, 999),
      }),
    ),
    Chapter(
      id: 'ce2_sub', title: 'Soustractions', subtitle: 'Nombres à 3 chiffres',
      emoji: '➖', color: _orange, monster: '🐙', monsterName: 'Soustracto Géant',
      generate: (l, r) => _subtractionQ(r, switch (l) {
        1 => _SubSpec(120, 999, 11, 99, borrow: false),
        2 => _SubSpec(120, 999, 11, 99, borrow: true),
        3 => _SubSpec(300, 999, 100, 299, borrow: false),
        4 => _SubSpec(300, 999, 100, 299, borrow: true),
        _ => _SubSpec(500, 999, 150, 499),
      }),
    ),
    Chapter(
      id: 'ce2_mul', title: 'Toutes les tables', subtitle: 'De 2 à 9',
      emoji: '✖️', color: _purple, monster: '🦖', monsterName: 'Multisaure',
      generate: (l, r) => _tableQ(r, switch (l) {
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
      generate: (l, r) => _problemQ(r, l, grade: 2),
    ),
  ],
  boss: const Chapter.boss(id: 'boss_ce2', monster: '🐲', monsterName: 'Le Dragon de Feu'),
);

// =====================================================================
//  CM1
// =====================================================================
final cm1 = Cycle(
  id: 'cm1',
  title: 'CM1',
  subtitle: 'Grands nombres, division, fractions',
  emoji: '🎒',
  color: _orange,
  chapters: [
    Chapter(
      id: 'cm1_big', title: 'Grands nombres', subtitle: 'Jusqu\'au million',
      emoji: '🏔️', color: _blue, monster: '🦣', monsterName: 'Mammouth Million',
      generate: _cm1BigNumbers,
    ),
    Chapter(
      id: 'cm1_mul', title: 'Multiplication posée', subtitle: '2 chiffres × 2 chiffres',
      emoji: '✖️', color: _purple, monster: '🤖', monsterName: 'Robot Fois',
      generate: _cm1Multiply,
    ),
    Chapter(
      id: 'cm1_div', title: 'Division', subtitle: 'Quotient et reste',
      emoji: '➗', color: _teal, monster: '🦈', monsterName: 'Requin Partageur',
      generate: _cm1Divide,
    ),
    Chapter(
      id: 'cm1_frac', title: 'Fractions', subtitle: 'Fraction d\'un nombre',
      emoji: '🍕', color: _orange, monster: '🍕', monsterName: 'Pizzator',
      generate: _cm1Fractions,
    ),
    Chapter(
      id: 'cm1_peri', title: 'Périmètres', subtitle: 'Carré et rectangle',
      emoji: '📏', color: _green, monster: '🐍', monsterName: 'Serpent Mesureur',
      generate: _cm1Perimeter,
    ),
  ],
  boss: const Chapter.boss(id: 'boss_cm1', monster: '🐉', monsterName: 'Le Dragon des Glaces'),
);

// =====================================================================
//  CM2
// =====================================================================
final cm2 = Cycle(
  id: 'cm2',
  title: 'CM2',
  subtitle: 'Décimaux, pourcentages, aires',
  emoji: '🎒',
  color: _purple,
  chapters: [
    Chapter(
      id: 'cm2_dec', title: 'Nombres décimaux', subtitle: '× 10, × 100, dixièmes',
      emoji: '🔢', color: _blue, monster: '🧙', monsterName: 'Mage Virgule',
      generate: _cm2Decimals,
    ),
    Chapter(
      id: 'cm2_div', title: 'Division', subtitle: '3 chiffres ÷ 1 chiffre',
      emoji: '➗', color: _teal, monster: '🦈', monsterName: 'Requin Partageur',
      generate: _cm2Divide,
    ),
    Chapter(
      id: 'cm2_pct', title: 'Pourcentages', subtitle: '10 %, 25 %, 50 %...',
      emoji: '💯', color: _red, monster: '🦹', monsterName: 'Docteur Pourcent',
      generate: _cm2Percent,
    ),
    Chapter(
      id: 'cm2_prop', title: 'Proportionnalité', subtitle: 'Règle de trois',
      emoji: '⚖️', color: _orange, monster: '🧞', monsterName: 'Génie de la Balance',
      generate: _cm2Proportion,
    ),
    Chapter(
      id: 'cm2_aire', title: 'Aires', subtitle: 'Rectangle, carré, triangle',
      emoji: '🟩', color: _green, monster: '🗿', monsterName: 'Géant de Pierre',
      generate: _cm2Area,
    ),
  ],
  boss: const Chapter.boss(id: 'boss_cm2', monster: '🐲', monsterName: 'Le Roi Dragon'),
);

// =====================================================================
//  OUTILS
// =====================================================================
int _rnd(Random rng, int a, int b) => a + rng.nextInt(b - a + 1);
T _pick<T>(Random rng, List<T> l) => l[rng.nextInt(l.length)];

String _fmt(int n) {
  // 45678 -> "45 678"
  final s = n.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return n < 0 ? '-$buf' : buf.toString();
}

String _dec(int hundredths) {
  // 425 -> "4,25" ; 340 -> "3,4"
  final e = hundredths ~/ 100, c = hundredths % 100;
  if (c == 0) return '$e';
  if (c % 10 == 0) return '$e,${c ~/ 10}';
  return '$e,${c.toString().padLeft(2, '0')}';
}

// ---------------------------------------------------------------------
// Additions et soustractions génériques
// ---------------------------------------------------------------------
class _AddSpec {
  final int aMin, aMax, bMin, bMax;
  final int? minSum, maxSum;
  final bool? carry; // true = avec retenue, false = sans, null = peu importe

  const _AddSpec(this.aMin, this.aMax, this.bMin, this.bMax,
      {this.minSum, this.maxSum, this.carry});
}

bool _hasCarry(int a, int b) {
  while (a > 0 || b > 0) {
    if (a % 10 + b % 10 >= 10) return true;
    a ~/= 10;
    b ~/= 10;
  }
  return false;
}

Question _additionQ(Random rng, _AddSpec s) {
  late int a, b;
  for (var tries = 0; tries < 200; tries++) {
    a = _rnd(rng, s.aMin, s.aMax);
    b = _rnd(rng, s.bMin, s.bMax);
    final sum = a + b;
    if (s.minSum != null && sum < s.minSum!) continue;
    if (s.maxSum != null && sum > s.maxSum!) continue;
    if (s.carry != null && _hasCarry(a, b) != s.carry) continue;
    break;
  }
  final sum = a + b;
  String expl;
  if (b < 10 && a < 10) {
    final toTen = 10 - a;
    expl = sum > 10
        ? 'Astuce : complète jusqu\'à 10 !\n$a + $toTen = 10, puis 10 + ${b - toTen} = $sum.'
        : 'Pars de $a et avance de $b sur tes doigts : tu arrives à $sum.';
  } else if (b < 10) {
    final toTen = 10 - a % 10;
    expl = b > toTen
        ? 'Complète jusqu\'à la dizaine : $a + $toTen = ${a + toTen}, '
            'puis ${a + toTen} + ${b - toTen} = $sum.'
        : 'On ajoute les unités : ${a % 10} + $b = ${a % 10 + b}, donc $a + $b = $sum.';
  } else {
    final big = b >= 100;
    final h = big ? (b ~/ 100) * 100 : 0;
    final d = ((b % 100) ~/ 10) * 10, u = b % 10;
    final parts = [if (h > 0) '$h', if (d > 0) '$d', if (u > 0) '$u'];
    var acc = a;
    final steps = <String>[];
    for (final p in [h, d, u]) {
      if (p == 0) continue;
      steps.add('$acc + $p = ${acc + p}');
      acc += p;
    }
    expl = 'Décompose $b en ${parts.join(' + ')}.\n${steps.join('\n')}';
    if (_hasCarry(a, b)) expl += '\n(Attention à la retenue en posant l\'opération !)';
  }
  return Question(prompt: '$a + $b = ?', answer: sum, explanation: expl);
}

class _SubSpec {
  final int aMin, aMax, bMin, bMax;
  final bool? borrow;

  const _SubSpec(this.aMin, this.aMax, this.bMin, this.bMax, {this.borrow});
}

bool _hasBorrow(int a, int b) {
  while (b > 0) {
    if (b % 10 > a % 10) return true;
    a ~/= 10;
    b ~/= 10;
  }
  return false;
}

Question _subtractionQ(Random rng, _SubSpec s) {
  late int a, b;
  for (var tries = 0; tries < 200; tries++) {
    a = _rnd(rng, s.aMin, s.aMax);
    b = _rnd(rng, s.bMin, min(s.bMax, a));
    if (s.borrow != null && _hasBorrow(a, b) != s.borrow) continue;
    break;
  }
  final r = a - b;
  String expl;
  if (b < 10) {
    final down = a % 10;
    expl = (b > down && down > 0 && a > 10)
        ? 'Redescends d\'abord à la dizaine : $a − $down = ${a - down}, '
            'puis ${a - down} − ${b - down} = $r.'
        : 'Pars de $a et recule de $b : tu arrives à $r.';
  } else {
    final h = (b ~/ 100) * 100, d = ((b % 100) ~/ 10) * 10, u = b % 10;
    final parts = [if (h > 0) '$h', if (d > 0) '$d', if (u > 0) '$u'];
    var acc = a;
    final steps = <String>[];
    for (final p in [h, d, u]) {
      if (p == 0) continue;
      steps.add('$acc − $p = ${acc - p}');
      acc -= p;
    }
    expl = 'Décompose $b en ${parts.join(' + ')} et enlève morceau par morceau :\n'
        '${steps.join('\n')}';
  }
  expl += '\nVérifie : $r + $b = $a ✔';
  return Question(prompt: '$a − $b = ?', answer: r, explanation: expl);
}

// ---------------------------------------------------------------------
// Tables de multiplication
// ---------------------------------------------------------------------
Question _tableQ(Random rng, List<int> tables, {bool missingFactor = false}) {
  final t = _pick(rng, tables);
  final f = _rnd(rng, 2, 10);
  final p = t * f;
  if (missingFactor && rng.nextBool()) {
    return Question(
      prompt: '$t × ? = $p',
      answer: f,
      explanation: 'Récite la table de $t jusqu\'à trouver $p : $t × $f = $p.',
      allowTrueFalse: false,
    );
  }
  String expl;
  if (f == 10 || t == 10) {
    expl = 'Multiplier par 10, c\'est ajouter un zéro : $t × $f = $p.';
  } else if (f <= 5) {
    expl = '$t × $f, c\'est $t ajouté $f fois :\n${List.filled(f, '$t').join(' + ')} = $p.';
  } else {
    expl = 'Coupe en deux : $t × $f = ($t × 5) + ($t × ${f - 5})\n'
        '= ${t * 5} + ${t * (f - 5)} = $p.';
  }
  return Question(prompt: '$t × $f = ?', answer: p, explanation: expl);
}

// ---------------------------------------------------------------------
// Problèmes
// ---------------------------------------------------------------------
const _names = [
  ('Awa', 'elle'), ('Lucas', 'il'), ('Fatou', 'elle'),
  ('Léo', 'il'), ('Inès', 'elle'), ('Moussa', 'il'),
];
const _objects = ['billes', 'bonbons', 'mangues', 'crayons', 'images', 'cartes'];

/// grade : 1 = CE1, 2 = CE2.
Question _problemQ(Random rng, int level, {required int grade}) {
  final (name, pron) = _pick(rng, _names);
  final pronCap = pron[0].toUpperCase() + pron.substring(1);
  final obj = _pick(rng, _objects);
  final kinds = level >= 4 ? ['add', 'sub', 'mul'] : ['add', 'sub'];
  final kind = _pick(rng, kinds);

  if (kind == 'mul') {
    final n = _rnd(rng, 2, grade == 1 ? 5 : 9);
    final k = _rnd(rng, 2, grade == 1 ? 5 : 9);
    return Question(
      prompt: '$name achète $n paquets de $k $obj.\nCombien de $obj en tout ?',
      answer: n * k,
      explanation: '$n paquets de $k, c\'est $n fois $k :\n$n × $k = ${n * k} $obj.',
      allowTrueFalse: false,
    );
  }
  final scale = grade == 1 ? 1 : 3;
  final (int a, int b) = switch (level) {
    1 => (_rnd(rng, 5, 15) * scale, _rnd(rng, 1, 5) * scale),
    2 => (_rnd(rng, 15, 30) * scale, _rnd(rng, 3, 9) * scale),
    3 => (_rnd(rng, 25, 60) * scale, _rnd(rng, 10, 20) * scale),
    4 => (_rnd(rng, 40, 90) * scale, _rnd(rng, 11, 35) * scale),
    _ => (_rnd(rng, 100, 300) * scale, _rnd(rng, 20, 90) * scale),
  };
  if (kind == 'add') {
    return Question(
      prompt: '$name a $a $obj. On lui en donne $b.\nCombien en a-t-$pron maintenant ?',
      answer: a + b,
      explanation: 'On lui en DONNE : ça augmente → addition.\n$a + $b = ${a + b} $obj.',
      allowTrueFalse: false,
    );
  }
  return Question(
    prompt: '$name a $a $obj. $pronCap en perd $b.\nCombien lui en reste-t-il ?',
    answer: a - b,
    explanation: '$pronCap en PERD : ça diminue → soustraction.\n$a − $b = ${a - b} $obj.',
    allowTrueFalse: false,
  );
}

// =====================================================================
//  GÉNÉRATEURS SPÉCIFIQUES
// =====================================================================

// ---------------- CP ----------------
Question _cpCount(int level, Random rng) {
  final n = switch (level) {
    1 => _rnd(rng, 1, 5),
    2 => _rnd(rng, 3, 8),
    3 => _rnd(rng, 6, 10),
    4 => _rnd(rng, 9, 14),
    _ => _rnd(rng, 12, 20),
  };
  final e = _pick(rng, ['🍎', '⭐', '🐟', '🌸', '🚗', '🎈']);
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
    final d = _rnd(rng, 1, 8), u = _rnd(rng, d + 1, 9);
    nums.addAll([d * 10 + u, u * 10 + d]);
  }
  while (nums.length < 4) {
    nums.add(_rnd(rng, 0, maxN));
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
    1 => (5, _rnd(rng, 0, 5)),
    2 => (10, _rnd(rng, 1, 9)),
    3 => (10, _rnd(rng, 0, 10)),
    4 => (20, _rnd(rng, 10, 19)),
    _ => (20, _rnd(rng, 2, 18)),
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
      final d = _rnd(rng, 1, 9), u = _rnd(rng, 0, 9);
      return Question(
        prompt: '$d dizaines et $u unités = ?',
        answer: d * 10 + u,
        explanation: '$d dizaines = ${d * 10}, plus $u unités : ${d * 10} + $u = ${d * 10 + u}.',
        allowTrueFalse: false,
      );
    }
    case 2: {
      final d = _rnd(rng, 1, 9), u = _rnd(rng, 1, 9);
      return Question(
        prompt: '$u unités et $d dizaines = ?',
        answer: d * 10 + u,
        explanation: 'Attention à l\'ordre ! Les dizaines s\'écrivent à gauche :\n'
            '$d dizaines = ${d * 10}, + $u unités = ${d * 10 + u}.',
        allowTrueFalse: false,
      );
    }
    case 3: {
      final c = _rnd(rng, 1, 9), d = _rnd(rng, 0, 9), u = _rnd(rng, 0, 9);
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
      final c = _rnd(rng, 1, 9), u = _rnd(rng, 1, 9);
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
      final n = _rnd(rng, 11, 99) * 10;
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
      final n = _rnd(rng, 1, 5);
      return Question(
        prompt: 'Le double de $n = ?',
        answer: 2 * n,
        explanation: 'Le double, c\'est le nombre ajouté à lui-même : $n + $n = ${2 * n}.',
      );
    }
    case 2: {
      final n = _rnd(rng, 6, 10);
      return Question(
        prompt: 'Le double de $n = ?',
        answer: 2 * n,
        explanation: '$n + $n = ${2 * n}.',
      );
    }
    case 3: {
      final n = _rnd(rng, 1, 10) * 2;
      return Question(
        prompt: 'La moitié de $n = ?',
        answer: n ~/ 2,
        explanation: 'La moitié, c\'est partager en 2 parts égales : '
            '${n ~/ 2} + ${n ~/ 2} = $n, donc la moitié de $n est ${n ~/ 2}.',
      );
    }
    case 4: {
      final n = _rnd(rng, 11, 45);
      final d = (n ~/ 10) * 10, u = n % 10;
      return Question(
        prompt: 'Le double de $n = ?',
        answer: 2 * n,
        explanation: 'Double des dizaines + double des unités :\n'
            '$d + $d = ${2 * d} et $u + $u = ${2 * u}, donc ${2 * n}.',
      );
    }
    default: {
      final n = _rnd(rng, 6, 50) * 2;
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
    final price = _rnd(rng, 3, 18);
    final paid = price <= 5 ? 5 : (price <= 10 ? 10 : 20);
    final item = _pick(rng, ['un jouet', 'un livre', 'un ballon', 'une glace', 'un stylo']);
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
  final count = level <= 2 ? _rnd(rng, 2, 3) : _rnd(rng, 3, 4);
  final items = [for (var i = 0; i < count; i++) _pick(rng, values)]
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
      final n = _rnd(rng, 2, 99);
      return Question(
        prompt: '$n × 10 = ?',
        answer: n * 10,
        explanation: 'Multiplier par 10 : on ajoute un zéro à droite. $n → ${n * 10}.',
      );
    }
    case 2: {
      final n = _rnd(rng, 2, 99);
      return Question(
        prompt: '$n × 100 = ?',
        answer: n * 100,
        explanation: 'Multiplier par 100 : on ajoute deux zéros. $n → ${n * 100}.',
      );
    }
    case 3: {
      final t = _rnd(rng, 2, 9), f = _rnd(rng, 2, 9);
      return Question(
        prompt: '${t * 10} × $f = ?',
        answer: t * 10 * f,
        explanation: '${t * 10} × $f = ($t × $f) × 10 = ${t * f} × 10 = ${t * f * 10}.',
      );
    }
    default: {
      final n = level == 4 ? _rnd(rng, 12, 49) : _rnd(rng, 51, 99);
      final f = _rnd(rng, 2, level == 4 ? 5 : 9);
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
  final d = _pick(rng, tables);
  final q = _rnd(rng, 2, 10);
  final n = d * q;
  if (level == 5) {
    final obj = _pick(rng, ['œufs', 'gâteaux', 'billes', 'crayons']);
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

// ---------------- CM1 ----------------
Question _cm1BigNumbers(int level, Random rng) {
  final n = switch (level) {
    1 => _rnd(rng, 1000, 9999),
    2 => _rnd(rng, 10000, 99999),
    3 => _rnd(rng, 10000, 99999),
    4 => _rnd(rng, 100000, 999999),
    _ => _rnd(rng, 100000, 999999),
  };
  if (level == 5 || level == 3) {
    final unit = level == 3 ? 100 : 1000;
    final name = level == 3 ? 'centaines' : 'milliers';
    return Question(
      prompt: 'Combien de $name\ndans ${_fmt(n)} ?',
      answer: n ~/ unit,
      explanation: 'Le nombre de $name, c\'est tout ce qui est à gauche du chiffre des $name inclus :\n'
          '${_fmt(n)} → ${_fmt(n ~/ unit)} $name.',
      allowTrueFalse: false,
    );
  }
  const ranks = [
    (1, 'unités'), (10, 'dizaines'), (100, 'centaines'),
    (1000, 'unités de mille'), (10000, 'dizaines de mille'), (100000, 'centaines de mille'),
  ];
  final digits = n.toString().length;
  final (p, name) = ranks[_rnd(rng, 1, digits - 1)];
  final digit = (n ~/ p) % 10;
  return Question(
    prompt: 'Dans ${_fmt(n)}, quel est\nle chiffre des $name ?',
    answer: digit,
    choices: {digit, ...n.toString().split('').map(int.parse)}.toList(),
    explanation: 'Place le nombre dans le tableau : de droite à gauche, unités, dizaines, '
        'centaines, puis milliers…\nLe chiffre des $name de ${_fmt(n)} est $digit.',
    allowTrueFalse: false,
  );
}

Question _cm1Multiply(int level, Random rng) {
  final (int a, int b) = switch (level) {
    1 => (_rnd(rng, 11, 99), 10),
    2 => (_rnd(rng, 12, 99), _rnd(rng, 3, 9)),
    3 => (_rnd(rng, 11, 49), _rnd(rng, 2, 5) * 10),
    4 => (_rnd(rng, 11, 39), _rnd(rng, 11, 19)),
    _ => (_rnd(rng, 21, 99), _rnd(rng, 21, 49)),
  };
  final bd = (b ~/ 10) * 10, bu = b % 10;
  final expl = bu == 0
      ? '$a × $b = ($a × ${b ~/ 10}) × 10 = ${a * (b ~/ 10)} × 10 = ${a * b}.'
      : bd == 0
          ? 'Décompose $a = ${(a ~/ 10) * 10} + ${a % 10} :\n'
              '${(a ~/ 10) * 10} × $b = ${(a ~/ 10) * 10 * b} et ${a % 10} × $b = ${(a % 10) * b}\n'
              'Total : ${a * b}.'
          : 'Décompose $b = $bd + $bu :\n'
              '$a × $bd = ${a * bd} et $a × $bu = ${a * bu}\n'
              'Total : ${a * bd} + ${a * bu} = ${a * b}.';
  return Question(prompt: '$a × $b = ?', answer: a * b, explanation: expl);
}

Question _cm1Divide(int level, Random rng) {
  final d = switch (level) {
    1 => _pick(rng, [2, 5]),
    2 => _pick(rng, [3, 4]),
    3 => _rnd(rng, 6, 9),
    _ => _rnd(rng, 3, 9),
  };
  final q = level >= 4 ? _rnd(rng, 11, 30) : _rnd(rng, 3, 10);
  final rest = level == 1 ? 0 : _rnd(rng, 0, d - 1);
  final n = d * q + rest;
  return Question(
    prompt: '$n ÷ $d\nquotient = ?',
    answer: q,
    explanation: 'Combien de fois $d dans $n ?\n'
        '$d × $q = ${d * q}${rest > 0 ? ', et il reste ${n - d * q}' : ''}.\n'
        'Le quotient est $q${rest > 0 ? ' (reste $rest)' : ''}.',
    allowTrueFalse: false,
  );
}

Question _cm1Fractions(int level, Random rng) {
  final dens = switch (level) {
    1 => [2],
    2 => [2, 4],
    3 => [3, 4, 5],
    4 => [4, 5, 10],
    _ => [3, 6, 8, 10],
  };
  final d = _pick(rng, dens);
  final n = level <= 2 ? 1 : _rnd(rng, 1, d - 1);
  final k = _rnd(rng, 2, 5 + 2 * level);
  final total = d * k;
  return Question(
    prompt: '$n/$d de $total = ?',
    answer: n * k,
    explanation: 'On partage $total en $d parts égales : $total ÷ $d = $k.\n'
        '${n == 1 ? 'On en prend 1 : $k.' : 'On en prend $n : $n × $k = ${n * k}.'}',
  );
}

Question _cm1Perimeter(int level, Random rng) {
  if (level <= 2) {
    final c = _rnd(rng, 2, level == 1 ? 9 : 25);
    return Question(
      prompt: 'Un carré de côté $c cm.\nPérimètre = ? cm',
      answer: 4 * c,
      explanation: 'Un carré a 4 côtés égaux : 4 × $c = ${4 * c} cm.',
      allowTrueFalse: false,
    );
  }
  final l = _rnd(rng, 4, 10 * (level - 1)), w = _rnd(rng, 2, max(3, l - 1));
  if (level == 5 && rng.nextBool()) {
    final p = 2 * (l + w);
    return Question(
      prompt: 'Un rectangle a un périmètre\nde $p cm et une longueur\nde $l cm. Largeur = ? cm',
      answer: w,
      explanation: 'Demi-périmètre : $p ÷ 2 = ${p ~/ 2} cm = longueur + largeur.\n'
          'Largeur = ${p ~/ 2} − $l = $w cm.',
      allowTrueFalse: false,
    );
  }
  return Question(
    prompt: 'Rectangle de $l cm sur $w cm.\nPérimètre = ? cm',
    answer: 2 * (l + w),
    explanation: 'Périmètre = 2 × (longueur + largeur)\n= 2 × ($l + $w) = 2 × ${l + w} = ${2 * (l + w)} cm.',
    allowTrueFalse: false,
  );
}

// ---------------- CM2 ----------------
Question _cm2Decimals(int level, Random rng) {
  switch (level) {
    case 1: {
      final t = _rnd(rng, 11, 99); // en dixièmes : 3,4 = 34 dixièmes
      return Question(
        prompt: '${_dec(t * 10)} × 10 = ?',
        answer: t,
        explanation: 'Multiplier par 10 : la virgule se décale d\'un rang vers la droite.\n'
            '${_dec(t * 10)} → $t.',
      );
    }
    case 2: {
      final c = _rnd(rng, 101, 999);
      return Question(
        prompt: '${_dec(c)} × 100 = ?',
        answer: c,
        explanation: 'Multiplier par 100 : la virgule se décale de deux rangs vers la droite.\n'
            '${_dec(c)} → $c.',
      );
    }
    case 3: {
      final t = _rnd(rng, 11, 99);
      return Question(
        prompt: 'Combien de dixièmes\ndans ${_dec(t * 10)} ?',
        answer: t,
        explanation: '1 unité = 10 dixièmes. ${_dec(t * 10)} = ${t ~/ 10} unités et ${t % 10} dixièmes\n'
            '= ${t ~/ 10} × 10 + ${t % 10} = $t dixièmes.',
        allowTrueFalse: false,
      );
    }
    case 4: {
      final a = _rnd(rng, 1, 9), b = 10 - a;
      final e1 = _rnd(rng, 0, 5), e2 = _rnd(rng, 0, 4);
      return Question(
        prompt: '${_dec(e1 * 100 + a * 10)} + ${_dec(e2 * 100 + b * 10)} = ?',
        answer: e1 + e2 + 1,
        explanation: 'Les dixièmes : $a + $b = 10 dixièmes = 1 unité.\n'
            'Les unités : $e1 + $e2 + 1 = ${e1 + e2 + 1}.',
      );
    }
    default: {
      final x = _rnd(rng, 11, 99) * 10; // dixièmes déguisés
      return Question(
        prompt: '${_dec(x)} × 1000 = ?',
        answer: x * 10,
        explanation: 'Multiplier par 1000 : la virgule avance de 3 rangs '
            '(on complète avec des zéros).\n${_dec(x)} → ${x * 10}.',
      );
    }
  }
}

Question _cm2Divide(int level, Random rng) {
  final d = switch (level) {
    1 => 2,
    2 => _pick(rng, [4, 5]),
    3 => _pick(rng, [3, 6]),
    _ => _rnd(rng, 3, 9),
  };
  final q = switch (level) {
    1 => _rnd(rng, 11, 49),
    2 => _rnd(rng, 21, 99),
    3 => _rnd(rng, 21, 99),
    4 => _rnd(rng, 101, 199),
    _ => _rnd(rng, 101, 333),
  };
  final n = d * q;
  final h = (q ~/ 100) * 100, rest = q - h;
  return Question(
    prompt: '$n ÷ $d = ?',
    answer: q,
    explanation: h > 0
        ? 'Découpe : $n = ${d * h} + ${d * rest}.\n'
            '${d * h} ÷ $d = $h et ${d * rest} ÷ $d = $rest, donc $q.'
        : 'Cherche combien de fois $d dans $n : $d × $q = $n.',
  );
}

Question _cm2Percent(int level, Random rng) {
  final (int pct, int base) = switch (level) {
    1 => (50, _rnd(rng, 2, 50) * 2),
    2 => (10, _rnd(rng, 2, 50) * 10),
    3 => (25, _rnd(rng, 2, 25) * 4),
    4 => (_pick(rng, [20, 30, 75]), _rnd(rng, 2, 20) * 20),
    _ => (_pick(rng, [5, 15, 40, 60]), _rnd(rng, 2, 20) * 20),
  };
  final r = pct * base ~/ 100;
  final how = switch (pct) {
    50 => '50 % = la moitié : $base ÷ 2 = $r.',
    10 => '10 % = un dixième : $base ÷ 10 = $r.',
    25 => '25 % = un quart : $base ÷ 4 = $r.',
    75 => '75 % = trois quarts : ($base ÷ 4) × 3 = ${base ~/ 4} × 3 = $r.',
    _ => '$pct % = $pct pour 100. 1 % de $base = $base ÷ 100, '
        'donc $pct % = $base × $pct ÷ 100 = $r.',
  };
  return Question(
    prompt: '$pct % de $base = ?',
    answer: r,
    explanation: how,
  );
}

Question _cm2Proportion(int level, Random rng) {
  final unit = _rnd(rng, 2, level <= 2 ? 5 : 12);
  final n1 = _rnd(rng, 2, level <= 2 ? 4 : 6);
  var n2 = _rnd(rng, 2, level >= 4 ? 15 : 10);
  if (n2 == n1) n2++;
  final (item, plural) = _pick(rng, [
    ('cahier', 'cahiers'), ('croissant', 'croissants'),
    ('ticket', 'tickets'), ('stylo', 'stylos'),
  ]);
  return Question(
    prompt: '$n1 $plural coûtent ${n1 * unit} €.\n$n2 $plural coûtent ? €',
    answer: n2 * unit,
    explanation: 'On cherche d\'abord le prix d\'1 $item : ${n1 * unit} ÷ $n1 = $unit €.\n'
        'Puis pour $n2 : $n2 × $unit = ${n2 * unit} €.',
    allowTrueFalse: false,
  );
}

Question _cm2Area(int level, Random rng) {
  switch (level) {
    case 1: {
      final c = _rnd(rng, 2, 9);
      return Question(
        prompt: 'Carré de côté $c cm.\nAire = ? cm²',
        answer: c * c,
        explanation: 'Aire du carré = côté × côté = $c × $c = ${c * c} cm².',
        allowTrueFalse: false,
      );
    }
    case 2:
    case 3: {
      final l = _rnd(rng, 3, level == 2 ? 9 : 20), w = _rnd(rng, 2, 9);
      return Question(
        prompt: 'Rectangle de $l cm sur $w cm.\nAire = ? cm²',
        answer: l * w,
        explanation: 'Aire du rectangle = longueur × largeur = $l × $w = ${l * w} cm².',
        allowTrueFalse: false,
      );
    }
    case 4: {
      final b = _rnd(rng, 2, 10) * 2, h = _rnd(rng, 3, 12);
      return Question(
        prompt: 'Triangle rectangle :\ncôtés de l\'angle droit $b cm et $h cm.\nAire = ? cm²',
        answer: b * h ~/ 2,
        explanation: 'C\'est la moitié d\'un rectangle $b × $h :\n'
            '($b × $h) ÷ 2 = ${b * h} ÷ 2 = ${b * h ~/ 2} cm².',
        allowTrueFalse: false,
      );
    }
    default: {
      final area = _pick(rng, [24, 36, 48, 60, 72]);
      final l = _pick(rng, [for (var x = 3; x <= 12; x++) if (area % x == 0) x]);
      return Question(
        prompt: 'Un rectangle a une aire de $area cm²\net une longueur de $l cm.\nLargeur = ? cm',
        answer: area ~/ l,
        explanation: 'Aire = longueur × largeur, donc largeur = aire ÷ longueur\n'
            '= $area ÷ $l = ${area ~/ l} cm.',
        allowTrueFalse: false,
      );
    }
  }
}
