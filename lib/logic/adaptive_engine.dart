import 'dart:math';

/// Moteur adaptatif inspiré du système Elo (celui des échecs).
///
/// - Chaque compétence de l'enfant a une note θ (theta), 1000 au départ.
/// - Chaque niveau d'exercice (1 à 5) a une difficulté D.
/// - Probabilité de réussite attendue : p = 1 / (1 + 10^((D − θ) / 400)).
/// - Après chaque réponse : θ ← θ + K × (résultat − p)
///   (résultat = 1 si juste, 0 si faux).
/// - On choisit le niveau dont la probabilité de réussite est la plus proche
///   de 70 % : assez facile pour rester motivé, assez dur pour progresser
///   (zone proximale de développement).
class AdaptiveEngine {
  static const double initialRating = 1000;
  static const double k = 90;
  static const double targetSuccess = 0.70;
  static const int minLevel = 1;
  static const int maxLevel = 5;

  static double difficultyOf(int level) => 700 + 150.0 * level;

  static double expectedSuccess(double theta, int level) =>
      1 / (1 + pow(10, (difficultyOf(level) - theta) / 400));

  static double update(double theta, int level, bool correct) {
    final p = expectedSuccess(theta, level);
    return theta + k * ((correct ? 1 : 0) - p);
  }

  static int chooseLevel(double theta) {
    var best = minLevel;
    var bestGap = double.infinity;
    for (var l = minLevel; l <= maxLevel; l++) {
      final gap = (expectedSuccess(theta, l) - targetSuccess).abs();
      if (gap < bestGap) {
        bestGap = gap;
        best = l;
      }
    }
    return best;
  }

  /// Maîtrise affichée aux parents, entre 0 et 1.
  static double mastery(double theta) {
    final lo = difficultyOf(minLevel);
    final hi = difficultyOf(maxLevel) + 150;
    return ((theta - lo) / (hi - lo)).clamp(0.0, 1.0);
  }
}
