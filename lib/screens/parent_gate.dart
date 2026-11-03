import 'dart:math';

import 'package:flutter/material.dart';

import '../theme.dart';

/// Contrôle parental simple (comme dans les vraies apps pour enfants) :
/// une multiplication qu'un jeune enfant ne sait pas encore faire.
Future<bool> showParentGate(BuildContext context) async {
  final rng = Random();
  final a = 6 + rng.nextInt(4);
  final b = 6 + rng.nextInt(4);
  final controller = TextEditingController();

  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Espace parent 🔒'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Pour continuer, combien font $a × $b ?',
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            onSubmitted: (v) => Navigator.of(ctx).pop(v.trim() == '${a * b}'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.blue),
          onPressed: () =>
              Navigator.of(ctx).pop(controller.text.trim() == '${a * b}'),
          child: const Text('Valider'),
        ),
      ],
    ),
  );

  if (result == false && context.mounted && controller.text.isNotEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mauvaise réponse 🙂')),
    );
  }
  return result ?? false;
}
