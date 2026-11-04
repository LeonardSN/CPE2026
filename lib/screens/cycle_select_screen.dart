import 'package:flutter/material.dart';

import '../curriculum/curriculum.dart';
import '../curriculum/cycle.dart';
import '../logic/progress_store.dart';
import '../theme.dart';
import 'main_shell.dart';

/// « Choisis ton niveau » : Primaire (puis la classe), Collège, Lycée.
class CycleSelectScreen extends StatelessWidget {
  /// true si on vient de la carte : on revient en arrière après le choix.
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
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 24),
            for (final school in Curriculum.schools) ...[
              _BigCard(
                emoji: school.emoji,
                title: school.title,
                subtitle: school.subtitle,
                info: !school.isAvailable
                    ? '🚧 Bientôt disponible'
                    : school.hasSeveralGrades
                        ? school.grades.map((g) => g.title).join(' · ')
                        : '${school.grades.first.chapters.length} chapitres + 1 boss',
                color: school.color,
                enabled: school.isAvailable,
                selected: Curriculum.schoolOf(Curriculum.current) == school &&
                    ProgressStore.instance.cycleId.isNotEmpty,
                onTap: () => _chooseSchool(context, school),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  void _chooseSchool(BuildContext context, School school) {
    if (!school.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${school.emoji} ${school.title} arrive bientôt !')),
      );
      return;
    }
    if (!school.hasSeveralGrades) {
      _chooseGrade(context, school.grades.first);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _GradeSelectScreen(
          school: school,
          onChoose: (ctx, grade) => _chooseGrade(ctx, grade, popExtra: true),
        ),
      ),
    );
  }

  Future<void> _chooseGrade(BuildContext context, Cycle grade,
      {bool popExtra = false}) async {
    await ProgressStore.instance.setCycle(grade.id);
    if (!context.mounted) return;
    final nav = Navigator.of(context);
    if (fromMap) {
      if (popExtra) nav.pop(); // écran des classes
      nav.pop(); // écran des écoles
    } else {
      nav.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => route.isFirst,
      );
    }
  }
}

/// Choix de la classe (CP, CE1, CE2, CM1, CM2).
class _GradeSelectScreen extends StatelessWidget {
  final School school;
  final void Function(BuildContext, Cycle) onChoose;

  const _GradeSelectScreen({required this.school, required this.onChoose});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Text(
              '${school.emoji} Quelle classe ?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 20),
            for (final g in school.grades) ...[
              _BigCard(
                emoji: g.emoji,
                title: g.title,
                subtitle: g.subtitle,
                info: g.isAvailable
                    ? '${g.chapters.length} chapitres + 1 boss'
                        '${g.id == school.recommendedGradeId ? '  ·  ⭐ Conseillé' : ''}'
                    : '🚧 Bientôt disponible',
                color: g.color,
                enabled: g.isAvailable,
                selected: Curriculum.current.id == g.id &&
                    ProgressStore.instance.cycleId.isNotEmpty,
                compact: true,
                onTap: () {
                  if (!g.isAvailable) return;
                  onChoose(context, g);
                },
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _BigCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String info;
  final Color color;
  final bool enabled;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  const _BigCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.info,
    required this.color,
    required this.enabled,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = enabled ? color : AppColors.greyDark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(compact ? 14 : 18),
        decoration: BoxDecoration(
          color: enabled
              ? c.withValues(alpha: context.isDark ? 0.22 : 0.12)
              : (context.isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF2F2F2)),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: c, width: selected ? 4 : 2),
          boxShadow: [
            BoxShadow(color: c.withValues(alpha: 0.5), offset: const Offset(0, 5))
          ],
        ),
        child: Row(
          children: [
            Text(emoji, style: TextStyle(fontSize: compact ? 40 : 52)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: compact ? 22 : 24,
                          fontWeight: FontWeight.w900,
                          color: context.isDark && c.computeLuminance() < 0.2 ? Colors.white : c)),
                  Text(subtitle,
                      style: AppText.body.copyWith(fontSize: 14, color: context.muted)),
                  const SizedBox(height: 4),
                  Text(info,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: enabled ? null : context.muted)),
                ],
              ),
            ),
            if (enabled) Icon(Icons.chevron_right, color: c, size: 32),
          ],
        ),
      ),
    );
  }
}
