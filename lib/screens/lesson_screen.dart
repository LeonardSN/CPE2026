import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../logic/exercise_generator.dart';
import '../logic/progress_store.dart';
import '../models/exercise.dart';
import '../models/skill.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'result_screen.dart';

/// Quiz classique (ancienne version, conservé comme mode « entraînement »).
class LessonScreen extends StatefulWidget {
  final Skill skill;

  const LessonScreen({super.key, required this.skill});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  static const goal = 8; // bonnes réponses pour finir la leçon
  static const maxHearts = 3;
  static const _praise = ['Bravo !', 'Super !', 'Génial !', 'Excellent !', 'Trop fort !'];

  final _rng = Random();
  late final ExerciseGenerator _generator = ExerciseGenerator(_rng);
  final _store = ProgressStore.instance;
  final _retry = <Exercise>[];
  final _start = DateTime.now();
  late final int _xpAtStart;

  late Exercise _ex;
  String _answer = '';
  bool _checked = false;
  bool _lastCorrect = false;
  int _hearts = maxHearts;
  int _correctCount = 0;
  int _answered = 0;
  int _rightAnswers = 0;
  int _questionIndex = 0;

  @override
  void initState() {
    super.initState();
    _xpAtStart = _store.xp;
    _ex = _nextExercise();
  }

  Exercise _nextExercise() {
    _questionIndex++;
    final remaining = goal - _correctCount;
    final useRetry = _retry.isNotEmpty &&
        (_questionIndex % 3 == 0 || remaining <= _retry.length);
    if (useRetry) return _retry.removeAt(0);

    final skillId = widget.skill.isBoss
        ? _store.pickBossSkill(_rng)
        : widget.skill.id;
    return _generator.generate(skillId, _store.levelFor(skillId));
  }

  void _check() {
    final correct = _ex.check(_answer);
    final levelUp = _store.recordAnswer(_ex, correct);
    HapticFeedback.mediumImpact();
    setState(() {
      _checked = true;
      _lastCorrect = correct;
      _answered++;
      if (correct) {
        _correctCount++;
        _rightAnswers++;
      } else {
        _hearts--;
        _retry.add(_ex); // l'exercice raté reviendra plus tard
      }
    });
    if (levelUp != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.blue,
          content: Text(
            '🚀 Niveau $levelUp débloqué en ${Skills.byId(_ex.skillId).title} !',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ),
      );
    }
  }

  Future<void> _continue() async {
    final seconds = DateTime.now().difference(_start).inSeconds;
    if (_hearts <= 0 || _correctCount >= goal) {
      final success = _correctCount >= goal;
      if (success) {
        await _store.completeLesson(widget.skill.id, _rightAnswers, _answered, seconds);
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            success: success,
            coinsEarned: 0,
            xpEarned: _store.xp - _xpAtStart,
            accuracy: _answered == 0 ? 0 : _rightAnswers / _answered,
            seconds: seconds,
            skill: widget.skill,
          ),
        ),
      );
      return;
    }
    setState(() {
      _ex = _nextExercise();
      _answer = '';
      _checked = false;
    });
  }

  String get _instruction => switch (_ex.type) {
        ExerciseType.multipleChoice => 'Choisis la bonne réponse',
        ExerciseType.input => 'Écris le résultat',
        ExerciseType.trueFalse => 'Vrai ou faux ?',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ---- Barre du haut : quitter, progression, cœurs ----
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.greyDark, size: 30),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(child: RoundedProgress(value: _correctCount / goal)),
                  const SizedBox(width: 12),
                  StatChip(emoji: '❤️', value: '$_hearts', color: AppColors.red),
                ],
              ),
            ),
            // ---- Question ----
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _instruction,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w800),
                          ),
                        ),
                        _LevelBadge(level: _ex.level, skillId: _ex.skillId),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      _ex.prompt,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: _ex.prompt.length > 30 ? 22 : 44,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildAnswerArea(),
                  ],
                ),
              ),
            ),
            // ---- Bas : vérifier / feedback ----
            _buildBottom(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerArea() {
    switch (_ex.type) {
      case ExerciseType.multipleChoice:
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.8,
          children: [
            for (final c in _ex.choices)
              _ChoiceCard(
                label: c,
                selected: _answer == c,
                onTap: _checked ? null : () => setState(() => _answer = c),
              ),
          ],
        );
      case ExerciseType.trueFalse:
        return Row(
          children: [
            for (final c in const ['vrai', 'faux']) ...[
              Expanded(
                child: SizedBox(
                  height: 90,
                  child: _ChoiceCard(
                    label: c == 'vrai' ? '✅  Vrai' : '❌  Faux',
                    selected: _answer == c,
                    onTap: _checked ? null : () => setState(() => _answer = c),
                  ),
                ),
              ),
              if (c == 'vrai') const SizedBox(width: 14),
            ],
          ],
        );
      case ExerciseType.input:
        return Column(
          children: [
            Container(
              height: 72,
              width: 180,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                    color: _answer.isEmpty ? AppColors.grey : AppColors.blue,
                    width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _answer.isEmpty ? '?' : _answer,
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  color: _answer.isEmpty ? AppColors.greyDark : AppColors.text,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _NumPad(
              enabled: !_checked,
              onDigit: (d) {
                if (_answer.length < 4) setState(() => _answer += d);
              },
              onDelete: () {
                if (_answer.isNotEmpty) {
                  setState(() => _answer = _answer.substring(0, _answer.length - 1));
                }
              },
            ),
          ],
        );
    }
  }

  Widget _buildBottom() {
    if (!_checked) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.grey, width: 2)),
        ),
        child: ChunkyButton(
          label: 'Vérifier',
          onPressed: _answer.isEmpty ? null : _check,
        ),
      );
    }
    final ok = _lastCorrect;
    final title = ok
        ? '${_praise[_rng.nextInt(_praise.length)]} 🎉'
        : 'Pas tout à fait… 🤔';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      color: ok ? AppColors.lightGreen : AppColors.lightRed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: ok ? AppColors.greenDark : AppColors.redDark,
            ),
          ),
          if (!ok) ...[
            const SizedBox(height: 8),
            if (_ex.type != ExerciseType.trueFalse)
              Text(
                'Bonne réponse : ${_ex.answer}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.redDark,
                ),
              ),
            const SizedBox(height: 6),
            Text(
              '${AppInfo.mascotEmoji} ${_ex.explanation}',
              style: const TextStyle(fontSize: 15, color: AppColors.redDark, height: 1.35),
            ),
          ],
          const SizedBox(height: 14),
          ChunkyButton(
            label: 'Continuer',
            color: ok ? AppColors.green : AppColors.red,
            shadowColor: ok ? AppColors.greenDark : AppColors.redDark,
            onPressed: _continue,
          ),
        ],
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final int level;
  final String skillId;

  const _LevelBadge({required this.level, required this.skillId});

  @override
  Widget build(BuildContext context) {
    final skill = Skills.byId(skillId);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: skill.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${skill.emoji} Niv. $level',
        style: TextStyle(fontWeight: FontWeight.w800, color: skill.color),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _ChoiceCard({required this.label, required this.selected, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFDDF4FF) : Colors.white,
          border: Border.all(
            color: selected ? AppColors.blue : AppColors.grey,
            width: 2.5,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: selected ? const Color(0xFF84D8FF) : AppColors.grey,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: selected ? AppColors.blue : AppColors.text,
          ),
        ),
      ),
    );
  }
}

/// Pavé numérique adapté aux enfants (plus simple que le clavier du téléphone).
class _NumPad extends StatelessWidget {
  final bool enabled;
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;

  const _NumPad({required this.enabled, required this.onDigit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.2,
      children: [
        for (final k in keys)
          if (k.isEmpty)
            const SizedBox.shrink()
          else
            Material(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: !enabled
                    ? null
                    : () {
                        if (k == '⌫') {
                          onDelete();
                        } else {
                          onDigit(k);
                        }
                      },
                child: Center(
                  child: Text(
                    k,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
      ],
    );
  }
}
