import 'package:flutter/material.dart';

import '../logic/sound.dart';
import '../models/game_type.dart';
import '../widgets/math_text.dart';
import 'game_base.dart';

class FruitsGame extends GameScreen {
  const FruitsGame({super.key, required super.skill});

  @override
  State<FruitsGame> createState() => _FruitsGameState();
}

class _FruitsGameState extends GameState<FruitsGame> {
  static const _lanes = 3;
  static const _fruitEmojis = ['🍎', '🍊', '🍋', '🍉', '🥭', '🍇', '🍓', '🍍'];
  static const _basketY = 0.72; // hauteur du panier (0 = haut, 1 = bas)

  int _basketLane = 1;
  double _fruitY = 0; // 0 = haut de la zone de jeu
  double _speed = 0.15;
  List<String> _emojis = [];
  bool _resolved = false;
  String? _caught;

  @override
  GameType get gameType => GameType.fruits;

  @override
  int get numChoices => _lanes;

  @override
  Color get backgroundColor => const Color(0xFFE8F8E0);

  @override
  void onNewQuestion() {
    _fruitY = -0.1;
    _resolved = false;
    _caught = null;
    _speed = 0.10 + 0.012 * current.level;
    _emojis = ([..._fruitEmojis]..shuffle(rng)).take(_lanes).toList();
  }

  @override
  void onTick(double dt) {
    _fruitY += _speed * dt;
    if (!_resolved && _fruitY >= _basketY - 0.06) {
      _resolved = true;
      _caught = current.choices[_basketLane];
      Sfx.play(Sound.catchFruit, volume: 0.7);
      submit(_caught);
    }
  }

  void _moveTo(int lane) {
    if (_resolved || paused) return;
    setState(() => _basketLane = lane.clamp(0, _lanes - 1));
  }

  @override
  Widget buildGame(BuildContext context) {
    return Column(
      children: [
        questionBanner(),
        Expanded(
          child: LayoutBuilder(builder: (context, c) {
            final w = c.maxWidth, h = c.maxHeight;
            final laneW = w / _lanes;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (d) => _moveTo((d.localPosition.dx / laneW).floor()),
              onHorizontalDragUpdate: (d) =>
                  _moveTo((d.localPosition.dx / laneW).floor()),
              child: Stack(
                children: [
                  // colonnes
                  for (var i = 0; i < _lanes; i++)
                    Positioned(
                      left: i * laneW,
                      top: 0,
                      bottom: 0,
                      width: laneW,
                      child: Container(
                        color: i == _basketLane
                            ? Colors.white.withValues(alpha: 0.45)
                            : Colors.transparent,
                      ),
                    ),
                  // arbre en haut
                  const Positioned(
                    top: -18,
                    left: 0,
                    right: 0,
                    child: Center(
                        child: Text('🌳🌳🌳', style: TextStyle(fontSize: 54))),
                  ),
                  // fruits qui tombent
                  for (var i = 0; i < _lanes; i++)
                    if (!(_resolved && current.choices[i] == _caught))
                      Positioned(
                        left: i * laneW + laneW / 2 - 40,
                        top: _fruitY * h,
                        child: _FruitView(
                          emoji: _emojis[i],
                          label: current.choices[i],
                        ),
                      ),
                  // panier
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 120),
                    left: _basketLane * laneW + laneW / 2 - 50,
                    top: _basketY * h,
                    child: SizedBox(
                      width: 100,
                      child: Column(
                        children: [
                          if (_caught != null)
                            Text(
                              _caught == current.answer ? '⭐' : '💦',
                              style: const TextStyle(fontSize: 26),
                            ),
                          const Text('🧺', style: TextStyle(fontSize: 60)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          color: const Color(0xFF8B5A2B),
          child: Text(
            '👆 Touche une colonne ou glisse ton doigt pour bouger le panier',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontWeight: FontWeight.w700, color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }
}

class _FruitView extends StatelessWidget {
  final String emoji;
  final String label;

  const _FruitView({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 52)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black26, width: 2),
            ),
            child: MathText(
              label,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
