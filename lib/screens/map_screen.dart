import 'dart:math';

import 'package:flutter/material.dart';

import '../curriculum/curriculum.dart';
import '../games/game_launcher.dart';
import '../logic/progress_store.dart';
import '../models/skill.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'cycle_select_screen.dart';
import 'exercise_screen.dart';

/// Carte de progression façon « chemin » : une leçon débloque la suivante.
/// En haut : le chapitre conseillé et la révision express (personnalisation).
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = ProgressStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final reco = store.recommendation;
        final hasPlayed = store.attempts.values.fold(0, (a, b) => a + b) > 0;
        return Scaffold(
          appBar: AppBar(
            title: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CycleSelectScreen(fromMap: true)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${Curriculum.current.emoji} ${Curriculum.current.title} ▾',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                    Text(Curriculum.currentSchool.title,
                        style: TextStyle(fontSize: 12, color: context.muted, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
            actions: [
              StatChip(emoji: '🔥', value: '${store.streak}', color: Brand.orange),
              const SizedBox(width: 14),
              StatChip(emoji: '🪙', value: '${store.coins}', color: const Color(0xFFB8860B)),
              const SizedBox(width: 14),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(2),
              child: Divider(height: 2, thickness: 2, color: context.colors.outline),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            children: [
              Mascot(
                message: store.lessonsCompleted == 0
                    ? 'Bonjour ${store.childName} ! Joue pour gagner des pièces 🪙 et construire ton village.'
                    : 'Bravo ${store.childName} ! Je te prépare un parcours rien que pour toi 🎯',
                size: 64,
              ),
              const SizedBox(height: 16),
              if (reco != null) _RecoCard(skill: reco.$1, reason: reco.$2),
              if (hasPlayed) ...[
                const SizedBox(height: 10),
                _ReviewCard(),
              ],
              const SizedBox(height: 26),
              for (var i = 0; i < Skills.all.length; i++)
                _LessonNode(
                  index: i,
                  skill: Skills.all[i],
                  recommended: reco?.$1.id == Skills.all[i].id,
                ),
            ],
          ),
        );
      },
    );
  }
}

/// « 🎯 Recommandé pour toi » : le chapitre choisi par l'algorithme.
class _RecoCard extends StatelessWidget {
  final Skill skill;
  final String reason;

  const _RecoCard({required this.skill, required this.reason});

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    return AppCard(
      borderColor: primary,
      color: primary.withValues(alpha: context.isDark ? 0.18 : 0.08),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Text(skill.emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🎯 Recommandé pour toi',
                    style: TextStyle(fontWeight: FontWeight.w900, color: primary, fontSize: 13)),
                Text(skill.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                Text(reason, style: AppText.body.copyWith(fontSize: 13, color: context.muted)),
              ],
            ),
          ),
          IconButton.filled(
            onPressed: () => openChapterSheet(context, skill),
            icon: const Icon(Icons.play_arrow_rounded),
          ),
        ],
      ),
    );
  }
}

/// « 🔁 Révision express » : mélange les points faibles et ce qui n'a pas été revu.
class _ReviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final review = Curriculum.current.review;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          const Text('🔁', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Révision express', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                Text('Tes points faibles et ce que tu n\'as pas revu',
                    style: AppText.body.copyWith(fontSize: 12, color: context.muted)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => openChapterSheet(context, review),
            child: const Text('Réviser', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _LessonNode extends StatelessWidget {
  final int index;
  final Skill skill;
  final bool recommended;

  const _LessonNode({required this.index, required this.skill, this.recommended = false});

  @override
  Widget build(BuildContext context) {
    final store = ProgressStore.instance;
    final unlocked = store.isUnlocked(index);
    final done = store.isCompleted(skill.id);
    // Zig-zag : décalage horizontal en sinus.
    final offset = sin(index * 1.2) * 80;
    final locked = context.isDark ? const Color(0xFF3C3C3C) : AppColors.grey;
    final color = unlocked ? skill.color : locked;
    final shadow = unlocked ? darker(skill.color, 0.18) : darker(locked, 0.15);

    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Transform.translate(
        offset: Offset(offset, 0),
        child: Column(
          children: [
            if (recommended)
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: context.colors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('🎯 Pour toi',
                    style: TextStyle(
                        color: context.colors.onPrimary, fontWeight: FontWeight.w900, fontSize: 12)),
              ),
            GestureDetector(
              onTap: () => unlocked
                  ? openChapterSheet(context, skill)
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
                  style: TextStyle(fontSize: 34, color: onColor(color)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              skill.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: unlocked ? null : context.muted,
              ),
            ),
            if (unlocked)
              Text(
                skill.exerciseOnly
                    ? '✏️ Exercices'
                    : '${store.nextGameFor(skill).emoji} ${store.nextGameFor(skill).label}',
                style: TextStyle(fontSize: 12, color: context.muted, fontWeight: FontWeight.w700),
              ),
          ],
        ),
      ),
    );
  }
}

/// Fenêtre d'un chapitre : jouer en mini-jeu ou s'entraîner en mode Exercices.
void openChapterSheet(BuildContext context, Skill skill) {
  final store = ProgressStore.instance;
  final level = skill.isBoss ? null : store.levelFor(skill.id);
  final game = store.nextGameFor(skill);
  final fg = onColor(skill.color);
  showModalBottomSheet(
    context: context,
    backgroundColor: skill.color,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${skill.emoji}  ${skill.title}',
              style: TextStyle(color: fg, fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            MathText(
              level == null
                  ? '${skill.subtitle} · cible tes points faibles'
                  : '${skill.subtitle} · Niveau $level / 5',
              style: AppText.body.copyWith(color: fg, fontSize: 15),
            ),
            const SizedBox(height: 16),
            if (!skill.exerciseOnly) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${game.emoji}  ${game.label}\n${game.description}',
                  style: AppText.body.copyWith(color: fg, fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),
              ChunkyButton(
                label: 'Mini-jeu  ${game.emoji}',
                color: Colors.white,
                shadowColor: Colors.black26,
                textColor: darker(skill.color, 0.1),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => gameScreenFor(skill, game)),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
            ChunkyButton(
              label: 'Exercices  ✏️',
              color: skill.exerciseOnly ? Colors.white : Colors.white.withValues(alpha: 0.25),
              shadowColor: Colors.black26,
              textColor: skill.exerciseOnly ? darker(skill.color, 0.1) : fg,
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ExerciseScreen(skill: skill)),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              skill.exerciseOnly
                  ? 'Place les points sur le graphique.'
                  : 'Mode Exercices : écris ta réponse dans la case, comme un vrai devoir.',
              textAlign: TextAlign.center,
              style: AppText.body.copyWith(color: fg.withValues(alpha: 0.85), fontSize: 12),
            ),
          ],
        ),
      ),
    ),
  );
}
