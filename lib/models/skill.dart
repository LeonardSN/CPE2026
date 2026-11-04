import '../curriculum/curriculum.dart';
import '../curriculum/cycle.dart';

export '../curriculum/cycle.dart';

/// Dans le code des écrans, une « Skill » = un chapitre.
typedef Skill = Chapter;

/// Accès pratique aux chapitres de la classe choisie.
class Skills {
  /// Chapitres de la carte de la classe actuelle, boss compris.
  static List<Chapter> get all => Curriculum.current.map;

  /// Chapitres « réels » (sans le boss) suivis dans l'espace parent.
  static List<Chapter> get tracked => Curriculum.current.chapters;

  /// Recherche un chapitre dans TOUTES les classes (null si inconnu,
  /// par exemple un ancien chapitre supprimé).
  static Chapter? tryById(String id) {
    for (final c in Curriculum.allCycles) {
      if (id == 'review_${c.id}') return c.review;
      for (final ch in c.map) {
        if (ch.id == id) return ch;
      }
    }
    return null;
  }

  static Chapter byId(String id) =>
      tryById(id) ?? (throw ArgumentError('Chapitre inconnu : $id'));
}
