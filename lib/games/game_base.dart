import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../curriculum/curriculum.dart';
import '../logic/exercise_generator.dart';
import '../logic/progress_store.dart';
import '../logic/sound.dart';
import '../models/exercise.dart';
import '../models/game_type.dart';
import '../models/skill.dart';
import '../screens/result_screen.dart';
import '../theme.dart';
import '../widgets/math_text.dart';
import 'game_launcher.dart';

/// Écran de mini-jeu : reçoit la compétence travaillée.
abstract class GameScreen extends StatefulWidget {
  final Skill skill;

  const GameScreen({super.key, required this.skill});
}

/// Logique commune à tous les mini-jeux :
/// questions adaptatives, pièces, cœurs, combo, pause avec explication,
/// fin de partie et écran de résultats.
abstract class GameState<T extends GameScreen> extends State<T>
    with SingleTickerProviderStateMixin {
  // --- À personnaliser dans chaque jeu ---
  GameType get gameType;
  int get numChoices => 4;
  int get goal => 8;
  bool get usesHearts => true;
  bool get isWon => correct >= goal;
  bool get isLost => usesHearts && hearts <= 0;
  double get progress => (correct / goal).clamp(0.0, 1.0);

  /// Appelé à chaque image (dt en secondes), sauf en pause.
  void onTick(double dt) {}
  void onNewQuestion() {}
  void onCorrect(String choice) {}
  void onWrong(String? choice) {}

  // --- État commun ---
  final rng = Random();
  late final ExerciseGenerator generator = ExerciseGenerator(rng);
  final store = ProgressStore.instance;
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  final DateTime _start = DateTime.now();
  late final int _xpStart;

  double gameTime = 0;
  bool paused = false;
  bool finished = false;

  /// Bloque les entrées pendant une courte animation entre deux questions.
  bool busy = false;

  late Exercise current;
  int hearts = 3;
  int correct = 0;
  int answered = 0;
  int rightAnswers = 0;
  int combo = 0;
  int coinsEarned = 0;

  /// Exercice raté affiché dans la fenêtre d'explication.
  Exercise? mistake;

  /// Moment où la question en cours est apparue (temps de réponse).
  DateTime _askedAt = DateTime.now();

  Skill get skill => widget.skill;
  bool get acceptsInput => !paused && !finished && !busy;

  @override
  void initState() {
    super.initState();
    _xpStart = store.xp;
    store.registerPlay(skill.id);
    current = _makeQuestion();
    onNewQuestion();
    _ticker = createTicker(_onTick)..start();
    Sfx.startMusic();
  }

  @override
  void dispose() {
    _ticker.dispose();
    Sfx.stopMusic();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    if (paused || finished || !mounted) return;
    gameTime += dt;
    onTick(dt.clamp(0.0, 0.1));
    setState(() {});
  }

  Exercise _makeQuestion() {
    final skillId =
        skill.isBoss ? store.pickBossSkill(rng, review: skill.isReview) : skill.id;
    return generator.generateChoices(
        skillId, store.levelFor(skillId), numChoices);
  }

  void nextQuestion() {
    if (finished || !mounted) return;
    setState(() {
      busy = false;
      current = _makeQuestion();
      _askedAt = DateTime.now();
      onNewQuestion();
    });
  }

  /// L'enfant choisit une réponse. [choice] = null si la bonne réponse
  /// lui a échappé (ballon envolé, fruit raté...).
  void submit(String? choice) {
    if (!acceptsInput) return;
    final ok = choice != null && current.check(choice);
    final levelUp = store.recordAnswer(current, ok,
        seconds: DateTime.now().difference(_askedAt).inMilliseconds / 1000);
    answered++;

    if (ok) {
      correct++;
      rightAnswers++;
      combo++;
      final gain = 5 + (combo >= 3 ? 3 : 0);
      coinsEarned += gain;
      store.addCoins(gain);
      HapticFeedback.lightImpact();
      Sfx.play(combo >= 3 ? Sound.coin : Sound.correct);
      onCorrect(choice);
      busy = true;
      Future.delayed(const Duration(milliseconds: 550), () {
        if (!mounted) return;
        if (isWon) {
          _finish(true);
        } else {
          nextQuestion();
        }
      });
    } else {
      combo = 0;
      if (usesHearts) hearts--;
      HapticFeedback.heavyImpact();
      Sfx.play(Sound.wrong);
      onWrong(choice);
      mistake = current;
      paused = true; // on affiche l'explication
    }

    if (levelUp != null) {
      Sfx.play(Sound.levelup);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.blue,
          duration: const Duration(seconds: 2),
          content: Text(
            '🚀 Niveau $levelUp débloqué en ${Skills.byId(current.skillId).title} !',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ),
      );
    }
    setState(() {});
  }

  /// Perte de cœur sans question (ex : attaque du monstre).
  void loseHeart() {
    if (finished) return;
    hearts--;
    combo = 0;
    HapticFeedback.heavyImpact();
    Sfx.play(Sound.monster);
    if (isLost) _finish(false);
  }

  void _closeMistake() {
    setState(() {
      mistake = null;
      paused = false;
    });
    if (isLost) {
      _finish(false);
    } else {
      nextQuestion();
    }
  }

  /// À appeler par le jeu quand une condition de défaite propre au jeu
  /// est atteinte (ex : le rival franchit la ligne d'arrivée).
  void lose() => _finish(false);

  Future<void> _finish(bool success) async {
    if (finished) return;
    finished = true;
    await Sfx.stopMusic();
    Sfx.play(success ? Sound.win : Sound.lose);
    final seconds = DateTime.now().difference(_start).inSeconds;
    if (success) {
      const bonus = 15;
      coinsEarned += bonus;
      store.addCoins(bonus);
      await store.completeLesson(skill.id, rightAnswers, answered, seconds);
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          success: success,
          coinsEarned: coinsEarned,
          xpEarned: store.xp - _xpStart,
          accuracy: answered == 0 ? 0 : rightAnswers / answered,
          seconds: seconds,
          skill: skill,
          retry: () => gameScreenFor(skill, store.nextGameFor(skill)),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // Interface commune
  // ------------------------------------------------------------------

  /// Fond de l'écran propre à chaque jeu.
  Color get backgroundColor => Colors.white;

  /// Contenu du jeu (sous la barre du haut).
  Widget buildGame(BuildContext context);

  @override
  Widget build(BuildContext context) {
    // Les mini-jeux gardent leurs couleurs vives, même en mode sombre.
    return Theme(
      data: buildTheme(Curriculum.currentSchool.id, Brightness.light),
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _hud(),
                Expanded(child: buildGame(context)),
              ],
            ),
            if (mistake != null) _mistakeOverlay(mistake!),
          ],
        ),
      ),
    );
  }

  Widget _hud() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 14, 6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, size: 28, color: AppColors.greyDark),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 14,
                color: AppColors.green,
                backgroundColor: Colors.black12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          if (combo >= 2)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text('🔥x$combo',
                  style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.orange,
                      fontSize: 16)),
            ),
          GestureDetector(
            onTap: () async {
              final on = !(store.soundOn || store.musicOn);
              await store.setSound(on);
              await store.setMusic(on);
              if (on) Sfx.startMusic();
              setState(() {});
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                store.soundOn || store.musicOn
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
                color: AppColors.greyDark,
              ),
            ),
          ),
          if (usesHearts)
            Text('❤️$hearts',
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.red,
                    fontSize: 16)),
          const SizedBox(width: 8),
          Text('🪙$coinsEarned',
              style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFB8860B),
                  fontSize: 16)),
        ],
      ),
    );
  }

  /// Bandeau de question réutilisable.
  Widget questionBanner({Color color = Colors.white}) {
    final long = current.prompt.length > 30;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 6)
        ],
      ),
      child: MathText(
        current.prompt,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: long ? 18 : 34,
          fontWeight: FontWeight.w900,
          color: AppColors.text,
        ),
      ),
    );
  }

  /// « 7 + 5 = ? » sur une seule ligne : on peut afficher « 7 + 5 = 12 ».
  bool _isEquation(Exercise ex) =>
      ex.prompt.endsWith('= ?') && !ex.prompt.contains('\n');

  Widget _mistakeOverlay(Exercise ex) {
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Oups ! 🙈',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.red)),
              const SizedBox(height: 10),
              MathText(
                _isEquation(ex) ? ex.prompt.replaceFirst('?', ex.answer) : ex.prompt,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Brand.ink),
              ),
              if (!_isEquation(ex)) ...[
                const SizedBox(height: 6),
                MathText('Réponse : ${ex.answer}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.greenDark)),
              ],
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E0),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(AppInfo.mascotImage, width: 40, height: 40),
                    const SizedBox(width: 8),
                    Expanded(
                      child: MathText(
                        ex.explanation,
                        style: AppText.body.copyWith(fontSize: 15, color: Brand.ink),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _closeMistake,
                child: Text(isLost ? 'Voir mon score' : 'J\'ai compris !',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
