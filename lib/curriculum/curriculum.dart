import 'cycle.dart';
import 'cycle1.dart';
import 'cycle2.dart';
import 'cycle3.dart';
import 'cycle4.dart';
import 'lycee.dart';

/// Registre de tout le contenu de l'app : du Cycle 1 (maternelle)
/// à la Terminale, d'après les programmes officiels (dossier docs).
///
/// Un fichier par cycle :
///   cycle1.dart  PS, MS, GS          cycle2.dart  CP, CE1, CE2
///   cycle3.dart  CM1, CM2, 6e        cycle4.dart  5e, 4e, 3e
///   lycee.dart   2nde, 1re, Terminale
class Curriculum {
  static final List<School> schools = [cycle1, cycle2, cycle3, cycle4, lycee];

  /// Toutes les cartes jouables (PS, MS, ..., Terminale).
  static List<Cycle> get allCycles => [for (final s in schools) ...s.grades];

  /// Carte actuellement choisie (mise à jour par ProgressStore).
  static Cycle current = ce1;

  static Cycle byId(String id) =>
      allCycles.firstWhere((c) => c.id == id, orElse: () => ce1);

  static School schoolOf(Cycle cycle) =>
      schools.firstWhere((s) => s.grades.contains(cycle), orElse: () => cycle2);

  /// Cycle d'études de la carte en cours (sert à choisir le thème visuel).
  static School get currentSchool => schoolOf(current);
}
