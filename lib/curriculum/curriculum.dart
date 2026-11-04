import 'college.dart';
import 'cycle.dart';
import 'lycee.dart';
import 'primaire.dart';

/// Registre de tout le contenu de l'app.
/// Pour ajouter un cycle : créer son fichier puis l'ajouter à [schools].
class Curriculum {
  static final List<School> schools = [
    primaire,
    School.single(college),
    School.single(lycee),
  ];

  /// Toutes les cartes jouables (CP, CE1, ..., Collège, Lycée).
  static List<Cycle> get allCycles => [for (final s in schools) ...s.grades];

  /// Carte actuellement choisie (mise à jour par ProgressStore).
  static Cycle current = ce1;

  static Cycle byId(String id) =>
      allCycles.firstWhere((c) => c.id == id, orElse: () => ce1);

  static School schoolOf(Cycle cycle) =>
      schools.firstWhere((s) => s.grades.contains(cycle));
}
