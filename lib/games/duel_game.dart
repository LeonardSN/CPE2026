import 'dart:math';

import 'package:flutter/material.dart';

import '../logic/sound.dart';
import '../models/game_type.dart';
import '../theme.dart';
import 'game_base.dart';

class DuelGame extends GameScreen {
  const DuelGame({super.key, required super.skill});

  @override
  State<DuelGame> createState() => _DuelGameState();
}

class _DuelGameState extends GameState<DuelGame> {

  late int _maxHp;
  late int _hp;
  late double _attackEvery;
  double _attackTimer = 0;
  double _hitAt = -10; // moment où le monstre a été touché
  double _attackAt = -10; // moment où le monstre a attaqué
  String _hitText = '';

  @override
  GameType get gameType => GameType.duel;

  @override
  int get goal => _maxHp;

  @override
  bool get isWon => _hp <= 0;

  @override
  double get progress => 1 - _hp / _maxHp;

  @override
  Color get backgroundColor => const Color(0xFF2B2250);

  @override
  void initState() {
    _maxHp = widget.skill.isBoss ? 10 : 8;
    _hp = _maxHp;
    super.initState();
    final level = skill.isBoss ? 3 : store.levelFor(skill.id);
    _attackEvery = max(8.0, 14.0 - level);
  }

  @override
  void onNewQuestion() => _attackTimer = 0;

  @override
  void onTick(double dt) {
    if (busy) return;
    _attackTimer += dt;
    if (_attackTimer >= _attackEvery) {
      _attackTimer = 0;
      _attackAt = gameTime;
      loseHeart();
    }
  }

  @override
  void onCorrect(String choice) {
    final dmg = combo >= 3 ? 2 : 1;
    _hp = max(0, _hp - dmg);
    _hitAt = gameTime;
    Sfx.play(Sound.hit, volume: 0.9);
    _hitText = dmg == 2 ? 'COUP CRITIQUE ! -2' : '-1';
  }

  @override
  void onWrong(String? choice) {
    _attackAt = gameTime;
    _attackTimer = 0;
  }

  @override
  Widget buildGame(BuildContext context) {
    final emoji = skill.monster, name = skill.monsterName;
    final sinceHit = gameTime - _hitAt;
    final sinceAttack = gameTime - _attackAt;
    final shake = sinceHit < 0.35 ? sin(sinceHit * 60) * 12 : 0.0;
    final attackScale = sinceAttack < 0.4 ? 1.0 + (0.4 - sinceAttack) : 1.0;

    return Stack(
      children: [
        if (sinceAttack < 0.3)
          Positioned.fill(
            child: Container(color: Colors.red.withValues(alpha: 0.25)),
          ),
        Column(
          children: [
            const SizedBox(height: 6),
            Text(name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _hp / _maxHp,
                  minHeight: 14,
                  color: AppColors.red,
                  backgroundColor: Colors.white24,
                ),
              ),
            ),
            Text('PV $_hp / $_maxHp',
                style: const TextStyle(
                    color: Colors.white70, fontWeight: FontWeight.w700)),
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Transform.translate(
                      offset: Offset(shake, 0),
                      child: Transform.scale(
                        scale: attackScale,
                        child: Opacity(
                          opacity: isWon ? 0.3 : 1,
                          child: Text(emoji, style: const TextStyle(fontSize: 120)),
                        ),
                      ),
                    ),
                    if (sinceHit < 0.8)
                      Positioned(
                        top: -10 - sinceHit * 40,
                        child: Text(
                          _hitText,
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    if (sinceAttack < 0.5)
                      const Positioned(
                        bottom: -10,
                        child: Text('💥 Aïe !',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900)),
                      ),
                  ],
                ),
              ),
            ),
            // Jauge d'attaque du monstre
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const Text('⚔️', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (_attackTimer / _attackEvery).clamp(0.0, 1.0),
                        minHeight: 8,
                        color: AppColors.orange,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            questionBanner(),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.3,
                children: [
                  for (final choice in current.choices)
                    _CardButton(label: choice, onTap: () => submit(choice)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CardButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CardButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      color: const Color(0xFFFFE9A8),
      elevation: 6,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFB8860B), width: 3),
          ),
          child: Text(
            '⚔️ $label',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}
