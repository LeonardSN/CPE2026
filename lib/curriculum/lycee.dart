import 'dart:math';

import 'package:flutter/material.dart';

import 'cycle.dart';
import 'helpers.dart';

// =====================================================================
//  LYCÉE : 2nde, 1re (spécialité), Terminale (spécialité)
//  D'après les programmes : automatismes, arithmétique, fonctions,
//  vecteurs, statistiques et probabilités (2nde) ; suites, second degré,
//  dérivation, exponentielle, trigonométrie, produit scalaire (1re) ;
//  dénombrement, logarithme, primitives et intégrales, loi binomiale (Tle).
// =====================================================================

final lycee = School(
  id: 'lycee',
  title: 'Lycée',
  subtitle: '2nde · 1re · Terminale',
  emoji: '🎓',
  color: Color(0xFF232323),
  grades: [seconde, premiere, terminale],
);

const _navy = Color(0xFF16355F);
const _blue = Color(0xFF2A5C96);
const _orange = Color(0xFFFF8C38);
const _teal = Color(0xFF00A6A6);
const _purple = Color(0xFF8E5CD9);
const _red = Color(0xFFE5484D);
const _green = Color(0xFF3FA34D);
const _ink = Color(0xFF232323);

String _p(int n) => n < 0 ? '($n)' : '$n';
String _sgn(int n) => n < 0 ? '− ${-n}' : '+ $n';
int _nz(Random rng, int a, int b) {
  var v = 0;
  while (v == 0) {
    v = rnd(rng, a, b);
  }
  return v;
}

String _coef(int a, String x, {bool first = false}) {
  final abs = a.abs();
  final body = abs == 1 ? x : '$abs$x';
  if (first) return a < 0 ? '−$body' : body;
  return a < 0 ? ' − $body' : ' + $body';
}

String _sub(int n) => '_{$n}';

int _fact(int n) => n <= 1 ? 1 : n * _fact(n - 1);
int _binom(int n, int k) => _fact(n) ~/ (_fact(k) * _fact(n - k));

// =====================================================================
//  SECONDE
// =====================================================================
final seconde = Cycle(
  id: '2nde',
  title: 'Seconde',
  subtitle: 'Fonctions, vecteurs, statistiques',
  emoji: '📓',
  color: _navy,
  chapters: [
    Chapter(
      id: '2de_auto', title: 'Automatismes', subtitle: 'Calcul mental, puissances',
      emoji: '⚡', color: _orange, monster: '⚡', monsterName: 'Électro',
      generate: _automatisms,
    ),
    Chapter(
      id: '2de_arith', title: 'Arithmétique', subtitle: 'Multiples, PGCD, premiers',
      emoji: '🔢', color: _blue, monster: '🧱', monsterName: 'Le Diviseur',
      generate: _arith2,
    ),
    Chapter(
      id: '2de_func', title: 'Fonctions', subtitle: 'Image, antécédent',
      emoji: '📈', color: _purple, monster: '📉', monsterName: 'Courbix',
      generate: _functions2,
    ),
    Chapter(
      id: '2de_vec', title: 'Vecteurs', subtitle: 'Coordonnées, somme',
      emoji: '➡️', color: _teal, monster: '🚀', monsterName: 'Vectorix',
      generate: _vectors2,
      exerciseOnly: true,
    ),
    Chapter(
      id: '2de_line', title: 'Droites', subtitle: 'Coefficient directeur',
      emoji: '📏', color: _red, monster: '📐', monsterName: 'L\'Équerre',
      generate: _lines2,
    ),
    Chapter(
      id: '2de_stat', title: 'Statistiques', subtitle: 'Moyenne, évolutions',
      emoji: '📊', color: _green, monster: '📈', monsterName: 'Graphix',
      generate: _stats2,
    ),
  ],
  boss: const Chapter.boss(id: 'boss_2de', monster: '🤖', monsterName: 'Le Robot de Seconde'),
);

// =====================================================================
//  PREMIÈRE
// =====================================================================
final premiere = Cycle(
  id: '1re',
  title: 'Première',
  subtitle: 'Spécialité mathématiques',
  emoji: '📔',
  color: _blue,
  chapters: [
    Chapter(
      id: '1re_suite', title: 'Suites', subtitle: 'Arithmétiques, géométriques',
      emoji: '🔢', color: _blue, monster: '🐍', monsterName: 'Le Serpent Infini',
      generate: _sequences,
    ),
    Chapter(
      id: '1re_deg2', title: 'Second degré', subtitle: 'Discriminant, racines',
      emoji: '🧮', color: _purple, monster: '🪐', monsterName: 'La Parabole',
      generate: _quadratic,
    ),
    Chapter(
      id: '1re_der', title: 'Dérivation', subtitle: 'Nombre dérivé',
      emoji: '📈', color: _orange, monster: '🌀', monsterName: 'La Tangente',
      generate: _derivative,
    ),
    Chapter(
      id: '1re_exp', title: 'Exponentielle', subtitle: 'e^{a} × e^{b}',
      emoji: '🚀', color: _red, monster: '🦠', monsterName: 'Croissance Folle',
      generate: _exponential,
    ),
    Chapter(
      id: '1re_trig', title: 'Trigonométrie', subtitle: 'Valeurs remarquables',
      emoji: '⭕', color: _teal, monster: '🎡', monsterName: 'Le Cercle',
      generate: _trigonometry,
    ),
    Chapter(
      id: '1re_scal', title: 'Produit scalaire', subtitle: 'Avec les coordonnées',
      emoji: '🎯', color: _green, monster: '🧭', monsterName: 'La Boussole',
      generate: _dotProduct,
    ),
  ],
  boss: const Chapter.boss(id: 'boss_1re', monster: '🤖', monsterName: 'Le Robot de Première'),
);

// =====================================================================
//  TERMINALE
// =====================================================================
final terminale = Cycle(
  id: 'tle',
  title: 'Terminale',
  subtitle: 'Spécialité · Bac',
  emoji: '🎓',
  color: _ink,
  chapters: [
    Chapter(
      id: 'tle_comb', title: 'Dénombrement', subtitle: 'n!, combinaisons',
      emoji: '🃏', color: _purple, monster: '🃏', monsterName: 'Le Joker',
      generate: _combinatorics,
    ),
    Chapter(
      id: 'tle_lim', title: 'Limites', subtitle: 'Suites et fonctions',
      emoji: '♾️', color: _blue, monster: '🌌', monsterName: 'L\'Infini',
      generate: _limits,
    ),
    Chapter(
      id: 'tle_ln', title: 'Logarithme', subtitle: 'ln(ab) = ln a + ln b',
      emoji: '🪵', color: _orange, monster: '🪵', monsterName: 'Bûche Logarithmique',
      generate: _logarithm,
    ),
    Chapter(
      id: 'tle_int', title: 'Intégrales', subtitle: 'Primitives et aires',
      emoji: '∫', color: _teal, monster: '🌊', monsterName: 'La Vague',
      generate: _integrals,
    ),
    Chapter(
      id: 'tle_bin', title: 'Loi binomiale', subtitle: 'Espérance, Bernoulli',
      emoji: '🎲', color: _green, monster: '🎰', monsterName: 'Le Hasard',
      generate: _binomial,
    ),
    Chapter(
      id: 'tle_space', title: 'Géométrie dans l\'espace', subtitle: 'Vecteurs 3D',
      emoji: '🧊', color: _red, monster: '🛸', monsterName: 'L\'OVNI',
      generate: _space,
    ),
  ],
  boss: const Chapter.boss(id: 'boss_tle', monster: '🐲', monsterName: 'Le Dragon du Bac'),
);

// =====================================================================
//  GÉNÉRATEURS — 2nde
// =====================================================================
Question _automatisms(int level, Random rng) {
  switch (level) {
    case 1: {
      final p = pick(rng, [10, 20, 25, 50]), n = rnd(rng, 2, 20) * 20;
      return Question(
        prompt: '$p % de $n = ?',
        answer: p * n ~/ 100,
        explanation: '$p % de $n = $n × \\frac{$p}{100} = ${p * n ~/ 100}.',
      );
    }
    case 2: {
      final a = rnd(rng, 2, 5), m = rnd(rng, 2, 5), n = rnd(rng, 2, 4);
      return Question(
        prompt: '($a^{$m})^{$n} = $a^{?}',
        answer: m * n,
        explanation: '(a^{m})^{n} = a^{m×n}, donc l\'exposant est $m × $n = ${m * n}.',
        allowTrueFalse: false,
      );
    }
    case 3: {
      final k = rnd(rng, 2, 9);
      return Question(
        prompt: '\\frac{1}{2} + \\frac{1}{$k} = \\frac{?}{${2 * k}}',
        answer: k + 2,
        explanation: 'Dénominateur commun ${2 * k} : \\frac{$k}{${2 * k}} + \\frac{2}{${2 * k}} = \\frac{${k + 2}}{${2 * k}}.',
        allowTrueFalse: false,
      );
    }
    case 4: {
      final t = pick(rng, [10, 20, 25, 50]), n = rnd(rng, 1, 10) * 20;
      final r = n + n * t ~/ 100;
      return Question(
        prompt: 'Un prix de $n € augmente\nde $t %. Nouveau prix = ? €',
        answer: r,
        explanation: 'Coefficient multiplicateur : 1 + \\frac{$t}{100} = ${fmtDec(100 + t)}.\n'
            '$n × ${fmtDec(100 + t)} = $r €.',
        allowTrueFalse: false,
      );
    }
    default: {
      final a = rnd(rng, 2, 9);
      return Question(
        prompt: 'Résoudre x^{2} = ${a * a}, x > 0.\nx = ?',
        answer: a,
        explanation: 'x^{2} = ${a * a} a deux solutions : $a et −$a. Avec x > 0, x = $a.',
        allowTrueFalse: false,
      );
    }
  }
}

Question _arith2(int level, Random rng) {
  if (level <= 2) {
    final n = rnd(rng, 10, 60);
    final isPrime = n > 1 && [for (var i = 2; i * i <= n; i++) i].every((i) => n % i != 0);
    return Question.text(
      prompt: '$n est-il un nombre premier ?',
      answer: isPrime ? 'Oui' : 'Non',
      choices: const ['Oui', 'Non', 'Seulement s\'il est pair', 'On ne peut pas savoir'],
      explanation: isPrime
          ? '$n n\'a que deux diviseurs : 1 et lui-même. Il est premier.'
          : '$n a d\'autres diviseurs que 1 et lui-même '
              '(par exemple ${[for (var i = 2; i < n; i++) if (n % i == 0) i].first}). Il n\'est pas premier.',
    );
  }
  if (level <= 4) {
    final g = rnd(rng, 2, 15);
    var a = rnd(rng, 2, 11), b = rnd(rng, 2, 11);
    while (gcd(a, b) != 1 || a == b) {
      a = rnd(rng, 2, 11);
      b = rnd(rng, 2, 11);
    }
    return Question(
      prompt: 'PGCD(${a * g} ; ${b * g}) = ?',
      answer: g,
      explanation: '${a * g} = $g × $a et ${b * g} = $g × $b ($a et $b sont premiers entre eux) : PGCD = $g.',
      allowTrueFalse: false,
    );
  }
  final n = pick(rng, [12, 18, 20, 28, 45, 50, 72, 84]);
  final factors = <int>[];
  var m = n;
  for (var p = 2; m > 1; p++) {
    while (m % p == 0) {
      factors.add(p);
      m ~/= p;
    }
  }
  return Question(
    prompt: 'Décomposition de $n en facteurs premiers :\ncombien de facteurs (avec répétition) ?',
    answer: factors.length,
    explanation: '$n = ${factors.join(' × ')} : ${factors.length} facteurs premiers.',
    allowTrueFalse: false,
  );
}

Question _functions2(int level, Random rng) {
  final a = _nz(rng, -3, 3), c = rnd(rng, -9, 9);
  final x = _nz(rng, -4, 4);
  final f = 'f(x) = ${_coef(a, 'x^{2}', first: true)} ${_sgn(c)}';
  switch (level) {
    case 1:
    case 2: {
      final k = _nz(rng, -5, 5), b = _nz(rng, -9, 9);
      return Question(
        prompt: 'f(x) = ${_coef(k, 'x', first: true)} ${_sgn(b)}\nf($x) = ?',
        answer: k * x + b,
        explanation: 'f($x) = $k × ${_p(x)} ${_sgn(b)} = ${k * x + b}.',
        allowTrueFalse: false,
      );
    }
    case 3:
    case 4:
      return Question(
        prompt: '$f\nf($x) = ?',
        answer: a * x * x + c,
        explanation: 'Attention : (${_p(x)})^{2} = ${x * x}. f($x) = $a × ${x * x} ${_sgn(c)} = ${a * x * x + c}.',
        allowTrueFalse: false,
      );
    default: {
      final k = _nz(rng, -5, 5), b = _nz(rng, -9, 9), y = k * x + b;
      return Question(
        prompt: 'f(x) = ${_coef(k, 'x', first: true)} ${_sgn(b)}\nAntécédent de $y = ?',
        answer: x,
        explanation: 'On résout ${k}x ${_sgn(b)} = $y : ${k}x = ${y - b}, x = $x.',
        allowTrueFalse: false,
      );
    }
  }
}

Question _vectors2(int level, Random rng) {
  final ax = rnd(rng, -3, 3), ay = rnd(rng, -3, 3);
  final ux = _nz(rng, -3, 3), uy = _nz(rng, -3, 3);
  if (level >= 4) {
    final vx = rnd(rng, -2, 2), vy = rnd(rng, -2, 2);
    final rx = ax + ux + vx, ry = ay + uy + vy;
    if (rx.abs() <= 6 && ry.abs() <= 6) {
      return Question.graph(
        prompt: 'A($ax ; $ay), u($ux ; $uy), v($vx ; $vy).\nPlace B tel que AB = u + v.',
        graph: GraphSpec.grid(range: 6, x: rx, y: ry),
        explanation: 'u + v = (${ux + vx} ; ${uy + vy}). B = A + (u + v) = ($rx ; $ry).',
      );
    }
  }
  return Question.graph(
    prompt: 'A($ax ; $ay) et u($ux ; $uy).\nPlace B tel que AB = u.',
    graph: GraphSpec.grid(range: 6, x: ax + ux, y: ay + uy),
    explanation: 'x_{B} = x_{A} + x_{u} = ${ax + ux} et y_{B} = y_{A} + y_{u} = ${ay + uy}.',
  );
}

Question _lines2(int level, Random rng) {
  final m = _nz(rng, -4, 4), p = rnd(rng, -6, 6);
  final x1 = rnd(rng, -3, 2), x2 = x1 + rnd(rng, 1, 3);
  final y1 = m * x1 + p, y2 = m * x2 + p;
  if (level <= 3) {
    return Question(
      prompt: 'A($x1 ; $y1) et B($x2 ; $y2).\nCoefficient directeur de (AB) = ?',
      answer: m,
      explanation: 'm = \\frac{y_{B} − y_{A}}{x_{B} − x_{A}} = \\frac{${y2 - y1}}{${x2 - x1}} = $m.',
      allowTrueFalse: false,
    );
  }
  return Question(
    prompt: 'A($x1 ; $y1) et B($x2 ; $y2).\nOrdonnée à l\'origine de (AB) = ?',
    answer: p,
    explanation: 'm = $m, puis p = y_{A} − m × x_{A} = $y1 − $m × ${_p(x1)} = $p.',
    allowTrueFalse: false,
  );
}

Question _stats2(int level, Random rng) {
  if (level <= 2) {
    final m = rnd(rng, 8, 15);
    var vals = <int>[];
    var last = -1;
    while (last < 0 || last > 20) {
      vals = [for (var i = 0; i < 3; i++) m + rnd(rng, -5, 5)];
      last = 4 * m - vals.fold(0, (a, b) => a + b);
    }
    vals.add(last);
    return Question(
      prompt: 'Série : ${vals.join(' ; ')}\nMoyenne = ?',
      answer: m,
      explanation: 'Somme = ${4 * m}, 4 valeurs : ${4 * m} ÷ 4 = $m.',
      allowTrueFalse: false,
    );
  }
  if (level <= 4) {
    final n = rnd(rng, 2, 9) * 50, t = pick(rng, [10, 20, 30, 40]);
    return Question(
      prompt: 'Un article passe de $n €\nà ${n - n * t ~/ 100} €.\nBaisse = ? %',
      answer: t,
      explanation: 'Taux = \\frac{${n - n * t ~/ 100} − $n}{$n} × 100 = −$t %.',
      allowTrueFalse: false,
    );
  }
  final vals = [for (var i = 0; i < 5; i++) rnd(rng, 1, 20)]..sort();
  return Question(
    prompt: 'Série rangée : ${vals.join(' ; ')}\nMédiane = ?',
    answer: vals[2],
    explanation: '5 valeurs rangées : la médiane est la 3e, soit ${vals[2]}.',
    allowTrueFalse: false,
  );
}

// =====================================================================
//  GÉNÉRATEURS — 1re
// =====================================================================
Question _sequences(int level, Random rng) {
  if (level <= 3) {
    final u0 = rnd(rng, -10, 20);
    final r = level >= 2 ? _nz(rng, -9, 9) : rnd(rng, 1, 6);
    final n = switch (level) { 1 => rnd(rng, 1, 5), 2 => rnd(rng, 5, 12), _ => rnd(rng, 10, 40) };
    return Question(
      prompt: 'Suite arithmétique :\nu${_sub(0)} = $u0, r = $r.\nu${_sub(n)} = ?',
      answer: u0 + n * r,
      explanation: 'u_{n} = u_{0} + n × r = $u0 + $n × ${_p(r)} = ${u0 + n * r}.',
      allowTrueFalse: false,
    );
  }
  final u0 = rnd(rng, 1, 5), q = rnd(rng, 2, 3), n = rnd(rng, 2, level == 4 ? 4 : 6);
  final r = u0 * pow(q, n).toInt();
  return Question(
    prompt: 'Suite géométrique :\nu${_sub(0)} = $u0, q = $q.\nu${_sub(n)} = ?',
    answer: r,
    explanation: 'u_{n} = u_{0} × q^{n} = $u0 × $q^{$n} = $u0 × ${pow(q, n).toInt()} = $r.',
    allowTrueFalse: false,
  );
}

Question _quadratic(int level, Random rng) {
  // On part des racines pour avoir des valeurs entières.
  final r1 = rnd(rng, -6, 6), r2 = rnd(rng, -6, 6);
  final a = level >= 4 ? _nz(rng, -2, 2) : 1;
  final b = -a * (r1 + r2), c = a * r1 * r2;
  final poly = '${_coef(a, 'x^{2}', first: true)}${b == 0 ? '' : _coef(b, 'x')}${c == 0 ? '' : ' ${_sgn(c)}'}';
  final delta = b * b - 4 * a * c;
  if (level <= 2) {
    return Question(
      prompt: 'P(x) = $poly\nΔ = b^{2} − 4ac = ?',
      answer: delta,
      explanation: 'a = $a, b = $b, c = $c. Δ = ${_p(b)}^{2} − 4 × $a × ${_p(c)} = $delta.',
      allowTrueFalse: false,
    );
  }
  if (level == 3) {
    final n = delta > 0 ? 2 : (delta == 0 ? 1 : 0);
    return Question(
      prompt: 'P(x) = $poly\nNombre de racines = ?',
      answer: n,
      explanation: 'Δ = $delta. Δ > 0 : 2 racines ; Δ = 0 : 1 racine ; Δ < 0 : aucune. Ici $n.',
      allowTrueFalse: false,
    );
  }
  final s = r1 + r2;
  return Question(
    prompt: 'P(x) = $poly\nSomme des racines = ?',
    answer: s,
    explanation: 'Somme des racines = −\\frac{b}{a} = −\\frac{$b}{$a} = $s '
        '(racines : $r1 et $r2).',
    allowTrueFalse: false,
  );
}

Question _derivative(int level, Random rng) {
  final x0 = level <= 2 ? rnd(rng, 1, 3) : rnd(rng, -3, 3);
  switch (level) {
    case 1: {
      final a = _nz(rng, -9, 9), b = rnd(rng, 1, 9);
      return Question(
        prompt: 'f(x) = ${_coef(a, 'x', first: true)} + $b\nf\'($x0) = ?',
        answer: a,
        explanation: '(ax + b)\' = a. Donc f\'(x) = $a et f\'($x0) = $a.',
        allowTrueFalse: false,
      );
    }
    case 2: {
      final a = _nz(rng, -5, 5);
      return Question(
        prompt: 'f(x) = ${_coef(a, 'x^{2}', first: true)}\nf\'($x0) = ?',
        answer: 2 * a * x0,
        explanation: '(x^{2})\' = 2x, donc f\'(x) = ${2 * a}x et f\'($x0) = ${2 * a * x0}.',
        allowTrueFalse: false,
      );
    }
    case 3:
    case 4: {
      final a = _nz(rng, -5, 5), b = _nz(rng, -9, 9);
      return Question(
        prompt: 'f(x) = ${_coef(a, 'x^{2}', first: true)}${_coef(b, 'x')}\nf\'($x0) = ?',
        answer: 2 * a * x0 + b,
        explanation: 'f\'(x) = ${2 * a}x ${_sgn(b)}, donc f\'($x0) = ${2 * a} × ${_p(x0)} ${_sgn(b)} = ${2 * a * x0 + b}.',
        allowTrueFalse: false,
      );
    }
    default: {
      final a = _nz(rng, -3, 3), b = _nz(rng, -5, 5);
      return Question(
        prompt: 'f(x) = ${_coef(a, 'x^{3}', first: true)}${_coef(b, 'x^{2}')}\nf\'($x0) = ?',
        answer: 3 * a * x0 * x0 + 2 * b * x0,
        explanation: 'f\'(x) = ${3 * a}x^{2} ${_sgn(2 * b)}x, donc f\'($x0) = ${3 * a * x0 * x0 + 2 * b * x0}.',
        allowTrueFalse: false,
      );
    }
  }
}

Question _exponential(int level, Random rng) {
  final a = rnd(rng, -5, 9), b = rnd(rng, -5, 9);
  switch (level) {
    case 1:
      return const Question(
        prompt: 'e^{0} = ?',
        answer: 1,
        explanation: 'Par définition de l\'exponentielle : e^{0} = 1.',
      );
    case 2:
      return Question(
        prompt: 'e^{$a} × e^{$b} = e^{?}',
        answer: a + b,
        explanation: 'e^{a} × e^{b} = e^{a+b} : $a + ${_p(b)} = ${a + b}.',
        allowTrueFalse: false,
      );
    case 3:
      return Question(
        prompt: '\\frac{e^{$a}}{e^{$b}} = e^{?}',
        answer: a - b,
        explanation: '\\frac{e^{a}}{e^{b}} = e^{a−b} : $a − ${_p(b)} = ${a - b}.',
        allowTrueFalse: false,
      );
    case 4: {
      final n = rnd(rng, 2, 5);
      return Question(
        prompt: '(e^{$a})^{$n} = e^{?}',
        answer: a * n,
        explanation: '(e^{a})^{n} = e^{na} : $n × ${_p(a)} = ${a * n}.',
        allowTrueFalse: false,
      );
    }
    default: {
      final k = rnd(rng, 2, 6);
      return Question(
        prompt: 'f(x) = e^{${k}x}\nf\'(0) = ?',
        answer: k,
        explanation: '(e^{kx})\' = k e^{kx}, donc f\'(0) = $k × e^{0} = $k.',
        allowTrueFalse: false,
      );
    }
  }
}

Question _trigonometry(int level, Random rng) {
  const table = [
    ('cos(0)', '1'),
    ('sin(0)', '0'),
    ('cos(\\frac{π}{3})', '\\frac{1}{2}'),
    ('sin(\\frac{π}{6})', '\\frac{1}{2}'),
    ('cos(\\frac{π}{4})', '\\frac{\\sqrt{2}}{2}'),
    ('sin(\\frac{π}{3})', '\\frac{\\sqrt{3}}{2}'),
    ('cos(π)', '−1'),
    ('sin(\\frac{π}{2})', '1'),
    ('cos(\\frac{π}{2})', '0'),
  ];
  const pool = ['0', '1', '−1', '\\frac{1}{2}', '\\frac{\\sqrt{2}}{2}', '\\frac{\\sqrt{3}}{2}', '−\\frac{1}{2}'];
  if (level == 5) {
    final k = rnd(rng, 1, 3);
    return Question(
      prompt: '${k * 180}° = ? π rad',
      answer: k,
      explanation: '180° = π rad, donc ${k * 180}° = $kπ rad.',
      allowTrueFalse: false,
    );
  }
  final usable = level <= 2 ? table.sublist(0, 4) : table;
  final (expr, value) = pick(rng, usable);
  return Question.text(
    prompt: '$expr = ?',
    answer: value,
    choices: pool,
    explanation: 'Valeur remarquable à connaître (cercle trigonométrique) : $expr = $value.',
  );
}

Question _dotProduct(int level, Random rng) {
  final ux = _nz(rng, -5, 5), uy = rnd(rng, -5, 5);
  final vx = _nz(rng, -5, 5), vy = rnd(rng, -5, 5);
  if (level <= 3) {
    return Question(
      prompt: 'u($ux ; $uy), v($vx ; $vy).\nu · v = ?',
      answer: ux * vx + uy * vy,
      explanation: 'u · v = xx\' + yy\' = $ux × ${_p(vx)} + $uy × ${_p(vy)} = ${ux * vx + uy * vy}.',
    );
  }
  // orthogonalité : trouver y pour que u · v = 0
  final k = _nz(rng, -3, 3);
  return Question(
    prompt: 'u(${ux * k} ; ${2 * k}), v(2 ; y).\nu ⊥ v pour y = ?',
    answer: -ux,
    explanation: 'u ⊥ v ⇔ u · v = 0 : ${ux * k} × 2 + ${2 * k} × y = 0, donc y = ${-ux}.',
    allowTrueFalse: false,
  );
}

// =====================================================================
//  GÉNÉRATEURS — Terminale
// =====================================================================
Question _combinatorics(int level, Random rng) {
  switch (level) {
    case 1: {
      final n = rnd(rng, 3, 5);
      return Question(
        prompt: '$n! = ?',
        answer: _fact(n),
        explanation: '$n! = ${[for (var i = n; i >= 1; i--) i].join(' × ')} = ${_fact(n)}.',
      );
    }
    case 2: {
      final n = rnd(rng, 3, 6);
      return Question(
        prompt: 'De combien de façons ranger\n$n livres sur une étagère ?',
        answer: _fact(n),
        explanation: 'Ce sont les permutations de $n éléments : $n! = ${_fact(n)}.',
        allowTrueFalse: false,
      );
    }
    case 3:
    case 4: {
      final n = rnd(rng, 4, level == 3 ? 6 : 9), k = rnd(rng, 2, 3);
      return Question(
        prompt: 'C($n ; $k) = ?',
        answer: _binom(n, k),
        explanation: 'C(n ; k) = \\frac{n!}{k!(n−k)!} = \\frac{$n!}{$k! × ${n - k}!} = ${_binom(n, k)}.',
      );
    }
    default: {
      final n = rnd(rng, 3, 6);
      return Question(
        prompt: 'Nombre de sous-ensembles\nd\'un ensemble à $n éléments ?',
        answer: pow(2, n).toInt(),
        explanation: 'Chaque élément est dedans ou non : 2^{$n} = ${pow(2, n).toInt()}.',
        allowTrueFalse: false,
      );
    }
  }
}

Question _limits(int level, Random rng) {
  const pool = ['+∞', '−∞', '0', '1', '2', '3'];
  final items = <(String, String, String)>[
    ('lim_{n→+∞} n^{2}', '+∞', 'n^{2} grandit sans limite.'),
    ('lim_{n→+∞} \\frac{1}{n}', '0', '1 divisé par un nombre de plus en plus grand tend vers 0.'),
    ('lim_{x→+∞} e^{x}', '+∞', 'L\'exponentielle croît vers +∞.'),
    ('lim_{x→−∞} e^{x}', '0', 'e^{x} tend vers 0 quand x tend vers −∞.'),
    ('lim_{x→+∞} −x^{3}', '−∞', 'x^{3} → +∞, donc −x^{3} → −∞.'),
    ('lim_{n→+∞} \\frac{3n + 1}{n}', '3', '\\frac{3n + 1}{n} = 3 + \\frac{1}{n} → 3.'),
    ('lim_{n→+∞} \\frac{2n^{2}}{n^{2} + 1}', '2', 'On factorise par n^{2} : → \\frac{2}{1} = 2.'),
    ('lim_{x→0} \\frac{e^{x} − 1}{x}', '1', 'C\'est le nombre dérivé de e^{x} en 0 : e^{0} = 1.'),
  ];
  final usable = level <= 2 ? items.sublist(0, 4) : items;
  final (expr, value, why) = pick(rng, usable);
  return Question.text(
    prompt: '$expr = ?',
    answer: value,
    choices: pool,
    explanation: why,
  );
}

Question _logarithm(int level, Random rng) {
  switch (level) {
    case 1:
      return const Question(
        prompt: 'ln(1) = ?',
        answer: 0,
        explanation: 'ln(1) = 0, car e^{0} = 1.',
      );
    case 2: {
      final k = rnd(rng, -5, 9);
      return Question(
        prompt: 'ln(e^{$k}) = ?',
        answer: k,
        explanation: 'ln et exp sont réciproques : ln(e^{x}) = x, donc $k.',
      );
    }
    case 3: {
      final a = rnd(rng, 2, 5), m = rnd(rng, 2, 4), n = rnd(rng, 1, 4);
      return Question(
        prompt: 'ln($a^{$m}) + ln($a^{$n}) = ? × ln($a)',
        answer: m + n,
        explanation: 'ln(a^{k}) = k ln(a) : $m ln($a) + $n ln($a) = ${m + n} ln($a).',
        allowTrueFalse: false,
      );
    }
    case 4: {
      final k = rnd(rng, 2, 6);
      return Question(
        prompt: 'e^{ln($k)} = ?',
        answer: k,
        explanation: 'e^{ln(x)} = x pour x > 0, donc $k.',
      );
    }
    default: {
      final k = rnd(rng, 2, 5);
      return Question(
        prompt: 'Résoudre ln(x) = ln($k) + ln(${k + 1}).\nx = ?',
        answer: k * (k + 1),
        explanation: 'ln(a) + ln(b) = ln(ab), donc x = $k × ${k + 1} = ${k * (k + 1)}.',
        allowTrueFalse: false,
      );
    }
  }
}

Question _integrals(int level, Random rng) {
  switch (level) {
    case 1: {
      final k = rnd(rng, 2, 9), a = rnd(rng, 1, 6);
      return Question(
        prompt: '\\int_{0}^{$a} $k dx = ?',
        answer: k * a,
        explanation: 'Aire d\'un rectangle de largeur $a et de hauteur $k : $k × $a = ${k * a}.',
      );
    }
    case 2: {
      final a = rnd(rng, 1, 5) * 2;
      return Question(
        prompt: '\\int_{0}^{$a} x dx = ?',
        answer: a * a ~/ 2,
        explanation: 'Une primitive de x est \\frac{x^{2}}{2} : \\frac{$a^{2}}{2} − 0 = ${a * a ~/ 2}.',
      );
    }
    case 3: {
      final k = rnd(rng, 2, 6);
      return Question(
        prompt: 'Primitive de ${2 * k}x : F(x) = ?x^{2}',
        answer: k,
        explanation: '(x^{2})\' = 2x, donc une primitive de ${2 * k}x est ${k}x^{2}.',
        allowTrueFalse: false,
      );
    }
    case 4: {
      final a = rnd(rng, 1, 3);
      return Question(
        prompt: '\\int_{0}^{$a} 3x^{2} dx = ?',
        answer: a * a * a,
        explanation: 'Une primitive de 3x^{2} est x^{3} : $a^{3} − 0 = ${a * a * a}.',
      );
    }
    default: {
      final a = rnd(rng, 1, 4), b = rnd(rng, 1, 5);
      return Question(
        prompt: '\\int_{0}^{$a} (2x + $b) dx = ?',
        answer: a * a + b * a,
        explanation: 'Primitive : x^{2} + ${b}x. On calcule ($a^{2} + $b × $a) − 0 = ${a * a + b * a}.',
      );
    }
  }
}

Question _binomial(int level, Random rng) {
  if (level <= 2) {
    final n = rnd(rng, 1, 5) * 20, pd = pick(rng, [2, 4, 5, 10]);
    return Question(
      prompt: 'X suit B($n ; \\frac{1}{$pd}).\nE(X) = ?',
      answer: n ~/ pd,
      explanation: 'Pour une loi binomiale, E(X) = n × p = $n × \\frac{1}{$pd} = ${n ~/ pd}.',
    );
  }
  if (level <= 4) {
    final n = rnd(rng, 3, 6);
    return Question(
      prompt: 'On lance $n fois une pièce.\nNombre de résultats possibles ?',
      answer: pow(2, n).toInt(),
      explanation: 'Chaque lancer a 2 issues, et les lancers sont indépendants : 2^{$n} = ${pow(2, n).toInt()}.',
      allowTrueFalse: false,
    );
  }
  final n = rnd(rng, 3, 6), k = rnd(rng, 1, n - 1);
  return Question(
    prompt: 'X suit B($n ; p). Combien de\nchemins donnent X = $k ?',
    answer: _binom(n, k),
    explanation: 'C\'est le coefficient binomial C($n ; $k) = ${_binom(n, k)}.',
    allowTrueFalse: false,
  );
}

Question _space(int level, Random rng) {
  final u = [for (var i = 0; i < 3; i++) rnd(rng, -4, 4)];
  final v = [for (var i = 0; i < 3; i++) rnd(rng, -4, 4)];
  if (level <= 2) {
    return Question(
      prompt: 'u(${u.join(' ; ')}), v(${v.join(' ; ')}).\nAbscisse de u + v = ?',
      answer: u[0] + v[0],
      explanation: 'On additionne coordonnée par coordonnée : ${u[0]} + ${_p(v[0])} = ${u[0] + v[0]}.',
      allowTrueFalse: false,
    );
  }
  if (level <= 4) {
    final d = u[0] * v[0] + u[1] * v[1] + u[2] * v[2];
    return Question(
      prompt: 'u(${u.join(' ; ')}), v(${v.join(' ; ')}).\nu · v = ?',
      answer: d,
      explanation: 'u · v = xx\' + yy\' + zz\' = ${u[0] * v[0]} ${_sgn(u[1] * v[1])} ${_sgn(u[2] * v[2])} = $d.',
    );
  }
  const triples = [(1, 2, 2, 3), (2, 3, 6, 7), (1, 4, 8, 9), (2, 6, 9, 11), (4, 4, 7, 9)];
  final (a, b, c, n) = pick(rng, triples);
  return Question(
    prompt: 'u($a ; $b ; $c). ‖u‖ = ?',
    answer: n,
    explanation: '‖u‖ = \\sqrt{$a^{2} + $b^{2} + $c^{2}} = \\sqrt{${a * a + b * b + c * c}} = $n.',
    allowTrueFalse: false,
  );
}
