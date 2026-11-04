import '../curriculum/cycle.dart';

enum ExerciseType { multipleChoice, input, trueFalse, numberLine, grid }

/// Un exercice prêt à être affiché (dans un mini-jeu ou en mode Exercices).
class Exercise {
  final String skillId;

  /// Niveau de difficulté de 1 (facile) à 5 (difficile).
  final int level;
  final ExerciseType type;

  /// Texte affiché (peut contenir des \frac{}{}, x^{2}...).
  final String prompt;

  /// Bonne réponse attendue, sous forme de texte ("12", "\frac{1}{2}", "3;-2"...).
  final String answer;

  /// Propositions pour les QCM (vide sinon).
  final List<String> choices;

  /// Explication pas à pas affichée en cas d'erreur.
  final String explanation;

  /// Graphique pour les types numberLine et grid.
  final GraphSpec? graph;

  const Exercise({
    required this.skillId,
    required this.level,
    required this.type,
    required this.prompt,
    required this.answer,
    required this.explanation,
    this.choices = const [],
    this.graph,
  });

  static String _norm(String s) =>
      s.trim().toLowerCase().replaceAll('−', '-').replaceAll(' ', '');

  bool check(String userAnswer) => _norm(userAnswer) == _norm(answer);
}
