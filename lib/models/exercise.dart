enum ExerciseType { multipleChoice, input, trueFalse }

/// Un exercice généré automatiquement.
class Exercise {
  final String skillId;

  /// Niveau de difficulté de 1 (facile) à 5 (difficile).
  final int level;
  final ExerciseType type;

  /// Texte affiché à l'enfant (ex : "7 + 5 = ?").
  final String prompt;

  /// Bonne réponse attendue, sous forme de texte ("12", "vrai", "faux").
  final String answer;

  /// Propositions pour les QCM (vide sinon).
  final List<String> choices;

  /// Explication pas à pas affichée en cas d'erreur.
  final String explanation;

  const Exercise({
    required this.skillId,
    required this.level,
    required this.type,
    required this.prompt,
    required this.answer,
    required this.explanation,
    this.choices = const [],
  });

  bool check(String userAnswer) =>
      userAnswer.trim().toLowerCase() == answer.trim().toLowerCase();
}
