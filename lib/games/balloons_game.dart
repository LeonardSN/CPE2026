import 'package:flutter/material.dart';

import '../models/game_type.dart';
import 'game_base.dart';

class BalloonsGame extends GameScreen {
  const BalloonsGame({super.key, required super.skill});

  @override
  State<BalloonsGame> createState() => _BalloonsGameState();
}

class _Balloon {
  final String label;
  final double x; // 0..1 (centre horizontal)
  double y; // 0 = bas de l'écran, 1 = haut
  final double speed;
  final Color color;
  bool popped = false;
  bool wrong = false;

  _Balloon(this.label, this.x, this.y, this.speed, this.color);
}

class _BalloonsGameState extends GameState<BalloonsGame> {
  static const _colors = [
    Color(0xFFFF4B4B),
    Color(0xFF1CB0F6),
    Color(0xFFFFC800),
    Color(0xFFCE82FF),
    Color(0xFF58CC02),
    Color(0xFFFF9600),
  ];

  List<_Balloon> _balloons = [];
  bool _escaped = false;

  @override
  GameType get gameType => GameType.balloons;

  @override
  Color get backgroundColor => const Color(0xFFBFE9FF);

  @override
  void onNewQuestion() {
    _escaped = false;
    final n = current.choices.length;
    final base = 0.11 + 0.012 * current.level; // vitesse (écran / seconde)
    final colors = [..._colors]..shuffle(rng);
    _balloons = [
      for (var i = 0; i < n; i++)
        _Balloon(
          current.choices[i],
          (i + 0.5) / n + (rng.nextDouble() - 0.5) * 0.06,
          -0.25 - rng.nextDouble() * 0.25,
          base * (0.85 + rng.nextDouble() * 0.3),
          colors[i % colors.length],
        ),
    ];
  }

  @override
  void onTick(double dt) {
    for (final b in _balloons) {
      if (!b.popped) b.y += b.speed * dt;
    }
    // La bonne réponse s'est envolée : c'est raté.
    final good = _balloons.where((b) => b.label == current.answer);
    if (!_escaped && good.isNotEmpty && good.first.y > 1.05 && !good.first.popped) {
      _escaped = true;
      submit(null);
    }
    // Les ballons partis repartent du bas pour laisser une chance.
    for (final b in _balloons) {
      if (!b.popped && b.y > 1.15 && b.label != current.answer) b.y = -0.3;
    }
  }

  void _tap(_Balloon b) {
    if (!acceptsInput || b.popped) return;
    if (b.label == current.answer) {
      b.popped = true;
    } else {
      b.wrong = true;
      b.popped = true;
    }
    submit(b.label);
  }

  @override
  Widget buildGame(BuildContext context) {
    return Column(
      children: [
        questionBanner(),
        Expanded(
          child: LayoutBuilder(builder: (context, c) {
            final w = c.maxWidth, h = c.maxHeight;
            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // nuages décoratifs
                for (final (dx, dy, size) in const [
                  (0.1, 0.15, 46.0),
                  (0.7, 0.3, 60.0),
                  (0.35, 0.6, 40.0),
                  (0.8, 0.75, 50.0),
                ])
                  Positioned(
                    left: dx * w,
                    top: dy * h,
                    child: Text('☁️', style: TextStyle(fontSize: size)),
                  ),
                for (final b in _balloons)
                  Positioned(
                    left: b.x * w - 42,
                    bottom: b.y * h - 60,
                    child: GestureDetector(
                      onTap: () => _tap(b),
                      child: _BalloonView(balloon: b),
                    ),
                  ),
              ],
            );
          }),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          color: const Color(0xFF7ED957),
          child: Text(
            gameType.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontWeight: FontWeight.w700, color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }
}

class _BalloonView extends StatelessWidget {
  final _Balloon balloon;

  const _BalloonView({required this.balloon});

  @override
  Widget build(BuildContext context) {
    if (balloon.popped && !balloon.wrong) {
      return const SizedBox(
        width: 84,
        height: 120,
        child: Center(child: Text('💥', style: TextStyle(fontSize: 64))),
      );
    }
    final color = balloon.wrong ? Colors.grey : balloon.color;
    return SizedBox(
      width: 84,
      height: 120,
      child: Column(
        children: [
          Container(
            width: 84,
            height: 96,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.4, -0.5),
                colors: [Color.lerp(color, Colors.white, 0.45)!, color],
              ),
              borderRadius: const BorderRadius.all(Radius.elliptical(84, 96)),
              boxShadow: const [
                BoxShadow(color: Colors.black26, offset: Offset(2, 4), blurRadius: 4)
              ],
            ),
            child: Text(
              balloon.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                shadows: [Shadow(color: Colors.black38, offset: Offset(1, 2))],
              ),
            ),
          ),
          Container(width: 2, height: 24, color: Colors.black38),
        ],
      ),
    );
  }
}
