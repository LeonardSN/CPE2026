import 'package:flutter/material.dart';

import '../logic/progress_store.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'cycle_select_screen.dart';
import 'main_shell.dart';
import 'parent_dashboard_screen.dart';
import 'parent_gate.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = ProgressStore.instance;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Center(
                child: Text(AppInfo.mascotEmoji, style: TextStyle(fontSize: 110)),
              ),
              const SizedBox(height: 12),
              const Text(
                AppInfo.appName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Joue, gagne des pièces et construis ton village !',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.greyDark),
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
              const SizedBox(height: 14),
              ChunkyButton(
                label: 'Espace parent',
                color: Colors.white,
                shadowColor: AppColors.grey,
                textColor: AppColors.blue,
                onPressed: () async {
                  final ok = await showParentGate(context);
                  if (ok && context.mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const ParentDashboardScreen()),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
