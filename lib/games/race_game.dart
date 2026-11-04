import 'package:flutter/material.dart';

import '../logic/sound.dart';
import '../models/game_type.dart';
import '../theme.dart';
import '../widgets/math_text.dart';
import 'game_base.dart';

class RaceGame extends GameScreen {
  const RaceGame({super.key, required super.skill});

  @override
  State<RaceGame> createState() => _RaceGameState();
}

class _RaceGameState extends GameState<RaceGame> {
  static const _countdown = 3.0;

  double _player = 0; // position affichée (0..1), suit la progression
  double _rival = 0;
  late double _rivalSpeed;
  String? _flash;
  int _lastCount = 4;
  double _flashUntil = 0;

  @override
  GameType get gameType => GameType.race;

  @override
  int get numChoices => 3;

  @override
  bool get usesHearts => false;

  @override
  Color get backgroundColor => const Color(0xFFDFF5D2);

  @override
  bool get acceptsInput => super.acceptsInput && gameTime >= _countdown;

  @override
  void initState() {
    super.initState();
    // Le rival met environ (goal × secondes par question) pour finir.
    final level = skill.isBoss ? 3 : store.levelFor(skill.id);
    final secondsPerQuestion = 8.5 - 0.4 * level;
    _rivalSpeed = 1 / (goal * secondsPerQuestion);
  }

  @override
  void onTick(double dt) {
    final left = (_countdown - gameTime).ceil();
    if (left != _lastCount) {
      _lastCount = left;
      if (left > 0) {
        Sfx.play(Sound.beep);
      } else if (left == 0) {
        Sfx.play(Sound.go);
      }
    }
    if (gameTime < _countdown) return;
    _rival += _rivalSpeed * dt;
    _player += (progress - _player) * (dt * 6).clamp(0.0, 1.0);
    if (_rival >= 1 && !isWon) {
      _rival = 1;
      lose();
    }
  }

  @override
  void onCorrect(String choice) {
    _flash = combo >= 3 ? '🔥 TURBO !' : '💨 Vroum !';
    _flashUntil = gameTime + 0.9;
  }

  @override
  void onWrong(String? choice) {
    _rival = (_rival + 0.05).clamp(0.0, 0.99);
    _flash = '😬 Le rival accélère !';
    _flashUntil = gameTime + 1.2;
  }

  @override
  Widget buildGame(BuildContext context) {
    final countdownLeft = _countdown - gameTime;
    return Column(
      children: [
        const SizedBox(height: 8),
        // ---- Piste ----
        LayoutBuilder(builder: (context, c) {
          final trackW = c.maxWidth - 32 - 60;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF555555),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                _lane(trackW, _player, '🏎️', 'Toi', AppColors.green),
                _dashes(),
                _lane(trackW, _rival, '🚙', 'Rival', AppColors.red),
              ],
            ),
          );
        }),
        SizedBox(
          height: 40,
          child: Center(
            child: Text(
              countdownLeft > 0
                  ? ''
                  : (gameTime < _flashUntil ? (_flash ?? '') : ''),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
          ),
        ),
        Expanded(
          child: countdownLeft > 0
              ? Center(
                  child: Text(
                    '${countdownLeft.ceil()}',
                    style: const TextStyle(
                        fontSize: 110,
                        fontWeight: FontWeight.w900,
                        color: AppColors.orange),
                  ),
                )
              : Column(
                  children: [
                    questionBanner(),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          for (final choice in current.choices)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: _AnswerButton(
                                  label: choice,
                                  onTap: () => submit(choice),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _lane(double trackW, double pos, String car, String name, Color color) {
    return SizedBox(
      height: 64,
      child: Stack(
        children: [
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: const Center(child: Text('🏁', style: TextStyle(fontSize: 32))),
          ),
          Positioned(
            left: 8 + pos.clamp(0.0, 1.0) * trackW,
            top: 0,
            bottom: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.flip(
                  flipX: true,
                  child: Text(car, style: const TextStyle(fontSize: 38)),
                ),
                Text(name,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w900,
                        fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashes() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: List.generate(
            12,
            (_) => Expanded(
              child: Container(
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: Colors.white70,
              ),
            ),
          ),
        ),
      );
}

class _AnswerButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AnswerButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: SizedBox(
          height: 86,
          child: Center(
            child: MathText(
              label,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ),
    );
  }
}
