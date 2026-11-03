import 'package:flutter/material.dart';

import '../theme.dart';
import 'map_screen.dart';
import 'village_screen.dart';

/// Navigation de l'enfant : l'aventure (les jeux) et son village.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [MapScreen(), VillageScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        indicatorColor: AppColors.lightGreen,
        destinations: const [
          NavigationDestination(
            icon: Text('🗺️', style: TextStyle(fontSize: 24)),
            label: 'Aventure',
          ),
          NavigationDestination(
            icon: Text('🏡', style: TextStyle(fontSize: 24)),
            label: 'Mon village',
          ),
        ],
      ),
    );
  }
}
