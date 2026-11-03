import 'package:flutter/material.dart';

import '../curriculum/curriculum.dart';
import '../curriculum/cycle.dart';
import '../logic/progress_store.dart';
import '../theme.dart';
import 'main_shell.dart';

/// « Choisis ton niveau » : primaire, collège, lycée.
class CycleSelectScreen extends StatelessWidget {
  /// true si on vient de la carte (on revient en arrière au lieu d'ouvrir
  /// une nouvelle carte).
  final bool fromMap;

  const CycleSelectScreen({super.key, this.fromMap = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            const Text(
              'Choisis ton niveau',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tu pourras en changer quand tu veux.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.greyDark, fontSize: 15),
            ),
            const SizedBox(height: 24),
            for (final cycle in Curriculum.cycles) ...[
              _CycleCard(
                cycle: cycle,
                onTap: () => _choose(context, cycle),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _choose(BuildContext context, Cycle cycle) async {
    if (!cycle.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${cycle.emoji} ${cycle.title} arrive bientôt !'),
        ),
      );
      return;
    }
    await ProgressStore.instance.setCycle(cycle.id);
    if (!context.mounted) return;
    if (fromMap) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    }
  }
}

class _CycleCard extends StatelessWidget {
  final Cycle cycle;
  final VoidCallback onTap;

  const _CycleCard({required this.cycle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final available = cycle.isAvailable;
    final selected = Curriculum.current.id == cycle.id &&
        ProgressStore.instance.cycleId.isNotEmpty;
    final color = available ? cycle.color : AppColors.greyDark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: available ? color.withValues(alpha: 0.12) : const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: color, width: selected ? 4 : 2),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            Text(cycle.emoji, style: const TextStyle(fontSize: 52)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cycle.title,
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w900, color: color)),
                  Text(cycle.subtitle,
                      style: const TextStyle(fontSize: 15, color: AppColors.greyDark)),
                  const SizedBox(height: 4),
                  Text(
                    available
                        ? '${cycle.chapters.length} chapitres + 1 boss'
                        : '🚧 Bientôt disponible',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: available ? AppColors.text : AppColors.greyDark),
                  ),
                ],
              ),
            ),
            if (available) Icon(Icons.chevron_right, color: color, size: 32),
          ],
        ),
      ),
    );
  }
}
