import 'dart:math';

import 'package:flutter/material.dart';

import 'cycle.dart';
import 'helpers.dart';

// =====================================================================
//  CYCLE 1 : MATERNELLE (PS, MS, GS)
//  D'après le programme : découvrir les nombres (quantité, rang),
//  résoudre des problèmes, explorer les formes, les grandeurs et les
//  motifs organisés. Progression « avant 4 ans / 4 ans / 5 ans ».
//  Tout se joue en choisissant une réponse (pas d'écriture).
// =====================================================================

final cycle1 = School(
  id: 'cycle1',
  title: 'Cycle 1',
  subtitle: 'Maternelle · PS · MS · GS',
  emoji: '🧸',
  color: Color(0xFFFFB347),
  grades: [ps, ms, gs],
  recommendedGradeId: 'gs',
);

const _orange = Color(0xFFFF8C38);
const _blue = Color(0xFF2A5C96);
const _yellow = Color(0xFFFFC23D);
const _pink = Color(0xFFFF7EB6);
const _green = Color(0xFF58CC02);
const _purple = Color(0xFFCE82FF);

const _things = ['🍎', '🐟', '⭐', '🌸', '🚗', '🎈', '🐞', '🍓'];
const _animals = ['🐥', '🐸', '🐱', '🐶', '🐰', '🐻', '🐷', '🐵', '🦁', '🐮'];

final ps = Cycle(
  id: 'ps',
  title: 'Petite section',
  subtitle: 'Avant 4 ans',
  emoji: '🧸',
  color: _yellow,
  chapters: [
    Chapter(
      id: 'ps_count', title: 'Combien ?', subtitle: '1, 2, 3',
      emoji: '🍎', color: _orange, monster: '🐛', monsterName: 'Petite Chenille',
      generate: (l, r) => _count(r, 1, l <= 2 ? 3 : 4),
    ),
    Chapter(
      id: 'ps_more', title: 'Le plus', subtitle: 'Où y en a-t-il le plus ?',
      emoji: '🧺', color: _pink, monster: '🐭', monsterName: 'Petite Souris',
      generate: (l, r) => _more(r, l <= 2 ? 3 : 5),
    ),
    Chapter(
      id: 'ps_shape', title: 'Les formes', subtitle: 'Rond, carré, triangle',
      emoji: '🔴', color: _blue, monster: '🧊', monsterName: 'Cube Rigolo',
      generate: _findShape,
    ),
  ],
  boss: const Chapter.boss(id: 'boss_ps', monster: '🐣', monsterName: 'Poussin Coquin'),
);

final ms = Cycle(
  id: 'ms',
  title: 'Moyenne section',
  subtitle: '4 ans',
  emoji: '🧸',
  color: _orange,
  chapters: [
    Chapter(
      id: 'ms_count', title: 'Compter', subtitle: 'Jusqu\'à 6',
      emoji: '🐞', color: _orange, monster: '🐛', monsterName: 'Chenille Gourmande',
      generate: (l, r) => _count(r, 1, 3 + l ~/ 2 + 1),
    ),
    Chapter(
      id: 'ms_rank', title: 'Quelle place ?', subtitle: 'Premier, deuxième...',
      emoji: '🏁', color: _blue, monster: '🐢', monsterName: 'Tortue Lente',
      generate: (l, r) => _rank(r, l <= 2 ? 3 : 5),
    ),
    Chapter(
      id: 'ms_add', title: 'Ajouter, enlever', subtitle: 'Petits problèmes',
      emoji: '🍬', color: _pink, monster: '🐻', monsterName: 'Ours Gourmand',
      generate: (l, r) => _story(r, l, 5),
    ),
    Chapter(
      id: 'ms_long', title: 'Le plus long', subtitle: 'Comparer des longueurs',
      emoji: '🐍', color: _green, monster: '🦒', monsterName: 'Girafe Géante',
      generate: _longest,
    ),
    Chapter(
      id: 'ms_motif', title: 'Les motifs', subtitle: 'Continuer la suite',
      emoji: '🔴', color: _purple, monster: '🦜', monsterName: 'Perroquet Répétitif',
      generate: (l, r) => _pattern(r, l <= 3 ? 2 : 3),
    ),
  ],
  boss: const Chapter.boss(id: 'boss_ms', monster: '🐲', monsterName: 'Bébé Dragon'),
);

final gs = Cycle(
  id: 'gs',
  title: 'Grande section',
  subtitle: '5 ans',
  emoji: '🧸',
  color: _pink,
  chapters: [
    Chapter(
      id: 'gs_count', title: 'Compter', subtitle: 'Jusqu\'à 10',
      emoji: '⭐', color: _orange, monster: '🐛', monsterName: 'Chenille Gourmande',
      generate: (l, r) => _count(r, 3, 5 + l),
    ),
    Chapter(
      id: 'gs_dec', title: 'Décomposer', subtitle: '5, c\'est 3 et 2',
      emoji: '✋', color: _yellow, monster: '🐙', monsterName: 'Poulpe Dix-Bras',
      generate: _decompose,
    ),
    Chapter(
      id: 'gs_add', title: 'Petits problèmes', subtitle: 'Jusqu\'à 10',
      emoji: '🍬', color: _pink, monster: '🐻', monsterName: 'Ours Gourmand',
      generate: (l, r) => _story(r, l, 10),
    ),
    Chapter(
      id: 'gs_rank', title: 'Quelle place ?', subtitle: 'Jusqu\'à 10',
      emoji: '🏁', color: _blue, monster: '🐢', monsterName: 'Tortue Lente',
      generate: (l, r) => _rank(r, 4 + l),
    ),
    Chapter(
      id: 'gs_motif', title: 'Les motifs', subtitle: 'Suites plus longues',
      emoji: '🔷', color: _purple, monster: '🦜', monsterName: 'Perroquet Répétitif',
      generate: (l, r) => _pattern(r, l <= 2 ? 2 : 3),
    ),
  ],
  boss: const Chapter.boss(id: 'boss_gs', monster: '🐲', monsterName: 'Petit Dragon'),
);

// =====================================================================
//  GÉNÉRATEURS
// =====================================================================

Question _count(Random rng, int minN, int maxN) {
  final n = rnd(rng, minN, maxN);
  final e = pick(rng, _things);
  final groups = <String>[];
  for (var i = 0; i < n; i += 5) {
    groups.add(List.filled(min(5, n - i), e).join());
  }
  return Question(
    prompt: 'Combien de $e ?\n${groups.join(' ')}',
    answer: n,
    explanation: 'On touche chaque $e en comptant : 1, 2, 3... Il y en a $n.',
    allowTrueFalse: false,
  );
}

Question _more(Random rng, int maxN) {
  final e = pick(rng, _things);
  final counts = <int>{};
  while (counts.length < 4) {
    counts.add(rnd(rng, 1, maxN + 1));
  }
  final list = counts.toList();
  final big = list.reduce(max);
  return Question.text(
    prompt: 'Où y en a-t-il le plus ?',
    answer: e * big,
    choices: [for (final n in list) e * n],
    explanation: 'Celle qui en a le plus, c\'est la plus longue file : $big.',
  );
}

Question _findShape(int level, Random rng) {
  const shapes = {'le rond': '🔴', 'le carré': '🟦', 'le triangle': '🔺', 'l\'étoile': '⭐'};
  final names = shapes.keys.toList();
  final name = pick(rng, level <= 2 ? names.sublist(0, 3) : names);
  return Question.text(
    prompt: 'Trouve $name',
    answer: shapes[name]!,
    choices: shapes.values.toList(),
    explanation: '${name[0].toUpperCase()}${name.substring(1)}, c\'est ${shapes[name]}.',
  );
}

Question _rank(Random rng, int length) {
  final row = ([..._animals]..shuffle(rng)).take(length).toList();
  final pos = rnd(rng, 1, length);
  final target = row[pos - 1];
  return Question(
    prompt: 'Le $target est à quelle place ?\n🏁 ${row.join(' ')}',
    answer: pos,
    explanation: 'On compte depuis le drapeau 🏁 : le $target est le ${pos == 1 ? '1er' : '${pos}e'}.',
    allowTrueFalse: false,
  );
}

Question _story(Random rng, int level, int maxTotal) {
  final e = pick(rng, ['🍬', '🍪', '🎈', '🧸', '🍓']);
  final add = level <= 3 || rng.nextBool();
  if (add) {
    final a = rnd(rng, 1, maxTotal - 1), b = rnd(rng, 1, maxTotal - a);
    return Question(
      prompt: 'J\'ai ${e * a}.\nOn m\'en donne ${e * b}.\nCombien j\'en ai ?',
      answer: a + b,
      explanation: 'On met tout ensemble et on compte : $a et $b, ça fait ${a + b}.',
      allowTrueFalse: false,
    );
  }
  final a = rnd(rng, 2, maxTotal), b = rnd(rng, 1, a - 1);
  return Question(
    prompt: 'J\'ai ${e * a}.\nJ\'en mange $b.\nCombien il en reste ?',
    answer: a - b,
    explanation: 'On en enlève $b : il en reste ${a - b}.',
    allowTrueFalse: false,
  );
}

Question _longest(int level, Random rng) {
  final e = pick(rng, ['🟩', '🟦', '🟧', '🟪']);
  final lens = <int>{};
  while (lens.length < 4) {
    lens.add(rnd(rng, 1, level <= 2 ? 6 : 8));
  }
  final list = lens.toList();
  final longest = list.reduce(max);
  final shortest = rng.nextBool() && level >= 3;
  final target = shortest ? list.reduce(min) : longest;
  return Question.text(
    prompt: shortest ? 'Quel est le plus court ?' : 'Quel est le plus long ?',
    answer: e * target,
    choices: [for (final n in list) e * n],
    explanation: shortest
        ? 'Le plus court est celui qui a le moins de carreaux : $target.'
        : 'Le plus long est celui qui a le plus de carreaux : $longest.',
  );
}

Question _pattern(Random rng, int period) {
  const palette = ['🔴', '🔵', '🟡', '🟢', '🟣'];
  final motif = ([...palette]..shuffle(rng)).take(period).toList();
  final shown = rnd(rng, period + 1, period * 3);
  final seq = [for (var i = 0; i < shown; i++) motif[i % period]];
  final next = motif[shown % period];
  return Question.text(
    prompt: 'Qu\'est-ce qui vient ensuite ?\n${seq.join()} ❓',
    answer: next,
    choices: palette.sublist(0, 4).contains(next)
        ? palette.sublist(0, 4)
        : [next, ...palette.where((p) => p != next).take(3)],
    explanation: 'Le motif qui se répète est ${motif.join()}. Après ${seq.last} vient $next.',
  );
}

Question _decompose(int level, Random rng) {
  final total = switch (level) { 1 => rnd(rng, 3, 5), 2 => rnd(rng, 4, 6), 3 => rnd(rng, 5, 8), _ => rnd(rng, 6, 10) };
  final a = rnd(rng, 1, total - 1);
  return Question(
    prompt: '$total, c\'est $a et ?\n${'✋' * (total ~/ 5)}${'☝️' * (total % 5)}',
    answer: total - a,
    explanation: 'Montre $total doigts, cache-en $a : il en reste ${total - a}.',
    allowTrueFalse: false,
  );
}
