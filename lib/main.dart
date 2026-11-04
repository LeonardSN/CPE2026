import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'curriculum/curriculum.dart';
import 'logic/progress_store.dart';
import 'screens/onboarding_screen.dart';
import 'screens/welcome_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await ProgressStore.instance.load();
  runApp(const MathouApp());
}

class MathouApp extends StatelessWidget {
  const MathouApp({super.key});

  @override
  Widget build(BuildContext context) {
    final store = ProgressStore.instance;
    // Le thème suit le cycle choisi (Cycle 1 ... Lycée) et le mode clair/sombre.
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final schoolId = Curriculum.currentSchool.id;
        return MaterialApp(
          title: AppInfo.appName,
          debugShowCheckedModeBanner: false,
          theme: buildTheme(schoolId, Brightness.light),
          darkTheme: buildTheme(schoolId, Brightness.dark),
          themeMode: switch (store.themeMode) {
            'light' => ThemeMode.light,
            'dark' => ThemeMode.dark,
            _ => ThemeMode.system,
          },
          home: store.childName.isEmpty
              ? const OnboardingScreen()
              : const WelcomeScreen(),
        );
      },
    );
  }
}
