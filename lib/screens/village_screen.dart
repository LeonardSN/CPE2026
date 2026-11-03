import 'package:flutter/material.dart';

import '../logic/progress_store.dart';
import '../models/village.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Le village que l'enfant construit avec les pièces gagnées en jouant.
class VillageScreen extends StatelessWidget {
  const VillageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = ProgressStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final count = store.village.length;
        final (_, rankName, rankEmoji) = Village.rankFor(count);
        final next = Village.nextRank(count);
        return Scaffold(
          backgroundColor: const Color(0xFFBFE9FF),
          appBar: AppBar(
            backgroundColor: const Color(0xFFBFE9FF),
            title: Text('Le village de ${store.childName}',
                style: const TextStyle(fontWeight: FontWeight.w800)),
            actions: [
              StatChip(
                  emoji: '🪙',
                  value: '${store.coins}',
                  color: const Color(0xFFB8860B)),
              const SizedBox(width: 16),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              // ---- Rang du village ----
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Text(rankEmoji, style: const TextStyle(fontSize: 40)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(rankName,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w900)),
                          Text(
                            next == null
                                ? 'Bravo, ton village est au maximum ! 🎉'
                                : 'Encore ${next.$1 - count} construction(s) pour devenir « ${next.$2} »',
                            style: const TextStyle(color: AppColors.greyDark),
                          ),
                          if (next != null) ...[
                            const SizedBox(height: 6),
                            RoundedProgress(
                              value: count / next.$1,
                              color: AppColors.orange,
                              height: 10,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // ---- Terrain ----
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF7ED957),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFF5BB33A), width: 4),
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: Village.size,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: Village.columns,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                  ),
                  itemBuilder: (context, i) {
                    final item = Village.byId(store.village[i] ?? '');
                    return GestureDetector(
                      onTap: () => item == null
                          ? _openShop(context, i)
                          : _openItem(context, i, item),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: (i + i ~/ Village.columns).isEven
                              ? const Color(0xFF8BE064)
                              : const Color(0xFF79D152),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: item == null
                            ? const Text('+',
                                style: TextStyle(
                                    fontSize: 26,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w900))
                            : Text(item.emoji,
                                style: const TextStyle(fontSize: 40)),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              const Mascot(
                message:
                    'Touche une case libre pour construire. Plus tu joues, plus ton village grandit !',
                size: 44,
              ),
            ],
          ),
        );
      },
    );
  }

  void _openShop(BuildContext context, int tile) {
    final store = ProgressStore.instance;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (ctx, scroll) => Column(
          children: [
            const SizedBox(height: 14),
            Text('🛒 Boutique · ${store.coins} 🪙',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.builder(
                controller: scroll,
                padding: const EdgeInsets.all(16),
                itemCount: Village.catalog.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (_, i) {
                  final item = Village.catalog[i];
                  final affordable = store.coins >= item.price;
                  return GestureDetector(
                    onTap: () {
                      if (!affordable) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'Il te manque ${item.price - store.coins} pièces. Joue pour en gagner ! 🎮'),
                        ));
                        return;
                      }
                      store.buildItem(tile, item);
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        backgroundColor: AppColors.green,
                        content: Text('${item.emoji} ${item.name} construit(e) !',
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                      ));
                    },
                    child: Opacity(
                      opacity: affordable ? 1 : 0.4,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.grey, width: 2),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(item.emoji, style: const TextStyle(fontSize: 40)),
                            Text(item.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 13)),
                            Text('${item.price} 🪙',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFB8860B))),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openItem(BuildContext context, int tile, VillageItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${item.emoji} ${item.name}'),
        content: Text(
            'Veux-tu le revendre ? Tu récupères ${item.price ~/ 2} pièces.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Garder')),
          TextButton(
            onPressed: () {
              ProgressStore.instance.sell(tile);
              Navigator.pop(ctx);
            },
            child: const Text('Revendre'),
          ),
        ],
      ),
    );
  }
}
