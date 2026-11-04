import 'dart:math';

import 'package:flutter/material.dart';

import 'cycle.dart';
import 'helpers.dart';

// =====================================================================
//  CYCLE 4 : 5e, 4e, 3e  (programme du cycle 4)
//  Nombres et calculs (relatifs, rationnels, puissances, racines,
//  calcul littéral), géométrie (repérage, triangles, Pythagore, Thalès),
//  statistiques et probabilités, proportionnalité et fonctions.
// =====================================================================

final cycle4 = School(
  id: 'cycle4',
  title: 'Cycle 4',
  subtitle: '5e · 4e · 3e',
  emoji: '📐',
  color: Color(0xFF16355F),
  grades: [cinquieme, quatrieme, troisieme],
);

const _navy = Color(0xFF16355F);
const _blue = Color(0xFF2A5C96);
const _orange = Color(0xFFFF8C38);
const _teal = Color(0xFF00A6A6);
const _purple = Color(0xFF8E5CD9);
const _red = Color(0xFFE5484D);
const _green = Color(0xFF3FA34D);

String _p(int n) => n < 0 ? '($n)' : '$n';
String _sgn(int n) => n < 0 ? '− ${-n}' : '+ $n';
int _nz(Random rng, int a, int b) {
  var v = 0;
  while (v == 0) {
    v = rnd(rng, a, b);
  }
  return v;
}

// =====================================================================
//  CINQUIÈME
// =====================================================================
final cinquieme = Cycle(
  id: '5e',
  title: '5e',
  subtitle: 'Relatifs, priorités, repérage',
  emoji: '📗',
  color: _blue,
  chapters: [
    Chapter(
      id: '5e_rel', title: 'Nombres relatifs', subtitle: 'Additions et soustractions',
      emoji: '±', color: _blue, monster: '🧊', monsterName: 'Glaçon Négatif',
      generate: _relatives,
    ),
    Chapter(
      id: '5e_prio', title: 'Priorités opératoires', subtitle: '× avant +',
      emoji: '🧮', color: _orange, monster: '🤹', monsterName: 'Le Jongleur',
      generate: _priorities,
    ),
    Chapter(
      id: '5e_frac', title: 'Fractions', subtitle: 'Même dénominateur, simplifier',
      emoji: '🍕', color: _red, monster: '🍕', monsterName: 'Pizzator',
      generate: _fractions5,
    ),
    Chapter(
      id: '5e_rep', title: 'Repérage dans le plan', subtitle: 'Abscisse et ordonnée',
      emoji: '🗺️', color: _teal, monster: '🏴‍☠️', monsterName: 'Capitaine Coordonnées',
      generate: (l, r) => gridPointQ(r, l <= 2 ? 4 : 6, negatives: l >= 2),
      exerciseOnly: true,
    ),
    Chapter(
      id: '5e_line', title: 'Relatifs sur la droite', subtitle: 'Placer un nombre négatif',
      emoji: '📏', color: _purple, monster: '🐌', monsterName: 'Escargot Rapide',
      generate: _relativeLine,
      exerciseOnly: true,
    ),
    Chapter(
      id: '5e_stat', title: 'Moyenne', subtitle: 'Statistiques',
      emoji: '📊', color: _green, monster: '📈', monsterName: 'Graphix',
      generate: _mean,
    ),
  ],
  boss: const Chapter.boss(id: 'boss_5e', monster: '🦑', monsterName: 'Le Kraken'),
);

// =====================================================================
//  QUATRIÈME
// =====================================================================
final quatrieme = Cycle(
  id: '4e',
  title: '4e',
  subtitle: 'Puissances, Pythagore, équations',
  emoji: '📙',
  color: _navy,
  chapters: [
    Chapter(
      id: '4e_mulrel', title: 'Produits de relatifs', subtitle: 'Règle des signes',
      emoji: '✖️', color: _blue, monster: '🧲', monsterName: 'Aimant Signé',
      generate: _relativeProducts,
    ),
    Chapter(
      id: '4e_pow', title: 'Puissances', subtitle: 'a^{n}, puissances de 10',
      emoji: '⚡', color: _orange, monster: '⚡', monsterName: 'Électro',
      generate: _powers,
    ),
    Chapter(
      id: '4e_pyth', title: 'Théorème de Pythagore', subtitle: 'Triangle rectangle',
      emoji: '📐', color: _purple, monster: '🏛️', monsterName: 'Pythagore',
      generate: _pythagoras,
    ),
    Chapter(
      id: '4e_lit', title: 'Calcul littéral', subtitle: 'Développer, réduire',
      emoji: '🔣', color: _teal, monster: '🧩', monsterName: 'Le Sphinx',
      generate: _literal,
    ),
    Chapter(
      id: '4e_eq', title: 'Équations', subtitle: 'Résoudre ax + b = c',
      emoji: '🔎', color: _red, monster: '🕵️', monsterName: 'Monsieur X',
      generate: _equations,
    ),
    Chapter(
      id: '4e_proba', title: 'Probabilités', subtitle: 'Dés, urnes, cartes',
      emoji: '🎲', color: _green, monster: '🎰', monsterName: 'Le Hasard',
      generate: _probability,
    ),
  ],
  boss: const Chapter.boss(id: 'boss_4e', monster: '🐉', monsterName: 'Le Dragon Algébrique'),
);

// =====================================================================
//  TROISIÈME
// =====================================================================
final troisieme = Cycle(
  id: '3e',
  title: '3e',
  subtitle: 'Brevet : fonctions, racines, Thalès',
  emoji: '📕',
  color: _red,
  chapters: [
    Chapter(
      id: '3e_sqrt', title: 'Racines carrées', subtitle: '\\sqrt{}',
      emoji: '√', color: _blue, monster: '🌳', monsterName: 'Racine Ancienne',
      generate: _squareRoots,
    ),
    Chapter(
      id: '3e_arith', title: 'Diviseurs et PGCD', subtitle: 'Arithmétique',
      emoji: '🔢', color: _orange, monster: '🧱', monsterName: 'Le Diviseur',
      generate: _arithmetic,
    ),
    Chapter(
      id: '3e_func', title: 'Fonctions affines', subtitle: 'f(x) = ax + b',
      emoji: '📈', color: _purple, monster: '📉', monsterName: 'Courbix',
      generate: _affine,
    ),
    Chapter(
      id: '3e_id', title: 'Identités remarquables', subtitle: '(a + b)^{2}',
      emoji: '✨', color: _teal, monster: '🪄', monsterName: 'Le Magicien',
      generate: _identities,
    ),
    Chapter(
      id: '3e_thales', title: 'Théorème de Thalès', subtitle: 'Agrandissement',
      emoji: '🔺', color: _red, monster: '🏺', monsterName: 'Thalès',
      generate: _thales,
    ),
    Chapter(
      id: '3e_vec', title: 'Translations', subtitle: 'Déplacer un point',
      emoji: '➡️', color: _green, monster: '🚀', monsterName: 'Vectorix',
      generate: _translation,
      exerciseOnly: true,
    ),
  ],
  boss: const Chapter.boss(id: 'boss_3e', monster: '🐲', monsterName: 'Le Dragon du Brevet'),
);

// =====================================================================
//  GÉNÉRATEURS — 5e
// =====================================================================
Question _relatives(int level, Random rng) {
  final limit = 4 + 3 * level;
  final a = _nz(rng, -limit, limit), b = _nz(rng, -limit, limit);
  if (level >= 3 && rng.nextBool()) {
    final r = a - b;
    return Question(
      prompt: '${_p(a)} − ${_p(b)} = ?',
      answer: r,
      explanation: 'Soustraire, c\'est ajouter l\'opposé :\n'
          '${_p(a)} − ${_p(b)} = ${_p(a)} + ${_p(-b)} = $r.',
    );
  }
  final r = a + b;
  final same = (a > 0) == (b > 0);
  return Question(
    prompt: '${_p(a)} + ${_p(b)} = ?',
    answer: r,
    explanation: same
        ? 'Même signe : on additionne les distances à zéro et on garde le signe → $r.'
        : 'Signes contraires : on soustrait les distances à zéro '
            '(${max(a.abs(), b.abs())} − ${min(a.abs(), b.abs())}) et on garde '
            'le signe du plus éloigné de zéro → $r.',
  );
}

Question _priorities(int level, Random rng) {
  final a = rnd(rng, 2, 9), b = rnd(rng, 2, 9), c = rnd(rng, 2, 9);
  switch (level) {
    case 1:
      return Question(
        prompt: '$a + $b × $c = ?',
        answer: a + b * c,
        explanation: 'La multiplication est prioritaire : $b × $c = ${b * c}, puis $a + ${b * c} = ${a + b * c}.',
      );
    case 2:
      return Question(
        prompt: '($a + $b) × $c = ?',
        answer: (a + b) * c,
        explanation: 'Les parenthèses d\'abord : $a + $b = ${a + b}, puis × $c = ${(a + b) * c}.',
      );
    case 3: {
      final big = a * b + c;
      return Question(
        prompt: '$big − $a × $b = ?',
        answer: c,
        explanation: '× d\'abord : $a × $b = ${a * b}, puis $big − ${a * b} = $c.',
      );
    }
    default: {
      final d = rnd(rng, 2, 5);
      final r = a * b - c * d;
      return Question(
        prompt: '$a × $b − $c × $d = ?',
        answer: r,
        explanation: 'On calcule les deux produits : ${a * b} et ${c * d}, puis ${a * b} − ${c * d} = $r.',
      );
    }
  }
}

Question _fractions5(int level, Random rng) {
  final d = rnd(rng, 3, 9 + level);
  if (level <= 2) {
    final a = rnd(rng, 1, d), b = rnd(rng, 1, d);
    return Question(
      prompt: '${frac(a, d)} + ${frac(b, d)} = \\frac{?}{$d}',
      answer: a + b,
      explanation: 'Même dénominateur : on additionne les numérateurs ($a + $b = ${a + b}) '
          'et on garde $d.',
      allowTrueFalse: false,
    );
  }
  if (level == 3) {
    final n = rnd(rng, 1, 9), k = rnd(rng, 2, 6);
    return Question(
      prompt: '${frac(n * k, d * k)} = \\frac{?}{$d}',
      answer: n,
      explanation: 'On simplifie en divisant le haut et le bas par $k : ${frac(n, d)}.',
      allowTrueFalse: false,
    );
  }
  // fraction d'une quantité / comparer
  final n = rnd(rng, 1, d - 1), k = rnd(rng, 2, 9);
  return Question(
    prompt: '${frac(n, d)} × ${d * k} = ?',
    answer: n * k,
    explanation: '${frac(n, d)} × ${d * k} = $n × (${d * k} ÷ $d) = $n × $k = ${n * k}.',
  );
}

Question _relativeLine(int level, Random rng) {
  final range = level <= 2 ? 5 : 10;
  final v = _nz(rng, -range, range);
  return Question.graph(
    prompt: 'Place le nombre $v\nsur la droite graduée.',
    graph: GraphSpec.numberLine(
      min: -range.toDouble(),
      max: range.toDouble(),
      divisions: 2 * range,
      targetTick: v + range,
      labels: {0: '${-range}', range: '0', 2 * range: '$range'},
    ),
    explanation: 'Les nombres négatifs sont à gauche de 0. '
        '$v est à ${v.abs()} graduation(s) ${v < 0 ? 'à gauche' : 'à droite'} de 0.',
  );
}

Question _mean(int level, Random rng) {
  final n = level <= 2 ? 3 : (level <= 4 ? 4 : 5);
  final m = rnd(rng, 8, 15);
  // On fabrique des notes dont la moyenne tombe juste.
  var vals = <int>[];
  var last = -1;
  while (last < 0 || last > 20) {
    vals = [for (var i = 0; i < n - 1; i++) m + rnd(rng, -4, 4)];
    last = m * n - vals.fold(0, (a, b) => a + b);
  }
  vals.add(last);
  final sum = m * n;
  return Question(
    prompt: 'Notes : ${vals.join(' ; ')}\nMoyenne = ?',
    answer: m,
    explanation: 'Moyenne = somme ÷ nombre de valeurs = $sum ÷ $n = $m.',
    allowTrueFalse: false,
  );
}

// =====================================================================
//  GÉNÉRATEURS — 4e
// =====================================================================
Question _relativeProducts(int level, Random rng) {
  final a = _nz(rng, -9, 9), b = _nz(rng, -9, 9);
  if (level >= 4) {
    final p = a * b;
    return Question(
      prompt: '${_p(p)} ÷ ${_p(b)} = ?',
      answer: a,
      explanation: 'Même règle que pour × : signes identiques → positif, '
          'signes contraires → négatif. ${_p(p)} ÷ ${_p(b)} = $a.',
    );
  }
  if (level == 3) {
    final c = _nz(rng, -5, 5);
    return Question(
      prompt: '${_p(a)} × ${_p(b)} × ${_p(c)} = ?',
      answer: a * b * c,
      explanation: 'On compte les facteurs négatifs : un nombre pair → positif, '
          'impair → négatif. Résultat : ${a * b * c}.',
    );
  }
  return Question(
    prompt: '${_p(a)} × ${_p(b)} = ?',
    answer: a * b,
    explanation: 'Règle des signes : (−) × (−) = (+) et (−) × (+) = (−).\n'
        '${a.abs()} × ${b.abs()} = ${(a * b).abs()}, donc ${a * b}.',
  );
}

Question _powers(int level, Random rng) {
  switch (level) {
    case 1: {
      final a = rnd(rng, 2, 5), n = rnd(rng, 2, 3);
      return Question(
        prompt: '$a^{$n} = ?',
        answer: pow(a, n).toInt(),
        explanation: '$a^{$n} = ${List.filled(n, '$a').join(' × ')} = ${pow(a, n).toInt()}.',
      );
    }
    case 2: {
      final n = rnd(rng, 2, 6);
      return Question(
        prompt: '10^{$n} = ?',
        answer: pow(10, n).toInt(),
        explanation: '10^{$n} = 1 suivi de $n zéros = ${fmtInt(pow(10, n).toInt())}.',
      );
    }
    case 3: {
      final a = rnd(rng, 2, 3), m = rnd(rng, 2, 4), n = rnd(rng, 2, 4);
      return Question(
        prompt: '$a^{$m} × $a^{$n} = $a^{?}',
        answer: m + n,
        explanation: 'On additionne les exposants : a^{m} × a^{n} = a^{m+n}, donc $m + $n = ${m + n}.',
        allowTrueFalse: false,
      );
    }
    case 4: {
      final m = rnd(rng, 5, 9), n = rnd(rng, 1, 4);
      return Question(
        prompt: '\\frac{10^{$m}}{10^{$n}} = 10^{?}',
        answer: m - n,
        explanation: 'On soustrait les exposants : $m − $n = ${m - n}.',
        allowTrueFalse: false,
      );
    }
    default: {
      final a = _nz(rng, -3, 3), n = rnd(rng, 2, 4);
      return Question(
        prompt: '($a)^{$n} = ?',
        answer: pow(a, n).toInt(),
        explanation: 'Un nombre négatif à une puissance paire donne un résultat positif, '
            'impaire → négatif. ($a)^{$n} = ${pow(a, n).toInt()}.',
      );
    }
  }
}

const _triples = [(3, 4, 5), (6, 8, 10), (5, 12, 13), (8, 15, 17), (9, 12, 15), (12, 16, 20), (7, 24, 25)];

Question _pythagoras(int level, Random rng) {
  final (a0, b0, c0) = pick(rng, level <= 2 ? _triples.sublist(0, 3) : _triples);
  if (level <= 3) {
    return Question(
      prompt: 'Triangle rectangle :\ncôtés de l\'angle droit $a0 cm et $b0 cm.\nHypoténuse = ? cm',
      answer: c0,
      explanation: 'Pythagore : hypoténuse^{2} = $a0^{2} + $b0^{2} = ${a0 * a0} + ${b0 * b0} = ${c0 * c0}.\n'
          'Donc hypoténuse = \\sqrt{${c0 * c0}} = $c0 cm.',
      allowTrueFalse: false,
    );
  }
  return Question(
    prompt: 'Triangle rectangle :\nhypoténuse $c0 cm, un côté $a0 cm.\nL\'autre côté = ? cm',
    answer: b0,
    explanation: 'Côté^{2} = $c0^{2} − $a0^{2} = ${c0 * c0} − ${a0 * a0} = ${b0 * b0}.\n'
        'Donc côté = \\sqrt{${b0 * b0}} = $b0 cm.',
    allowTrueFalse: false,
  );
}

Question _literal(int level, Random rng) {
  final k = rnd(rng, 2, 9), a = _nz(rng, -9, 9);
  switch (level) {
    case 1: {
      final b = rnd(rng, 2, 9);
      return Question(
        prompt: '${k}x + ${b}x = ?x',
        answer: k + b,
        explanation: 'On réduit : $k x + $b x = ${k + b} x (comme $k pommes + $b pommes).',
        allowTrueFalse: false,
      );
    }
    case 2:
      return Question(
        prompt: '$k(x ${_sgn(a)}) = ${k}x + ?',
        answer: k * a,
        explanation: 'On distribue : $k × x + $k × ${_p(a)} = ${k}x ${_sgn(k * a)}.',
        allowTrueFalse: false,
      );
    case 3: {
      final x = _nz(rng, -5, 5);
      return Question(
        prompt: 'Pour x = $x,\n${k}x ${_sgn(a)} = ?',
        answer: k * x + a,
        explanation: 'On remplace x : $k × ${_p(x)} ${_sgn(a)} = ${k * x} ${_sgn(a)} = ${k * x + a}.',
      );
    }
    default: {
      final b = _nz(rng, -6, 6);
      return Question(
        prompt: '(x ${_sgn(a)})(x ${_sgn(b)}) = x^{2} + ?x + ${a * b}',
        answer: a + b,
        explanation: 'On développe : x × x + x × ${_p(b)} + ${_p(a)} × x + ${_p(a)} × ${_p(b)}\n'
            '= x^{2} ${_sgn(a + b)}x ${_sgn(a * b)}.',
        allowTrueFalse: false,
      );
    }
  }
}

Question _equations(int level, Random rng) {
  final x = level >= 4 ? _nz(rng, -9, 9) : rnd(rng, 1, 12);
  final a = level == 1 ? 1 : rnd(rng, 2, 9);
  final b = level <= 2 ? rnd(rng, 1, 20) : _nz(rng, -20, 20);
  final c = a * x + b;
  if (level == 5) {
    final d = rnd(rng, 1, a - 1);
    final e = (a - d) * x + b;
    return Question(
      prompt: '${a}x ${_sgn(b)} = ${d == 1 ? '' : d}x ${_sgn(e)}\nx = ?',
      answer: x,
      explanation: 'On regroupe les x à gauche et les nombres à droite :\n'
          '${a}x − ${d}x = ${_p(e)} − ${_p(b)}, soit ${a - d}x = ${e - b}.\n'
          'Donc x = ${e - b} ÷ ${a - d} = $x.',
      allowTrueFalse: false,
    );
  }
  final left = '${a == 1 ? '' : a}x ${_sgn(b)}';
  return Question(
    prompt: '$left = $c\nx = ?',
    answer: x,
    explanation: 'On enlève ${_p(b)} des deux côtés : ${a == 1 ? '' : a}x = ${c - b}.\n'
        '${a == 1 ? '' : 'On divise par $a : '}x = $x.\n'
        'Vérification : $a × ${_p(x)} ${_sgn(b)} = $c ✔',
    allowTrueFalse: false,
  );
}

Question _probability(int level, Random rng) {
  switch (level) {
    case 1:
    case 2: {
      final faces = rnd(rng, 1, 5);
      return Question.text(
        prompt: 'On lance un dé à 6 faces.\nProbabilité d\'obtenir\nun nombre ≤ $faces ?',
        answer: _reduced(faces, 6),
        choices: {_reduced(faces, 6), frac(faces, 10), frac(1, faces + 1), _reduced(6 - faces, 6), frac(faces, 12)}.toList(),
        explanation: 'Cas favorables : $faces sur 6 cas possibles → ${frac(faces, 6)}'
            '${gcd(faces, 6) > 1 ? ' = ${_reduced(faces, 6)}' : ''}.',
      );
    }
    default: {
      final red = rnd(rng, 1, 8), blue = rnd(rng, 1, 8);
      final total = red + blue;
      return Question.text(
        prompt: 'Une urne contient $red boules rouges\net $blue bleues. Probabilité\nde tirer une rouge ?',
        answer: _reduced(red, total),
        choices: {_reduced(red, total), _reduced(blue, total), frac(red, blue), frac(1, total), frac(red, total + 1), frac(red + 1, total), frac(blue, red)}.toList(),
        explanation: '$red boules rouges sur $total boules au total → ${frac(red, total)}'
            '${gcd(red, total) > 1 ? ' = ${_reduced(red, total)}' : ''}.',
      );
    }
  }
}

String _reduced(int n, int d) {
  final g = gcd(n, d);
  final rn = n ~/ g, rd = d ~/ g;
  return rd == 1 ? '$rn' : frac(rn, rd);
}

// =====================================================================
//  GÉNÉRATEURS — 3e
// =====================================================================
Question _squareRoots(int level, Random rng) {
  switch (level) {
    case 1:
    case 2: {
      final r = rnd(rng, 2, level == 1 ? 10 : 15);
      return Question(
        prompt: '\\sqrt{${r * r}} = ?',
        answer: r,
        explanation: '$r × $r = ${r * r}, donc \\sqrt{${r * r}} = $r.',
      );
    }
    case 3: {
      final r = rnd(rng, 2, 9), s = rnd(rng, 2, 9);
      return Question(
        prompt: '\\sqrt{${r * r}} × \\sqrt{${s * s}} = ?',
        answer: r * s,
        explanation: '\\sqrt{${r * r}} = $r et \\sqrt{${s * s}} = $s, donc $r × $s = ${r * s}.',
      );
    }
    case 4: {
      final a = rnd(rng, 2, 9);
      return Question(
        prompt: '(\\sqrt{$a})^{2} = ?',
        answer: a,
        explanation: 'Par définition, (\\sqrt{a})^{2} = a. Donc (\\sqrt{$a})^{2} = $a.',
      );
    }
    default: {
      final k = rnd(rng, 2, 6), n = pick(rng, [2, 3, 5]);
      return Question(
        prompt: '\\sqrt{${k * k * n}} = ?\\sqrt{$n}',
        answer: k,
        explanation: '${k * k * n} = ${k * k} × $n, donc \\sqrt{${k * k * n}} = \\sqrt{${k * k}} × \\sqrt{$n} = $k\\sqrt{$n}.',
        allowTrueFalse: false,
      );
    }
  }
}

Question _arithmetic(int level, Random rng) {
  if (level <= 2) {
    final n = pick(rng, [12, 18, 20, 24, 28, 30, 36]);
    final divs = [for (var i = 1; i <= n; i++) if (n % i == 0) i];
    return Question(
      prompt: 'Combien de diviseurs\na le nombre $n ?',
      answer: divs.length,
      explanation: 'Les diviseurs de $n : ${divs.join(', ')}. Il y en a ${divs.length}.',
      allowTrueFalse: false,
    );
  }
  final g = rnd(rng, 2, 12);
  var a = rnd(rng, 2, 9), b = rnd(rng, 2, 9);
  while (gcd(a, b) != 1 || a == b) {
    a = rnd(rng, 2, 9);
    b = rnd(rng, 2, 9);
  }
  return Question(
    prompt: 'PGCD(${a * g} ; ${b * g}) = ?',
    answer: g,
    explanation: '${a * g} = $g × $a et ${b * g} = $g × $b, avec $a et $b sans diviseur commun.\n'
        'Le plus grand diviseur commun est donc $g.',
    allowTrueFalse: false,
  );
}

Question _affine(int level, Random rng) {
  final a = _nz(rng, -5, 5), b = _nz(rng, -9, 9);
  final x = rnd(rng, -4, 5);
  final f = 'f(x) = ${a == 1 ? '' : a == -1 ? '−' : '$a'}x ${_sgn(b)}';
  switch (level) {
    case 1:
    case 2:
      return Question(
        prompt: '$f\nf($x) = ?',
        answer: a * x + b,
        explanation: 'On remplace x par ${_p(x)} : $a × ${_p(x)} ${_sgn(b)} = ${a * x + b}.',
        allowTrueFalse: false,
      );
    case 3:
      return Question(
        prompt: '$f\nCoefficient directeur = ?',
        answer: a,
        explanation: 'Pour f(x) = ax + b, le coefficient directeur est a = $a '
            '(et l\'ordonnée à l\'origine est b = $b).',
        allowTrueFalse: false,
      );
    default: {
      final y = a * x + b;
      return Question(
        prompt: '$f\nf(x) = $y pour x = ?',
        answer: x,
        explanation: 'On résout $a x ${_sgn(b)} = $y : ${a}x = ${y - b}, donc x = ${(y - b) ~/ a}.',
        allowTrueFalse: false,
      );
    }
  }
}

Question _identities(int level, Random rng) {
  final a = rnd(rng, 1, 9);
  switch (level) {
    case 1:
    case 2:
      return Question(
        prompt: '(x + $a)^{2} = x^{2} + ?x + ${a * a}',
        answer: 2 * a,
        explanation: '(a + b)^{2} = a^{2} + 2ab + b^{2}, donc le terme du milieu est 2 × x × $a = ${2 * a}x.',
        allowTrueFalse: false,
      );
    case 3:
      return Question(
        prompt: '(x − $a)^{2} = x^{2} − ${2 * a}x + ?',
        answer: a * a,
        explanation: '(a − b)^{2} = a^{2} − 2ab + b^{2}, donc le dernier terme est $a^{2} = ${a * a}.',
        allowTrueFalse: false,
      );
    case 4:
      return Question(
        prompt: '(x + $a)(x − $a) = x^{2} − ?',
        answer: a * a,
        explanation: '(a + b)(a − b) = a^{2} − b^{2}, donc x^{2} − $a^{2} = x^{2} − ${a * a}.',
        allowTrueFalse: false,
      );
    default: {
      final n = rnd(rng, 21, 99);
      return Question(
        prompt: '$n^{2} − ${n - 1}^{2} = ?',
        answer: n * n - (n - 1) * (n - 1),
        explanation: 'a^{2} − b^{2} = (a + b)(a − b) = ($n + ${n - 1}) × 1 = ${2 * n - 1}.',
      );
    }
  }
}

Question _thales(int level, Random rng) {
  final k = rnd(rng, 2, level <= 2 ? 3 : 5);
  final am = rnd(rng, 2, 9), an = rnd(rng, 2, 9);
  return Question(
    prompt: '(MN) // (BC), AM = $am, AB = ${am * k},\nAN = $an. Calcule AC = ?',
    answer: an * k,
    explanation: 'Thalès : \\frac{AM}{AB} = \\frac{AN}{AC}. Ici \\frac{$am}{${am * k}} = \\frac{1}{$k}, '
        'donc AC = $an × $k = ${an * k}.',
    allowTrueFalse: false,
  );
}

Question _translation(int level, Random rng) {
  final range = 6;
  final ax = rnd(rng, -3, 3), ay = rnd(rng, -3, 3);
  final ux = _nz(rng, -3, 3), uy = rnd(rng, -3, 3);
  return Question.graph(
    prompt: 'A($ax ; $ay). Place l\'image de A\npar la translation de vecteur u($ux ; $uy).',
    graph: GraphSpec.grid(range: range, x: ax + ux, y: ay + uy),
    explanation: 'On ajoute les coordonnées du vecteur : ($ax + ${_p(ux)} ; $ay + ${_p(uy)}) '
        '= (${ax + ux} ; ${ay + uy}).',
  );
}
