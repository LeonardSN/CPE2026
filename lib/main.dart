import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    return MaterialApp(
      title: AppInfo.appName,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: store.childName.isEmpty
          ? const OnboardingScreen()
          : const WelcomeScreen(),
    );
  }
}
