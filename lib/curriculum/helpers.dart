import 'dart:math';

import 'cycle.dart';

// Outils partagés par tous les fichiers de cycle (additions, tables, etc.).
// =====================================================================
//  OUTILS
// =====================================================================
int rnd(Random rng, int a, int b) => a + rng.nextInt(b - a + 1);
T pick<T>(Random rng, List<T> l) => l[rng.nextInt(l.length)];

String fmtInt(int n) {
  // 45678 -> "45 678"
  final s = n.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return n < 0 ? '-$buf' : buf.toString();
}

String fmtDec(int hundredths) {
  // 425 -> "4,25" ; 340 -> "3,4"
  final e = hundredths ~/ 100, c = hundredths % 100;
  if (c == 0) return '$e';
  if (c % 10 == 0) return '$e,${c ~/ 10}';
  return '$e,${c.toString().padLeft(2, '0')}';
}

// ---------------------------------------------------------------------
// Additions et soustractions génériques
// ---------------------------------------------------------------------
class AddSpec {
  final int aMin, aMax, bMin, bMax;
  final int? minSum, maxSum;
  final bool? carry; // true = avec retenue, false = sans, null = peu importe

  const AddSpec(this.aMin, this.aMax, this.bMin, this.bMax,
      {this.minSum, this.maxSum, this.carry});
}

bool hasCarry(int a, int b) {
  while (a > 0 || b > 0) {
    if (a % 10 + b % 10 >= 10) return true;
    a ~/= 10;
    b ~/= 10;
  }
  return false;
}

Question additionQ(Random rng, AddSpec s) {
  late int a, b;
  for (var tries = 0; tries < 200; tries++) {
    a = rnd(rng, s.aMin, s.aMax);
    b = rnd(rng, s.bMin, s.bMax);
    final sum = a + b;
    if (s.minSum != null && sum < s.minSum!) continue;
    if (s.maxSum != null && sum > s.maxSum!) continue;
    if (s.carry != null && hasCarry(a, b) != s.carry) continue;
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
    if (hasCarry(a, b)) expl += '\n(Attention à la retenue en posant l\'opération !)';
  }
  return Question(prompt: '$a + $b = ?', answer: sum, explanation: expl);
}

class SubSpec {
  final int aMin, aMax, bMin, bMax;
  final bool? borrow;

  const SubSpec(this.aMin, this.aMax, this.bMin, this.bMax, {this.borrow});
}

bool hasBorrow(int a, int b) {
  while (b > 0) {
    if (b % 10 > a % 10) return true;
    a ~/= 10;
    b ~/= 10;
  }
  return false;
}

Question subtractionQ(Random rng, SubSpec s) {
  late int a, b;
  for (var tries = 0; tries < 200; tries++) {
    a = rnd(rng, s.aMin, s.aMax);
    b = rnd(rng, s.bMin, min(s.bMax, a));
    if (s.borrow != null && hasBorrow(a, b) != s.borrow) continue;
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
Question tableQ(Random rng, List<int> tables, {bool missingFactor = false}) {
  final t = pick(rng, tables);
  final f = rnd(rng, 2, 10);
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
Question problemQ(Random rng, int level, {required int grade}) {
  final (name, pron) = pick(rng, _names);
  final pronCap = pron[0].toUpperCase() + pron.substring(1);
  final obj = pick(rng, _objects);
  final kinds = level >= 4 ? ['add', 'sub', 'mul'] : ['add', 'sub'];
  final kind = pick(rng, kinds);

  if (kind == 'mul') {
    final n = rnd(rng, 2, grade == 1 ? 5 : 9);
    final k = rnd(rng, 2, grade == 1 ? 5 : 9);
    return Question(
      prompt: '$name achète $n paquets de $k $obj.\nCombien de $obj en tout ?',
      answer: n * k,
      explanation: '$n paquets de $k, c\'est $n fois $k :\n$n × $k = ${n * k} $obj.',
      allowTrueFalse: false,
    );
  }
  final scale = grade == 1 ? 1 : 3;
  final (int a, int b) = switch (level) {
    1 => (rnd(rng, 5, 15) * scale, rnd(rng, 1, 5) * scale),
    2 => (rnd(rng, 15, 30) * scale, rnd(rng, 3, 9) * scale),
    3 => (rnd(rng, 25, 60) * scale, rnd(rng, 10, 20) * scale),
    4 => (rnd(rng, 40, 90) * scale, rnd(rng, 11, 35) * scale),
    _ => (rnd(rng, 100, 300) * scale, rnd(rng, 20, 90) * scale),
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


// ---------------------------------------------------------------------
// Fractions et droite graduée (utilisés du CP au collège)
// ---------------------------------------------------------------------

/// Écrit une fraction en notation de l'app : \frac{n}{d}.
String frac(int n, int d) => '\\frac{$n}{$d}';

int gcd(int a, int b) {
  a = a.abs();
  b = b.abs();
  while (b != 0) {
    final t = a % b;
    a = b;
    b = t;
  }
  return a;
}

/// « Quelle fraction est coloriée ? » avec des carrés.
Question fractionOfWholeQ(Random rng, int level, List<int> dens) {
  final usable = dens.where((d) => d <= (level <= 2 ? 4 : 10)).toList();
  final d = pick(rng, usable.isEmpty ? dens : usable);
  final n = level == 1 ? 1 : rnd(rng, 1, d - 1);
  final squares = '🟧' * n + '⬜' * (d - n);
  final pool = <String>{
    frac(n, d),
    frac(d - n == n ? n + 1 : d - n, d),
    frac(n, d + 1),
    frac(d, n == d ? n + 1 : n),
    frac(n + 1, d + 1),
    frac(n, d == 2 ? 3 : d - 1),
  }.toList();
  return Question.text(
    prompt: 'Quelle fraction est coloriée ?\n$squares',
    answer: frac(n, d),
    choices: pool,
    explanation: 'L\'unité est partagée en $d parts égales (le nombre du bas) '
        'et $n sont coloriées (le nombre du haut) : ${frac(n, d)}.',
  );
}

/// Placer un nombre entier sur une droite graduée de 0 à [max] (pas [step]).
Question numberLineQ(Random rng, int max, int step, {bool maxLevelBig = false}) {
  final divisions = max ~/ step;
  final tick = rnd(rng, 1, divisions - 1);
  final value = tick * step;
  final labels = <int, String>{0: '0', divisions: '$max'};
  if (!maxLevelBig && divisions >= 4) labels[divisions ~/ 2] = '${max ~/ 2}';
  return Question.graph(
    prompt: 'Place le nombre $value\nsur la droite graduée.',
    graph: GraphSpec.numberLine(
      min: 0,
      max: max.toDouble(),
      divisions: divisions,
      targetTick: tick,
      labels: labels,
    ),
    explanation: 'Chaque graduation vaut $step. $value = $tick × $step : '
        'compte $tick graduations à partir de 0.',
  );
}

/// Placer une fraction sur une droite graduée de 0 à [units].
Question fractionLineQ(Random rng, int level) {
  final d = pick(rng, level <= 2 ? [2, 4] : [3, 4, 5, 6, 8, 10]);
  final units = level >= 4 ? 2 : 1;
  final n = rnd(rng, 1, d * units - 1);
  final labels = <int, String>{0: '0', d: '1'};
  if (units == 2) labels[2 * d] = '2';
  return Question.graph(
    prompt: 'Place ${frac(n, d)} sur la droite graduée.',
    graph: GraphSpec.numberLine(
      min: 0,
      max: units.toDouble(),
      divisions: d * units,
      targetTick: n,
      labels: labels,
    ),
    explanation: 'L\'unité (de 0 à 1) est partagée en $d : chaque graduation vaut ${frac(1, d)}. '
        'Pour ${frac(n, d)}, on compte $n graduations à partir de 0.',
  );
}

/// Placer un point dans un repère.
Question gridPointQ(Random rng, int range, {bool negatives = true}) {
  int coord() => negatives ? rnd(rng, -range, range) : rnd(rng, 0, range);
  var x = coord(), y = coord();
  if (x == 0 && y == 0) x = 1;
  return Question.graph(
    prompt: 'Place le point A($x ; $y).',
    graph: GraphSpec.grid(range: range, x: x, y: y),
    explanation: 'Le 1er nombre ($x) est l\'abscisse : on se déplace horizontalement. '
        'Le 2e ($y) est l\'ordonnée : on se déplace verticalement.',
  );
}

/// Réponses décimales en texte : 3,75 et des pièges proches.
List<String> decimalChoices(int hundredths, Random rng) {
  final set = <int>{hundredths};
  for (final delta in [10, -10, 1, -1, 100, 5, -5, 25]) {
    if (set.length >= 5) break;
    final v = hundredths + delta;
    if (v > 0) set.add(v);
  }
  return set.map(fmtDec).toList();
}
