import 'dart:math';

import 'package:flutter/material.dart';

import '../logic/progress_store.dart';
import '../models/skill.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../curriculum/curriculum.dart';
import '../games/game_launcher.dart';
import 'cycle_select_screen.dart';

/// Carte de progression façon « chemin » : une leçon débloque la suivante.
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = ProgressStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const CycleSelectScreen(fromMap: true)),
            ),
            child: Text(
              '${Curriculum.current.emoji} ${Curriculum.current.title} ▾',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          actions: [
            StatChip(
                emoji: '🔥', value: '${store.streak}', color: AppColors.orange),
            const SizedBox(width: 16),
            StatChip(
                emoji: '🪙', value: '${store.coins}', color: const Color(0xFFB8860B)),
            const SizedBox(width: 16),
          ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(2),
            child: Divider(height: 2, thickness: 2, color: AppColors.grey),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          children: [
            Mascot(
              message: store.lessonsCompleted == 0
                  ? 'Bonjour ${store.childName} ! Joue pour gagner des pièces 🪙 et construire ton village.'
                  : 'Bravo ${store.childName} ! Chaque partie te rapporte des pièces pour ton village 🏡',
              size: 56,
            ),
            const SizedBox(height: 32),
            for (var i = 0; i < Skills.all.length; i++)
              _LessonNode(index: i, skill: Skills.all[i]),
          ],
        ),
      ),
    );
  }
}

class _LessonNode extends StatelessWidget {
  final int index;
  final Skill skill;

  const _LessonNode({required this.index, required this.skill});

  @override
  Widget build(BuildContext context) {
    final store = ProgressStore.instance;
    final unlocked = store.isUnlocked(index);
    final done = store.isCompleted(skill.id);
    // Zig-zag : décalage horizontal en sinus.
    final offset = sin(index * 1.2) * 80;
    final color = unlocked ? skill.color : AppColors.grey;
    final shadow = unlocked
        ? HSLColor.fromColor(skill.color).withLightness(0.35).toColor()
        : AppColors.greyDark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Transform.translate(
        offset: Offset(offset, 0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => unlocked
                  ? _openSheet(context)
                  : ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Termine la leçon précédente pour débloquer celle-ci 🔒'),
                      ),
                    ),
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: shadow, offset: const Offset(0, 7))],
                ),
                alignment: Alignment.center,
                child: Text(
                  unlocked ? (done ? '⭐' : skill.emoji) : '🔒',
                  style: const TextStyle(fontSize: 34),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              skill.title,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: unlocked ? AppColors.text : AppColors.greyDark,
              ),
            ),
            if (unlocked)
              Text(
                '${store.nextGameFor(skill).emoji} ${store.nextGameFor(skill).label}',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.greyDark, fontWeight: FontWeight.w600),
              ),
          ],
        ),
      ),
    );
  }

  void _openSheet(BuildContext context) {
    final store = ProgressStore.instance;
    final level =
        skill.isBoss ? null : store.levelFor(skill.id);
    final game = store.nextGameFor(skill);
    showModalBottomSheet(
      context: context,
      backgroundColor: skill.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${skill.emoji}  ${skill.title}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              level == null
                  ? '${skill.subtitle} · cible tes points faibles'
                  : '${skill.subtitle} · Niveau $level / 5',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '${game.emoji}  ${game.label}\n${game.description}',
                style: const TextStyle(
                    color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 20),
            ChunkyButton(
              label: 'Jouer  ${game.emoji}',
              color: Colors.white,
              shadowColor: Colors.black26,
              textColor: skill.color,
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => gameScreenFor(skill, game)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
