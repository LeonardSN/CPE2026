import 'dart:math';

import 'package:flutter/material.dart';

import '../games/game_launcher.dart';
import '../logic/progress_store.dart';
import '../models/skill.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ResultScreen extends StatefulWidget {
  final bool success;
  final int coinsEarned;
  final int xpEarned;
  final double accuracy;
  final int seconds;
  final Skill skill;

  const ResultScreen({
    super.key,
    required this.success,
    required this.coinsEarned,
    required this.xpEarned,
    required this.accuracy,
    required this.seconds,
    required this.skill,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  );

  @override
  void initState() {
    super.initState();
    if (widget.success) _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.success;
    final mins = widget.seconds ~/ 60;
    final secs = widget.seconds % 60;
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.3, end: 1),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.elasticOut,
                      builder: (_, v, child) => Transform.scale(scale: v, child: child),
                      child: Text(s ? '🏆' : AppInfo.mascotEmoji,
                          style: const TextStyle(fontSize: 120)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    s ? 'Leçon terminée !' : 'Plus de cœurs…',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: s ? AppColors.gold : AppColors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s
                        ? 'Tu as gagné ${widget.coinsEarned} pièces 🪙\nVa les dépenser dans ton village !'
                        : 'Ce n\'est pas grave, on apprend en se trompant.\n'
                            '${AppInfo.mascotName} va adapter les calculs pour toi.\n'
                            'Tu gardes les ${widget.coinsEarned} pièces gagnées 🪙',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 17, color: AppColors.greyDark),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      _ResultTile(
                        title: 'Pièces',
                        value: '+${widget.coinsEarned}',
                        color: AppColors.gold,
                      ),
                      const SizedBox(width: 12),
                      _ResultTile(
                        title: 'Précision',
                        value: '${(widget.accuracy * 100).round()} %',
                        color: AppColors.green,
                      ),
                      const SizedBox(width: 12),
                      _ResultTile(
                        title: 'Temps',
                        value: '$mins:${secs.toString().padLeft(2, '0')}',
                        color: AppColors.blue,
                      ),
                    ],
                  ),
                  const Spacer(),
                  ChunkyButton(
                    label: s ? 'Continuer' : 'Réessayer',
                    onPressed: () {
                      if (s) {
                        Navigator.of(context).pop();
                      } else {
                        final store = ProgressStore.instance;
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (_) => gameScreenFor(
                              widget.skill, store.nextGameFor(widget.skill)),
                        ));
                      }
                    },
                  ),
                  if (!s) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Retour à la carte'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (s)
            Positioned.fill(
              child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _anim,
                builder: (_, __) => CustomPaint(
                  size: Size.infinite,
                  painter: _ConfettiPainter(_anim.value),
                ),
              ),
            ),
            ),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _ResultTile({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Text(
                title.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Confettis dessinés à la main (pas besoin de package externe).
class _ConfettiPainter extends CustomPainter {
  final double t;
  static final _pieces = List.generate(70, (i) {
    final r = Random(i);
    return (
      x: r.nextDouble(),
      speed: 0.6 + r.nextDouble() * 0.8,
      delay: r.nextDouble() * 0.3,
      size: 6 + r.nextDouble() * 8,
      spin: r.nextDouble() * 6,
      color: [
        AppColors.green,
        AppColors.blue,
        AppColors.gold,
        AppColors.red,
        AppColors.orange,
        const Color(0xFFCE82FF),
      ][i % 6],
    );
  });

  _ConfettiPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _pieces) {
      final progress = ((t - p.delay) * p.speed * 1.6).clamp(0.0, 1.2);
      if (progress <= 0) continue;
      final y = -20 + progress * (size.height + 40);
      final x = p.x * size.width + sin(progress * 8 + p.spin) * 20;
      final paint = Paint()..color = p.color.withValues(alpha: (1.2 - progress).clamp(0.0, 1.0));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * 10 + p.spin);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.5),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
