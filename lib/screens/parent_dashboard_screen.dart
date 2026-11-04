import 'package:flutter/material.dart';

import '../logic/progress_store.dart';
import '../models/skill.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'premium_screen.dart';

/// Tableau de bord pour les parents : ce qui intéresse le client payeur.
class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = ProgressStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final minutes = (store.totalSeconds / 60).round();
        final avg = store.avgSeconds();
        final reco = store.recommendation;
        return Scaffold(
          appBar: AppBar(
            title: Text('Suivi de ${store.childName}',
                style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ---- Chiffres clés ----
              Row(
                children: [
                  _KpiCard(emoji: '⭐', label: 'XP total', value: '${store.xp}'),
                  const SizedBox(width: 12),
                  _KpiCard(emoji: '🔥', label: 'Série', value: '${store.streak} j'),
                  const SizedBox(width: 12),
                  _KpiCard(
                      emoji: '🏡',
                      label: 'Village',
                      value: '${store.village.length}'),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _KpiCard(
                      emoji: '📚',
                      label: 'Leçons',
                      value: '${store.lessonsCompleted}'),
                  const SizedBox(width: 12),
                  _KpiCard(emoji: '⏱️', label: 'Temps', value: '$minutes min'),
                  const SizedBox(width: 12),
                  _KpiCard(
                      emoji: '🎯',
                      label: 'Réussite',
                      value: '${(store.globalAccuracy * 100).round()} %'),
                ],
              ),
              const SizedBox(height: 20),

              // ---- Abonnement ----
              _Section(
                title: store.isPremium ? '⭐ Mathou Premium' : '⭐ Version gratuite',
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        store.isPremium
                            ? 'Abonnement actif : pas de publicité, toutes les classes, rapports détaillés.'
                            : 'Passez à Premium : sans publicité, rapports détaillés, '
                                'parcours illimité. $premiumMonthly / mois.',
                        style: AppText.body.copyWith(fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: Brand.orange),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const PremiumScreen()),
                      ),
                      child: Text(store.isPremium ? 'Gérer' : 'Découvrir'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ---- Rythme et personnalisation ----
              _Section(
                title: '⏱️ Rythme d\'apprentissage',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InsightLine(
                      color: AppColors.blue,
                      text: avg == null
                          ? 'Temps moyen par réponse : pas encore de données.'
                          : 'Temps moyen par réponse : ${avg.toStringAsFixed(1).replaceAll('.', ',')} s'
                              '${avg < 6 ? ' (rapide ⚡)' : avg > 15 ? ' (prend son temps 🐢)' : ''}.',
                    ),
                    _InsightLine(
                      color: AppColors.green,
                      text: 'Parties ces 7 derniers jours : ${store.sessionsThisWeek}.',
                    ),
                    if (reco != null)
                      _InsightLine(
                        color: Brand.orange,
                        text: 'Prochain chapitre conseillé : ${reco.$1.title} — ${reco.$2.toLowerCase()}.',
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ---- Analyse automatique ----
              _Section(
                title: '🧠 Analyse de ${AppInfo.mascotName}',
                child: _Insights(store: store),
              ),
              const SizedBox(height: 16),

              // ---- Maîtrise par compétence ----
              _Section(
                title: '📊 Maîtrise par compétence',
                child: Column(
                  children: [
                    for (final s in Skills.tracked) _SkillRow(skill: s, store: store),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ---- Historique ----
              _Section(
                title: '🗓️ Dernières leçons',
                child: store.history.isEmpty
                    ? Text('Aucune leçon terminée pour l\'instant.',
                        style: TextStyle(color: context.muted))
                    : Column(
                        children: [
                          for (final h in store.history
                              .where((h) => Skills.tryById(h.skillId) != null)
                              .take(6))
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Text(Skills.byId(h.skillId).emoji,
                                  style: const TextStyle(fontSize: 26)),
                              title: Text(Skills.byId(h.skillId).title,
                                  style: const TextStyle(fontWeight: FontWeight.w700)),
                              subtitle: Text(
                                  '${_fmtDate(h.date)} · ${h.correct}/${h.total} bonnes réponses'),
                              trailing: Text(
                                '${(h.seconds / 60).ceil()} min',
                                style: TextStyle(color: context.muted),
                              ),
                            ),
                        ],
                      ),
              ),
              const SizedBox(height: 16),

              // ---- Outils de démo ----
              _Section(
                title: '⚙️ Réglages',
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text('🌗 Apparence', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                        SegmentedButton<String>(
                          showSelectedIcon: false,
                          segments: const [
                            ButtonSegment(value: 'system', label: Text('Auto')),
                            ButtonSegment(value: 'light', label: Text('Clair')),
                            ButtonSegment(value: 'dark', label: Text('Sombre')),
                          ],
                          selected: {store.themeMode},
                          onSelectionChanged: (v) => store.setThemeMode(v.first),
                        ),
                      ],
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('🔊 Effets sonores'),
                      value: store.soundOn,
                      onChanged: store.setSound,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('🎵 Musique dans les jeux'),
                      value: store.musicOn,
                      onChanged: store.setMusic,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Débloquer toutes les leçons'),
                      value: store.unlockAll,
                      onChanged: store.setUnlockAll,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        icon: const Icon(Icons.restart_alt, color: AppColors.red),
                        label: const Text('Réinitialiser la progression',
                            style: TextStyle(color: AppColors.red)),
                        onPressed: () => _confirmReset(context, store),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  Future<void> _confirmReset(BuildContext context, ProgressStore store) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tout réinitialiser ?'),
        content: const Text('XP, série, niveaux et historique seront effacés.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Réinitialiser')),
        ],
      ),
    );
    if (ok == true) await store.resetAll();
  }
}

class _Insights extends StatelessWidget {
  final ProgressStore store;

  const _Insights({required this.store});

  @override
  Widget build(BuildContext context) {
    final weak = store.weakestSkill;
    final strong = store.strongestSkill;
    if (weak == null) {
      return const Text(
        'Pas encore assez de réponses pour une analyse. '
        'Après quelques exercices, vous verrez ici les points forts et '
        'les points à travailler de votre enfant.',
        style: TextStyle(fontSize: 15, height: 1.4),
      );
    }
    final weakPct = (store.masteryOf(weak.id) * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (strong != null && strong.id != weak.id)
          _InsightLine(
            color: AppColors.green,
            text: 'Point fort : ${strong.title} '
                '(${(store.accuracyOf(strong.id) * 100).round()} % de réussite).',
          ),
        _InsightLine(
          color: AppColors.orange,
          text: 'À travailler : ${weak.title} (maîtrise $weakPct %).',
        ),
        _InsightLine(
          color: AppColors.blue,
          text: 'Conseil : 5 minutes de « ${weak.title} » par jour cette semaine. '
              '${AppInfo.mascotName} adapte déjà la difficulté automatiquement.',
        ),
      ],
    );
  }
}

class _InsightLine extends StatelessWidget {
  final Color color;
  final String text;

  const _InsightLine({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 6, right: 10),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Expanded(
            child: Text(text, style: AppText.body.copyWith(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

class _SkillRow extends StatelessWidget {
  final Skill skill;
  final ProgressStore store;

  const _SkillRow({required this.skill, required this.store});

  @override
  Widget build(BuildContext context) {
    final tried = (store.attempts[skill.id] ?? 0) > 0;
    final m = store.masteryOf(skill.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('${skill.emoji}  ${skill.title}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const Spacer(),
              Text(
                tried
                    ? 'Niv. ${store.levelFor(skill.id)} · ${(m * 100).round()} %'
                    : 'Pas commencé',
                style: TextStyle(color: context.muted, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          RoundedProgress(value: tried ? m : 0, color: skill.color, height: 12),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;

  const _KpiCard({required this.emoji, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.outline, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            Text(label, style: TextStyle(color: context.muted)),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.outline, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
