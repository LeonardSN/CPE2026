import 'package:flutter/material.dart';

import '../curriculum/curriculum.dart';
import '../logic/progress_store.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'cycle_select_screen.dart';
import 'main_shell.dart';
import 'parent_dashboard_screen.dart';
import 'parent_gate.dart';
import 'premium_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = ProgressStore.instance;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: store.isPremium
                            ? const Chip(label: Text('⭐ Premium'))
                            : TextButton.icon(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const PremiumScreen()),
                                ),
                                icon: const Text('⭐'),
                                label: const Text('Premium'),
                              ),
                      ),
                      const Spacer(),
                      const Center(child: MascotImage(size: 190)),
                      const SizedBox(height: 12),
                      const Center(child: MathouLogo(fontSize: 46)),
                      const SizedBox(height: 10),
                      Text(
                        'Joue, gagne des pièces et construis ton village !',
                        textAlign: TextAlign.center,
                        style: AppText.body.copyWith(fontSize: 16, color: context.muted),
                      ),
                      const Spacer(),
                      ChunkyButton(
                        label: 'Jouer (${store.childName})',
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => store.cycleId.isEmpty
                                ? const CycleSelectScreen()
                                : const MainShell(),
                          ),
                        ),
                      ),
                      if (store.cycleId.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          '${Curriculum.currentSchool.title} · ${Curriculum.current.title}',
                          textAlign: TextAlign.center,
                          style: AppText.body.copyWith(color: context.muted, fontSize: 13),
                        ),
                      ],
                      const SizedBox(height: 14),
                      ChunkyButton(
                        label: 'Espace parent',
                        color: context.card,
                        shadowColor: context.colors.outline,
                        textColor: context.isDark ? Colors.white : Brand.navy,
                        onPressed: () async {
                          final ok = await showParentGate(context);
                          if (ok && context.mounted) {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ParentDashboardScreen()),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
