import 'college.dart';
import 'cycle.dart';
import 'lycee.dart';
import 'primaire.dart';

/// Registre de tous les cycles de l'app.
/// Pour ajouter un cycle : créer son fichier puis l'ajouter à cette liste.
class Curriculum {
  static final List<Cycle> cycles = [primaire, college, lycee];

  /// Cycle actuellement choisi (mis à jour par ProgressStore).
  static Cycle current = primaire;

  static Cycle byId(String id) =>
      cycles.firstWhere((c) => c.id == id, orElse: () => primaire);
}
