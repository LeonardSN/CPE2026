/// Les mini-jeux qui remplacent les questions classiques.
enum GameType {
  balloons('Éclate les ballons', '🎈',
      'Éclate le ballon qui porte la bonne réponse avant qu\'il s\'envole !'),
  fruits('Attrape les fruits', '🧺',
      'Déplace ton panier pour attraper le fruit avec la bonne réponse.'),
  race('Course folle', '🏎️',
      'Chaque bonne réponse fait avancer ta voiture. Bats le rival !'),
  duel('Duel du monstre', '⚔️',
      'Frappe le monstre avec les bonnes réponses avant qu\'il t\'attaque !');

  final String label;
  final String emoji;
  final String description;

  const GameType(this.label, this.emoji, this.description);

  /// Ordre de rotation des jeux pour les leçons normales.
  static const rotation = [balloons, fruits, race, duel];
}
