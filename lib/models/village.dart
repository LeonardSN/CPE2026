/// Un élément qu'on peut construire dans son village.
class VillageItem {
  final String id;
  final String emoji;
  final String name;
  final int price;

  const VillageItem(this.id, this.emoji, this.name, this.price);
}

class Village {
  static const columns = 4;
  static const rows = 6;
  static const size = columns * rows;

  static const catalog = [
    VillageItem('fleurs', '🌻', 'Fleurs', 10),
    VillageItem('arbre', '🌳', 'Arbre', 15),
    VillageItem('palmier', '🌴', 'Palmier', 20),
    VillageItem('poule', '🐔', 'Poule', 20),
    VillageItem('tente', '⛺', 'Tente', 25),
    VillageItem('chevre', '🐐', 'Chèvre', 30),
    VillageItem('potager', '🥕', 'Potager', 35),
    VillageItem('case', '🛖', 'Case', 45),
    VillageItem('maison', '🏠', 'Maison', 50),
    VillageItem('fontaine', '⛲', 'Fontaine', 60),
    VillageItem('terrain', '⚽', 'Terrain de foot', 90),
    VillageItem('marche', '🏪', 'Boutique', 100),
    VillageItem('ecole', '🏫', 'École', 120),
    VillageItem('hopital', '🏥', 'Hôpital', 150),
    VillageItem('stade', '🏟️', 'Stade', 250),
    VillageItem('chateau', '🏰', 'Château', 300),
    VillageItem('fusee', '🚀', 'Fusée', 400),
  ];

  static VillageItem? byId(String id) {
    for (final item in catalog) {
      if (item.id == id) return item;
    }
    return null;
  }

  /// Rangs du village selon le nombre de constructions.
  static const ranks = [
    (0, 'Campement', '🏕️'),
    (3, 'Hameau', '🏡'),
    (8, 'Village', '🏘️'),
    (14, 'Petite ville', '🏙️'),
    (20, 'Grande ville', '🌆'),
  ];

  static (int, String, String) rankFor(int count) {
    var current = ranks.first;
    for (final r in ranks) {
      if (count >= r.$1) current = r;
    }
    return current;
  }

  static (int, String, String)? nextRank(int count) {
    for (final r in ranks) {
      if (r.$1 > count) return r;
    }
    return null;
  }
}
