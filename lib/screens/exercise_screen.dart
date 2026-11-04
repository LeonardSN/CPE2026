import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../logic/exercise_generator.dart';
import '../logic/progress_store.dart';
import '../logic/sound.dart';
import '../models/exercise.dart';
import '../models/skill.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/graph_inputs.dart';
import 'result_screen.dart';

/// Mode « Exercices » (façon Mathraining) : un énoncé, une case réponse,
/// un bouton « Soumettre ». Gère aussi les QCM, la droite graduée et le repère.
class ExerciseScreen extends StatefulWidget {
  final Skill skill;

  const ExerciseScreen({super.key, required this.skill});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  static const total = 10;

  final _rng = Random();
  late final ExerciseGenerator _gen = ExerciseGenerator(_rng);
  final _store = ProgressStore.instance;
  final _start = DateTime.now();
  final _retry = <Exercise>[];
  late final int _xpStart;
  late final int _coinsStart;

  late Exercise _ex;
  int _number = 1;
  String _answer = '';
  int? _tick;
  Point<int>? _point;
  bool _checked = false;
  bool _ok = false;
  int _right = 0;
  int _answered = 0;
  DateTime _askedAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    _xpStart = _store.xp;
    _coinsStart = _store.coins;
    _store.registerPlay(widget.skill.id);
    _ex = _next();
  }

  Exercise _next() {
    _askedAt = DateTime.now();
    // Les exercices ratés reviennent une fois en fin de série.
    if (_number > total - _retry.length && _retry.isNotEmpty) return _retry.removeAt(0);
    final skill = widget.skill;
    String id;
    if (skill.isBoss) {
      id = _store.pickBossSkill(_rng, review: skill.isReview);
    } else {
      id = skill.id;
    }
    return _gen.generate(id, _store.levelFor(id), allowTrueFalse: true);
  }

  String get _userAnswer => switch (_ex.type) {
        ExerciseType.numberLine => _tick == null ? '' : '$_tick',
        ExerciseType.grid => _point == null ? '' : '${_point!.x};${_point!.y}',
        _ => _answer,
      };

  void _submit() {
    final ok = _ex.check(_userAnswer);
    final levelUp = _store.recordAnswer(_ex, ok,
        seconds: DateTime.now().difference(_askedAt).inMilliseconds / 1000);
    HapticFeedback.mediumImpact();
    Sfx.play(ok ? Sound.correct : Sound.wrong);
    setState(() {
      _checked = true;
      _ok = ok;
      _answered++;
      if (ok) {
        _right++;
        _store.addCoins(3);
      } else if (_retry.length < 3) {
        _retry.add(_ex);
      }
    });
    if (levelUp != null) {
      Sfx.play(Sound.levelup);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: context.colors.primary,
        content: Text('🚀 Niveau $levelUp débloqué en ${Skills.byId(_ex.skillId).title} !',
            style: TextStyle(fontWeight: FontWeight.w800, color: context.colors.onPrimary)),
      ));
    }
  }

  Future<void> _continue() async {
    if (_number >= total) {
      final seconds = DateTime.now().difference(_start).inSeconds;
      final success = _right >= (total * 0.6).ceil();
      if (success) {
        _store.addCoins(10);
        await _store.completeLesson(widget.skill.id, _right, _answered, seconds);
      }
      Sfx.play(success ? Sound.win : Sound.lose);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => ResultScreen(
          success: success,
          coinsEarned: _store.coins - _coinsStart,
          xpEarned: _store.xp - _xpStart,
          accuracy: _answered == 0 ? 0 : _right / _answered,
          seconds: seconds,
          skill: widget.skill,
          retry: () => ExerciseScreen(skill: widget.skill),
        ),
      ));
      return;
    }
    setState(() {
      _number++;
      _ex = _next();
      _answer = '';
      _tick = null;
      _point = null;
      _checked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final chapter = Skills.tryById(_ex.skillId);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 6, 16, 6),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: context.muted, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(child: RoundedProgress(value: (_number - 1) / total, height: 14)),
                  const SizedBox(width: 12),
                  Text('$_right / $total',
                      style: TextStyle(fontWeight: FontWeight.w900, color: context.colors.primary)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ---- Énoncé ----
                    AppCard(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Exercice $_number',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: context.colors.primary,
                                      fontSize: 15)),
                              const Spacer(),
                              if (chapter != null)
                                Text('${chapter.emoji} ${chapter.title} · niv. ${_ex.level}',
                                    style: TextStyle(fontSize: 12, color: context.muted, fontWeight: FontWeight.w700)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: MathText(
                              _ex.prompt,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: _ex.prompt.length > 34 ? 20 : 30,
                                fontWeight: FontWeight.w800,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _answerArea(),
                  ],
                ),
              ),
            ),
            _bottom(),
          ],
        ),
      ),
    );
  }

  Widget _answerArea() {
    switch (_ex.type) {
      case ExerciseType.numberLine:
        return AppCard(
          child: NumberLineInput(
            spec: _ex.graph!,
            selected: _tick,
            showCorrect: _checked,
            onSelect: _checked ? null : (t) => setState(() => _tick = t),
          ),
        );
      case ExerciseType.grid:
        return AppCard(
          padding: const EdgeInsets.all(10),
          child: GridInput(
            spec: _ex.graph!,
            selected: _point,
            showCorrect: _checked,
            onSelect: _checked ? null : (p) => setState(() => _point = p),
          ),
        );
      case ExerciseType.multipleChoice:
      case ExerciseType.trueFalse:
        final options = _ex.type == ExerciseType.trueFalse ? const ['vrai', 'faux'] : _ex.choices;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            for (final o in options)
              _ChoiceTile(
                label: o == 'vrai' ? '✅ Vrai' : (o == 'faux' ? '❌ Faux' : o),
                selected: _answer == o,
                correct: _checked && _ex.check(o),
                wrong: _checked && _answer == o && !_ex.check(o),
                onTap: _checked ? null : () => setState(() => _answer = o),
              ),
          ],
        );
      case ExerciseType.input:
        return Column(
          children: [
            Text('Ta réponse :', style: AppText.body.copyWith(color: context.muted)),
            const SizedBox(height: 8),
            // La « case » façon Mathraining
            Container(
              width: 200,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  width: 3,
                  color: _checked
                      ? (_ok ? AppColors.green : AppColors.red)
                      : (_answer.isEmpty ? context.colors.outline : context.colors.primary),
                ),
              ),
              child: Text(
                _answer.isEmpty ? ' ' : _answer,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 16),
            _Keypad(
              enabled: !_checked,
              onKey: (k) => setState(() {
                if (k == '⌫') {
                  if (_answer.isNotEmpty) _answer = _answer.substring(0, _answer.length - 1);
                } else if (k == '±') {
                  _answer = _answer.startsWith('−') ? _answer.substring(1) : '−$_answer';
                } else if (_answer.replaceAll('−', '').length < 6) {
                  _answer += k;
                }
              }),
            ),
          ],
        );
    }
  }

  Widget _bottom() {
    if (!_checked) {
      return Container(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: context.colors.outline, width: 2)),
        ),
        child: ChunkyButton(
          label: 'Soumettre',
          onPressed: _userAnswer.isEmpty || _userAnswer == '−' ? null : _submit,
        ),
      );
    }
    final bg = _ok
        ? AppColors.green.withValues(alpha: context.isDark ? 0.25 : 0.18)
        : AppColors.red.withValues(alpha: context.isDark ? 0.25 : 0.15);
    final fg = _ok ? (context.isDark ? AppColors.lightGreen : AppColors.greenDark) : (context.isDark ? AppColors.lightRed : AppColors.redDark);
    final showAnswer = !_ok &&
        _ex.type != ExerciseType.trueFalse &&
        _ex.type != ExerciseType.numberLine &&
        _ex.type != ExerciseType.grid;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      color: bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_ok ? 'Bravo, c\'est juste ! 🎉' : 'Pas tout à fait… 🤔',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: fg)),
          if (!_ok) ...[
            const SizedBox(height: 6),
            if (showAnswer)
              MathText('Bonne réponse : ${_ex.answer}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: fg)),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 140),
              child: SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const MascotImage(size: 40),
                    const SizedBox(width: 8),
                    Expanded(
                      child: MathText(_ex.explanation,
                          style: AppText.body.copyWith(fontSize: 14, color: fg)),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          ChunkyButton(
            label: _number >= total ? 'Voir mon score' : 'Continuer',
            color: _ok ? AppColors.green : AppColors.red,
            onPressed: _continue,
          ),
        ],
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  final String label;
  final bool selected;
  final bool correct;
  final bool wrong;
  final VoidCallback? onTap;

  const _ChoiceTile({
    required this.label,
    required this.selected,
    required this.correct,
    required this.wrong,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    final border = correct
        ? AppColors.green
        : wrong
            ? AppColors.red
            : (selected ? primary : context.colors.outline);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        constraints: const BoxConstraints(minWidth: 140, minHeight: 72),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? primary.withValues(alpha: 0.12) : context.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 2.5),
          boxShadow: [BoxShadow(color: border.withValues(alpha: 0.6), offset: const Offset(0, 4))],
        ),
        child: Center(
          widthFactor: 1,
          child: MathText(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}

/// Pavé numérique (avec le signe moins pour le collège et le lycée).
class _Keypad extends StatelessWidget {
  final bool enabled;
  final ValueChanged<String> onKey;

  const _Keypad({required this.enabled, required this.onKey});

  @override
  Widget build(BuildContext context) {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '±', '0', '⌫'];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.3,
      children: [
        for (final k in keys)
          Material(
            color: context.colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: enabled ? () => onKey(k) : null,
              child: Center(
                child: Text(k == '±' ? '+/−' : k,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
      ],
    );
  }
}
