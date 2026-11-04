import 'dart:math';

import 'package:flutter/material.dart';

import 'cycle.dart';
import 'helpers.dart';

// =====================================================================
//  CYCLE 3 : CM1, CM2, 6e  (programme du cycle 3)
//  Grands nombres, fractions et décimaux, quatre opérations, algèbre,
//  grandeurs (aires, angles, volumes), géométrie.
// =====================================================================

final cycle3 = School(
  id: 'cycle3',
  title: 'Cycle 3',
  subtitle: 'CM1 · CM2 · 6e',
  emoji: '🧭',
  color: Color(0xFF2A5C96),
  grades: [cm1, cm2, sixieme],
);

const _green = Color(0xFF58CC02);
const _blue = Color(0xFF2A5C96);
const _orange = Color(0xFFFF8C38);
const _purple = Color(0xFFCE82FF);
const _red = Color(0xFFFF4B4B);
const _teal = Color(0xFF00C2A8);

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
    Chapter(
      id: 'cm1_fline', title: 'Fractions sur la droite', subtitle: 'Placer une fraction',
      emoji: '📏', color: _teal, monster: '🐌', monsterName: 'Escargot Rapide',
      generate: (l, r) => fractionLineQ(r, l),
      exerciseOnly: true,
    ),
    Chapter(
      id: 'cm1_ang', title: 'Les angles', subtitle: 'Droit, aigu, obtus',
      emoji: '📐', color: _purple, monster: '🦇', monsterName: 'Chauve-souris Pointue',
      generate: _cm1Angles,
    ),
  ],
  boss: const Chapter.boss(id: 'boss_cm1', monster: '🐉', monsterName: 'Le Dragon des Glaces'),
);

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
    Chapter(
      id: 'cm2_alg', title: 'Trouver le nombre caché', subtitle: 'Initiation à l\'algèbre',
      emoji: '🕵️', color: _blue, monster: '🕵️', monsterName: 'Monsieur X',
      generate: _cm2Algebra,
    ),
  ],
  boss: const Chapter.boss(id: 'boss_cm2', monster: '🐲', monsterName: 'Le Roi Dragon'),
);

// =====================================================================
//  SIXIÈME
// =====================================================================
final sixieme = Cycle(
  id: '6e',
  title: '6e',
  subtitle: 'Décimaux, fractions, aires et volumes',
  emoji: '📘',
  color: _blue,
  chapters: [
    Chapter(
      id: '6e_dec', title: 'Nombres décimaux', subtitle: 'Calculer avec la virgule',
      emoji: '🔢', color: _blue, monster: '🧙', monsterName: 'Mage Virgule',
      generate: _sixiemeDecimals,
    ),
    Chapter(
      id: '6e_frac', title: 'Fractions', subtitle: 'Quotient et fraction d\'une quantité',
      emoji: '🍕', color: _orange, monster: '🍕', monsterName: 'Pizzator',
      generate: _sixiemeFractions,
    ),
    Chapter(
      id: '6e_alg', title: 'Expressions', subtitle: 'Calculer pour x = ...',
      emoji: '🔣', color: _purple, monster: '🧩', monsterName: 'Le Sphinx',
      generate: _sixiemeExpressions,
    ),
    Chapter(
      id: '6e_vol', title: 'Aires et volumes', subtitle: 'Triangle, pavé droit',
      emoji: '🧊', color: _teal, monster: '🧊', monsterName: 'Cube de Glace',
      generate: _sixiemeAreaVolume,
    ),
    Chapter(
      id: '6e_ang', title: 'Angles du triangle', subtitle: 'Somme = 180°',
      emoji: '🔺', color: _red, monster: '🔺', monsterName: 'Triangle Farceur',
      generate: _sixiemeTriangleAngles,
    ),
    Chapter(
      id: '6e_sym', title: 'Symétrie axiale', subtitle: 'Dans un quadrillage',
      emoji: '🦋', color: _green, monster: '🦋', monsterName: 'Papillon Miroir',
      generate: _sixiemeSymmetry,
      exerciseOnly: true,
    ),
  ],
  boss: const Chapter.boss(id: 'boss_6e', monster: '🐉', monsterName: 'Le Dragon du Collège'),
);

// =====================================================================
//  GÉNÉRATEURS
// =====================================================================
// ---------------- CM1 ----------------
Question _cm1BigNumbers(int level, Random rng) {
  final n = switch (level) {
    1 => rnd(rng, 1000, 9999),
    2 => rnd(rng, 10000, 99999),
    3 => rnd(rng, 10000, 99999),
    4 => rnd(rng, 100000, 999999),
    _ => rnd(rng, 100000, 999999),
  };
  if (level == 5 || level == 3) {
    final unit = level == 3 ? 100 : 1000;
    final name = level == 3 ? 'centaines' : 'milliers';
    return Question(
      prompt: 'Combien de $name\ndans ${fmtInt(n)} ?',
      answer: n ~/ unit,
      explanation: 'Le nombre de $name, c\'est tout ce qui est à gauche du chiffre des $name inclus :\n'
          '${fmtInt(n)} → ${fmtInt(n ~/ unit)} $name.',
      allowTrueFalse: false,
    );
  }
  const ranks = [
    (1, 'unités'), (10, 'dizaines'), (100, 'centaines'),
    (1000, 'unités de mille'), (10000, 'dizaines de mille'), (100000, 'centaines de mille'),
  ];
  final digits = n.toString().length;
  final (p, name) = ranks[rnd(rng, 1, digits - 1)];
  final digit = (n ~/ p) % 10;
  return Question(
    prompt: 'Dans ${fmtInt(n)}, quel est\nle chiffre des $name ?',
    answer: digit,
    choices: {digit, ...n.toString().split('').map(int.parse)}.toList(),
    explanation: 'Place le nombre dans le tableau : de droite à gauche, unités, dizaines, '
        'centaines, puis milliers…\nLe chiffre des $name de ${fmtInt(n)} est $digit.',
    allowTrueFalse: false,
  );
}

Question _cm1Multiply(int level, Random rng) {
  final (int a, int b) = switch (level) {
    1 => (rnd(rng, 11, 99), 10),
    2 => (rnd(rng, 12, 99), rnd(rng, 3, 9)),
    3 => (rnd(rng, 11, 49), rnd(rng, 2, 5) * 10),
    4 => (rnd(rng, 11, 39), rnd(rng, 11, 19)),
    _ => (rnd(rng, 21, 99), rnd(rng, 21, 49)),
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
    1 => pick(rng, [2, 5]),
    2 => pick(rng, [3, 4]),
    3 => rnd(rng, 6, 9),
    _ => rnd(rng, 3, 9),
  };
  final q = level >= 4 ? rnd(rng, 11, 30) : rnd(rng, 3, 10);
  final rest = level == 1 ? 0 : rnd(rng, 0, d - 1);
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
  final d = pick(rng, dens);
  final n = level <= 2 ? 1 : rnd(rng, 1, d - 1);
  final k = rnd(rng, 2, 5 + 2 * level);
  final total = d * k;
  return Question(
    prompt: '${frac(n, d)} de $total = ?',
    answer: n * k,
    explanation: 'On partage $total en $d parts égales : $total ÷ $d = $k.\n'
        '${n == 1 ? 'On en prend 1 : $k.' : 'On en prend $n : $n × $k = ${n * k}.'}',
  );
}

Question _cm1Perimeter(int level, Random rng) {
  if (level <= 2) {
    final c = rnd(rng, 2, level == 1 ? 9 : 25);
    return Question(
      prompt: 'Un carré de côté $c cm.\nPérimètre = ? cm',
      answer: 4 * c,
      explanation: 'Un carré a 4 côtés égaux : 4 × $c = ${4 * c} cm.',
      allowTrueFalse: false,
    );
  }
  final l = rnd(rng, 4, 10 * (level - 1)), w = rnd(rng, 2, max(3, l - 1));
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
      final t = rnd(rng, 11, 99); // en dixièmes : 3,4 = 34 dixièmes
      return Question(
        prompt: '${fmtDec(t * 10)} × 10 = ?',
        answer: t,
        explanation: 'Multiplier par 10 : la virgule se décale d\'un rang vers la droite.\n'
            '${fmtDec(t * 10)} → $t.',
      );
    }
    case 2: {
      final c = rnd(rng, 101, 999);
      return Question(
        prompt: '${fmtDec(c)} × 100 = ?',
        answer: c,
        explanation: 'Multiplier par 100 : la virgule se décale de deux rangs vers la droite.\n'
            '${fmtDec(c)} → $c.',
      );
    }
    case 3: {
      final t = rnd(rng, 11, 99);
      return Question(
        prompt: 'Combien de dixièmes\ndans ${fmtDec(t * 10)} ?',
        answer: t,
        explanation: '1 unité = 10 dixièmes. ${fmtDec(t * 10)} = ${t ~/ 10} unités et ${t % 10} dixièmes\n'
            '= ${t ~/ 10} × 10 + ${t % 10} = $t dixièmes.',
        allowTrueFalse: false,
      );
    }
    case 4: {
      final a = rnd(rng, 1, 9), b = 10 - a;
      final e1 = rnd(rng, 0, 5), e2 = rnd(rng, 0, 4);
      return Question(
        prompt: '${fmtDec(e1 * 100 + a * 10)} + ${fmtDec(e2 * 100 + b * 10)} = ?',
        answer: e1 + e2 + 1,
        explanation: 'Les dixièmes : $a + $b = 10 dixièmes = 1 unité.\n'
            'Les unités : $e1 + $e2 + 1 = ${e1 + e2 + 1}.',
      );
    }
    default: {
      final x = rnd(rng, 11, 99) * 10; // dixièmes déguisés
      return Question(
        prompt: '${fmtDec(x)} × 1000 = ?',
        answer: x * 10,
        explanation: 'Multiplier par 1000 : la virgule avance de 3 rangs '
            '(on complète avec des zéros).\n${fmtDec(x)} → ${x * 10}.',
      );
    }
  }
}

Question _cm2Divide(int level, Random rng) {
  final d = switch (level) {
    1 => 2,
    2 => pick(rng, [4, 5]),
    3 => pick(rng, [3, 6]),
    _ => rnd(rng, 3, 9),
  };
  final q = switch (level) {
    1 => rnd(rng, 11, 49),
    2 => rnd(rng, 21, 99),
    3 => rnd(rng, 21, 99),
    4 => rnd(rng, 101, 199),
    _ => rnd(rng, 101, 333),
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
    1 => (50, rnd(rng, 2, 50) * 2),
    2 => (10, rnd(rng, 2, 50) * 10),
    3 => (25, rnd(rng, 2, 25) * 4),
    4 => (pick(rng, [20, 30, 75]), rnd(rng, 2, 20) * 20),
    _ => (pick(rng, [5, 15, 40, 60]), rnd(rng, 2, 20) * 20),
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
  final unit = rnd(rng, 2, level <= 2 ? 5 : 12);
  final n1 = rnd(rng, 2, level <= 2 ? 4 : 6);
  var n2 = rnd(rng, 2, level >= 4 ? 15 : 10);
  if (n2 == n1) n2++;
  final (item, plural) = pick(rng, [
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
      final c = rnd(rng, 2, 9);
      return Question(
        prompt: 'Carré de côté $c cm.\nAire = ? cm²',
        answer: c * c,
        explanation: 'Aire du carré = côté × côté = $c × $c = ${c * c} cm².',
        allowTrueFalse: false,
      );
    }
    case 2:
    case 3: {
      final l = rnd(rng, 3, level == 2 ? 9 : 20), w = rnd(rng, 2, 9);
      return Question(
        prompt: 'Rectangle de $l cm sur $w cm.\nAire = ? cm²',
        answer: l * w,
        explanation: 'Aire du rectangle = longueur × largeur = $l × $w = ${l * w} cm².',
        allowTrueFalse: false,
      );
    }
    case 4: {
      final b = rnd(rng, 2, 10) * 2, h = rnd(rng, 3, 12);
      return Question(
        prompt: 'Triangle rectangle :\ncôtés de l\'angle droit $b cm et $h cm.\nAire = ? cm²',
        answer: b * h ~/ 2,
        explanation: 'C\'est la moitié d\'un rectangle $b × $h :\n'
            '($b × $h) ÷ 2 = ${b * h} ÷ 2 = ${b * h ~/ 2} cm².',
        allowTrueFalse: false,
      );
    }
    default: {
      final area = pick(rng, [24, 36, 48, 60, 72]);
      final l = pick(rng, [for (var x = 3; x <= 12; x++) if (area % x == 0) x]);
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

// ---------------- CM1 (suite) ----------------
Question _cm1Angles(int level, Random rng) {
  switch (level) {
    case 1:
      return const Question(
        prompt: 'Un angle droit mesure ? °',
        answer: 90,
        explanation: 'Un angle droit mesure 90°, comme le coin d\'une feuille.',
        allowTrueFalse: false,
      );
    case 2:
      return const Question(
        prompt: 'Un demi-tour mesure ? °',
        answer: 180,
        explanation: 'Un tour complet fait 360°, donc un demi-tour fait 180° (2 angles droits).',
        allowTrueFalse: false,
      );
    case 3: {
      final a = rnd(rng, 2, 8) * 10;
      return Question(
        prompt: 'Combien faut-il ajouter à $a°\npour faire un angle droit ?',
        answer: 90 - a,
        explanation: 'Un angle droit = 90°. 90 − $a = ${90 - a}°.',
        allowTrueFalse: false,
      );
    }
    default: {
      final a = rnd(rng, 1, 17) * 10;
      final kind = a < 90 ? 'aigu' : (a == 90 ? 'droit' : 'obtus');
      return Question.text(
        prompt: 'Un angle de $a° est...',
        answer: kind,
        choices: const ['aigu', 'droit', 'obtus', 'plat'],
        explanation: 'Aigu : moins de 90°. Droit : 90°. Obtus : entre 90° et 180°. '
            'Plat : 180°. Ici $a° → $kind.',
      );
    }
  }
}

// ---------------- CM2 (suite) ----------------
Question _cm2Algebra(int level, Random rng) {
  final x = rnd(rng, 2, 9 + 4 * level);
  switch (level) {
    case 1: {
      final a = rnd(rng, 2, 20);
      return Question(
        prompt: '? + $a = ${x + a}',
        answer: x,
        explanation: 'Pour trouver le nombre caché, on enlève $a : ${x + a} − $a = $x.',
        allowTrueFalse: false,
      );
    }
    case 2: {
      final a = rnd(rng, 2, 9);
      return Question(
        prompt: '? × $a = ${x * a}',
        answer: x,
        explanation: 'On divise : ${x * a} ÷ $a = $x.',
        allowTrueFalse: false,
      );
    }
    case 3: {
      final a = rnd(rng, 2, 30);
      return Question(
        prompt: '? − $a = $x',
        answer: x + a,
        explanation: 'On fait l\'opération inverse : $x + $a = ${x + a}.',
        allowTrueFalse: false,
      );
    }
    default: {
      final a = rnd(rng, 2, 6), b = rnd(rng, 1, 15);
      return Question(
        prompt: '$a × ? + $b = ${a * x + b}',
        answer: x,
        explanation: 'On enlève d\'abord $b : ${a * x + b} − $b = ${a * x}.\n'
            'Puis on divise par $a : ${a * x} ÷ $a = $x.',
        allowTrueFalse: false,
      );
    }
  }
}

// ---------------- 6e ----------------
Question _sixiemeDecimals(int level, Random rng) {
  switch (level) {
    case 1: {
      // 2,5 + 1,3 (dixièmes)
      final a = rnd(rng, 11, 59), b = rnd(rng, 11, 39);
      final r = (a + b) * 10;
      return Question.text(
        prompt: '${fmtDec(a * 10)} + ${fmtDec(b * 10)} = ?',
        answer: fmtDec(r),
        choices: decimalChoices(r, rng),
        explanation: 'On aligne les virgules : unités avec unités, dixièmes avec dixièmes.\n'
            '${fmtDec(a * 10)} + ${fmtDec(b * 10)} = ${fmtDec(r)}.',
      );
    }
    case 2: {
      final a = rnd(rng, 150, 900), b = rnd(rng, 25, a - 50);
      return Question.text(
        prompt: '${fmtDec(a)} − ${fmtDec(b)} = ?',
        answer: fmtDec(a - b),
        choices: decimalChoices(a - b, rng),
        explanation: 'On pose en alignant les virgules (complète avec des 0 si besoin).\n'
            '${fmtDec(a)} − ${fmtDec(b)} = ${fmtDec(a - b)}.',
      );
    }
    case 3: {
      final a = rnd(rng, 11, 99), k = rnd(rng, 2, 9);
      return Question.text(
        prompt: '${fmtDec(a * 10)} × $k = ?',
        answer: fmtDec(a * 10 * k),
        choices: decimalChoices(a * 10 * k, rng),
        explanation: 'On calcule $a × $k = ${a * k}, puis on remet 1 chiffre après la virgule : '
            '${fmtDec(a * 10 * k)}.',
      );
    }
    case 4: {
      final a = rnd(rng, 101, 999);
      return Question(
        prompt: '${fmtDec(a)} × 100 = ?',
        answer: a,
        explanation: '× 100 : la virgule se décale de 2 rangs vers la droite. ${fmtDec(a)} → $a.',
      );
    }
    default: {
      final a = rnd(rng, 11, 99) * 10, b = a + pick<int>(rng, [1, 9, 10, 90]);
      final pool = [fmtDec(a), fmtDec(b)];
      final big = fmtDec(max(a, b));
      return Question.text(
        prompt: 'Quel est le plus grand ?',
        answer: big,
        choices: [...pool, fmtDec(a - 1), fmtDec(a - 2)],
        explanation: 'On compare la partie entière, puis les dixièmes, puis les centièmes. '
            'Le plus grand est $big.',
      );
    }
  }
}

Question _sixiemeFractions(int level, Random rng) {
  switch (level) {
    case 1:
    case 2: {
      final d = rnd(rng, 2, level == 1 ? 5 : 9), q = rnd(rng, 2, 12);
      return Question(
        prompt: '${frac(d * q, d)} = ?',
        answer: q,
        explanation: 'Une fraction est un quotient : ${frac(d * q, d)} = ${d * q} ÷ $d = $q.',
      );
    }
    case 3: {
      final d = rnd(rng, 3, 8), n = rnd(rng, 2, d - 1), k = rnd(rng, 2, 8);
      return Question(
        prompt: '${frac(n, d)} de ${d * k} = ?',
        answer: n * k,
        explanation: '${frac(n, d)} de ${d * k} = (${d * k} ÷ $d) × $n = $k × $n = ${n * k}.',
      );
    }
    case 4: {
      final d = rnd(rng, 2, 6), n = rnd(rng, 1, d - 1), k = rnd(rng, 2, 5);
      return Question(
        prompt: '${frac(n, d)} = \\frac{${n * k}}{?}',
        answer: d * k,
        explanation: 'Le numérateur a été multiplié par $k, donc le dénominateur aussi : $d × $k = ${d * k}.',
        allowTrueFalse: false,
      );
    }
    default: {
      final d = rnd(rng, 3, 9), a = rnd(rng, 1, d - 1), b = rnd(rng, 1, d);
      return Question(
        prompt: '${frac(a, d)} + ${frac(b, d)} = \\frac{?}{$d}',
        answer: a + b,
        explanation: 'Même dénominateur : on additionne les numérateurs. $a + $b = ${a + b}, '
            'donc ${frac(a + b, d)}.',
        allowTrueFalse: false,
      );
    }
  }
}

Question _sixiemeExpressions(int level, Random rng) {
  final x = rnd(rng, 1, 3 + 2 * level);
  switch (level) {
    case 1: {
      final a = rnd(rng, 2, 9);
      return Question(
        prompt: 'Pour x = $x,\nx + $a = ?',
        answer: x + a,
        explanation: 'On remplace x par $x : $x + $a = ${x + a}.',
        allowTrueFalse: false,
      );
    }
    case 2: {
      final a = rnd(rng, 2, 9);
      return Question(
        prompt: 'Pour x = $x,\n${a}x = ?',
        answer: a * x,
        explanation: '${a}x veut dire $a × x : $a × $x = ${a * x}.',
        allowTrueFalse: false,
      );
    }
    case 3: {
      final a = rnd(rng, 2, 9), b = rnd(rng, 1, 20);
      return Question(
        prompt: 'Pour x = $x,\n${a}x + $b = ?',
        answer: a * x + b,
        explanation: 'On multiplie d\'abord : $a × $x = ${a * x}, puis on ajoute $b : ${a * x + b}.',
        allowTrueFalse: false,
      );
    }
    default: {
      final a = rnd(rng, 2, 6), b = rnd(rng, 1, 9);
      return Question(
        prompt: 'Pour x = $x,\n$a × (x + $b) = ?',
        answer: a * (x + b),
        explanation: 'Les parenthèses d\'abord : $x + $b = ${x + b}, puis $a × ${x + b} = ${a * (x + b)}.',
        allowTrueFalse: false,
      );
    }
  }
}

Question _sixiemeAreaVolume(int level, Random rng) {
  switch (level) {
    case 1:
    case 2: {
      final b = rnd(rng, 2, 10) * 2, h = rnd(rng, 2, 12);
      return Question(
        prompt: 'Triangle de base $b cm\net de hauteur $h cm.\nAire = ? cm²',
        answer: b * h ~/ 2,
        explanation: 'Aire du triangle = (base × hauteur) ÷ 2 = ($b × $h) ÷ 2 = ${b * h ~/ 2} cm².',
        allowTrueFalse: false,
      );
    }
    case 3: {
      final c = rnd(rng, 2, 6);
      return Question(
        prompt: 'Cube d\'arête $c cm.\nVolume = ? cm³',
        answer: c * c * c,
        explanation: 'Volume du cube = arête × arête × arête = $c × $c × $c = ${c * c * c} cm³.',
        allowTrueFalse: false,
      );
    }
    case 4: {
      final l = rnd(rng, 2, 10), w = rnd(rng, 2, 6), h = rnd(rng, 2, 5);
      return Question(
        prompt: 'Pavé droit : $l cm × $w cm × $h cm.\nVolume = ? cm³',
        answer: l * w * h,
        explanation: 'Volume = longueur × largeur × hauteur = $l × $w × $h = ${l * w * h} cm³.',
        allowTrueFalse: false,
      );
    }
    default: {
      final dm = rnd(rng, 2, 9);
      return Question(
        prompt: '$dm dm³ = ? L',
        answer: dm,
        explanation: '1 dm³ = 1 L (un cube de 10 cm de côté contient 1 litre). Donc $dm dm³ = $dm L.',
        allowTrueFalse: false,
      );
    }
  }
}

Question _sixiemeTriangleAngles(int level, Random rng) {
  if (level == 1) {
    return const Question(
      prompt: 'La somme des angles\nd\'un triangle vaut ? °',
      answer: 180,
      explanation: 'Dans tout triangle, la somme des trois angles vaut 180°.',
      allowTrueFalse: false,
    );
  }
  if (level == 2) {
    final a = rnd(rng, 2, 7) * 10;
    return Question(
      prompt: 'Triangle rectangle :\nun angle aigu mesure $a°.\nL\'autre mesure ? °',
      answer: 90 - a,
      explanation: '180 − 90 (angle droit) − $a = ${90 - a}°.',
      allowTrueFalse: false,
    );
  }
  final a = rnd(rng, 3, 9) * 10 + (level >= 4 ? rnd(rng, 1, 9) : 0);
  final b = rnd(rng, 2, (170 - a) ~/ 10) * 10;
  return Question(
    prompt: 'Un triangle a deux angles\nde $a° et $b°.\nLe 3e mesure ? °',
    answer: 180 - a - b,
    explanation: '180 − $a − $b = ${180 - a - b}°.',
    allowTrueFalse: false,
  );
}

Question _sixiemeSymmetry(int level, Random rng) {
  final range = level <= 2 ? 4 : 5;
  var x = rnd(rng, 1, range), y = rnd(rng, -range, range);
  final vertical = level <= 3 || rng.nextBool();
  if (vertical) {
    // symétrie par rapport à l'axe des ordonnées
    return Question.graph(
      prompt: 'A($x ; $y). Place son symétrique\npar rapport à l\'axe vertical.',
      graph: GraphSpec.grid(range: range, x: -x, y: y),
      explanation: 'Par rapport à l\'axe vertical, on garde la même hauteur ($y) '
          'et on va de l\'autre côté à la même distance : (${-x} ; $y).',
    );
  }
  y = y == 0 ? 2 : y;
  return Question.graph(
    prompt: 'A($y ; $x). Place son symétrique\npar rapport à l\'axe horizontal.',
    graph: GraphSpec.grid(range: range, x: y, y: -x),
    explanation: 'Par rapport à l\'axe horizontal, on garde la même abscisse ($y) '
        'et l\'ordonnée change de signe : ($y ; ${-x}).',
  );
}
