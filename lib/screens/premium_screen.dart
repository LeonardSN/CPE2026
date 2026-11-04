import 'package:flutter/material.dart';

import '../logic/progress_store.dart';
import '../theme.dart';
import '../widgets/common.dart';

// =====================================================================
//  FREEMIUM
//  L'app est gratuite. De temps en temps (une partie sur trois), une
//  fenêtre propose de passer à Mathou Premium (mensuel, annuel ou familial).
//  VERSION DÉMO : aucun paiement réel n'est effectué.
// =====================================================================

// Tarifs du business plan (Drive de l'équipe).
const premiumMonthly = '6,99 €';
const premiumYearly = '49,99 €';
const premiumYearlyPerMonth = '4,16 €';
const premiumFamily = '79,99 €';

const _benefits = [
  ('🚫', 'Une expérience sans publicité'),
  ('♾️', 'Accès illimité aux exercices'),
  ('📊', 'Suivi détaillé des progressions'),
  ('🎯', 'Parcours de révision personnalisés sur les points faibles'),
];

/// Fenêtre « pub » : propose l'abonnement mensuel.
Future<void> showPremiumPopup(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => const _PremiumPopup(),
  );
}

class _PremiumPopup extends StatefulWidget {
  const _PremiumPopup();

  @override
  State<_PremiumPopup> createState() => _PremiumPopupState();
}

class _PremiumPopupState extends State<_PremiumPopup> {
  int _wait = 3;

  @override
  void initState() {
    super.initState();
    _tick();
  }

  void _tick() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || _wait == 0) return;
      setState(() => _wait--);
      _tick();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 8, 18),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Brand.navy, Brand.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('PUB',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
                    ),
                    const Spacer(),
                    _wait > 0
                        ? Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text('$_wait',
                                style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w900)),
                          )
                        : IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                  ],
                ),
                const MascotImage(size: 110),
                const SizedBox(height: 6),
                const Text('Mathou Premium',
                    style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('Apprends sans interruption !',
                    style: AppText.body.copyWith(color: Colors.white70, fontSize: 15)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (icon, text) in _benefits.take(3))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Text(icon, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(child: Text(text, style: AppText.body.copyWith(fontSize: 15))),
                      ],
                    ),
                  ),
                const SizedBox(height: 6),
                Text('À partir de $premiumYearlyPerMonth / mois',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 12),
                ChunkyButton(
                  label: 'Voir les formules',
                  color: Brand.orange,
                  onPressed: () {
                    final nav = Navigator.of(context);
                    nav.pop();
                    nav.push(MaterialPageRoute(builder: (_) => const PremiumScreen()));
                  },
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: _wait > 0 ? null : () => Navigator.of(context).pop(),
                  child: Text(_wait > 0 ? 'Plus tard ($_wait)' : 'Plus tard'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Page d'abonnement (mensuel ou annuel).
class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  /// 0 = mensuel, 1 = annuel, 2 = familial.
  int _plan = 1;

  @override
  Widget build(BuildContext context) {
    final store = ProgressStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: const Text('Mathou Premium')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          children: [
            const Center(child: MascotImage(size: 130)),
            const SizedBox(height: 6),
            Text(
              store.isPremium ? 'Tu es Premium ⭐' : 'Passe à Premium',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                children: [
                  for (final (icon, text) in _benefits)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Text(icon, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 12),
                          Expanded(child: Text(text, style: AppText.body.copyWith(fontSize: 15))),
                          const Icon(Icons.check_circle, color: AppColors.green),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (!store.isPremium) ...[
              _PlanTile(
                title: 'Mensuel',
                price: '$premiumMonthly / mois',
                note: 'Flexible, sans engagement',
                selected: _plan == 0,
                onTap: () => setState(() => _plan = 0),
              ),
              const SizedBox(height: 10),
              _PlanTile(
                title: 'Annuel',
                price: '$premiumYearly / an',
                note: 'Soit environ $premiumYearlyPerMonth / mois',
                badge: '-40 %',
                selected: _plan == 1,
                onTap: () => setState(() => _plan = 1),
              ),
              const SizedBox(height: 10),
              _PlanTile(
                title: 'Familial',
                price: '$premiumFamily / an',
                note: 'Jusqu\'à 4 profils dans le même foyer · soit environ 1,67 € / mois par enfant',
                badge: '4 profils',
                selected: _plan == 2,
                onTap: () => setState(() => _plan = 2),
              ),
              const SizedBox(height: 18),
              ChunkyButton(
                label: switch (_plan) {
                  0 => 'S\'abonner · $premiumMonthly / mois',
                  1 => 'S\'abonner · $premiumYearly / an',
                  _ => 'S\'abonner · $premiumFamily / an',
                },
                color: Brand.orange,
                onPressed: () async {
                  await store.setPremium(true);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Bienvenue dans Mathou Premium ! ⭐ (démo)'),
                  ));
                },
              ),
            ] else
              ChunkyButton(
                label: 'Résilier (démo)',
                color: context.card,
                textColor: AppColors.red,
                shadowColor: context.colors.outline,
                onPressed: () => store.setPremium(false),
              ),
            const SizedBox(height: 12),
            Text(
              'Version de démonstration pour le Challenge Projets d\'Entreprendre : '
              'aucun paiement réel n\'est effectué.',
              textAlign: TextAlign.center,
              style: AppText.body.copyWith(fontSize: 12, color: context.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  final String title;
  final String price;
  final String note;
  final String? badge;
  final bool selected;
  final VoidCallback onTap;

  const _PlanTile({
    required this.title,
    required this.price,
    required this.note,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        borderColor: selected ? Brand.orange : null,
        color: selected ? Brand.orange.withValues(alpha: 0.1) : null,
        child: Row(
          children: [
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? Brand.orange : context.muted),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                  Text(note, style: AppText.body.copyWith(fontSize: 12, color: context.muted)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(badge!,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
                  ),
                Text(price, style: const TextStyle(fontWeight: FontWeight.w900)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
