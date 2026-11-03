import 'package:flutter/material.dart';

import '../logic/progress_store.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'welcome_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    await ProgressStore.instance.setChildName(name);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              const Spacer(),
              const Center(
                child: Text(AppInfo.mascotEmoji, style: TextStyle(fontSize: 90)),
              ),
              const SizedBox(height: 16),
              const Text(
                'Salut, moi c\'est ${AppInfo.mascotName} !',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Je vais t\'aider à devenir un champion des maths.\n'
                'Comment tu t\'appelles ?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, color: AppColors.greyDark),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _controller,
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  hintText: 'Ton prénom',
                  filled: true,
                  fillColor: const Color(0xFFF7F7F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.grey, width: 2),
                  ),
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _start(),
              ),
              const Spacer(),
              ChunkyButton(
                label: 'C\'est parti !',
                onPressed: _controller.text.trim().isEmpty ? null : _start,
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
