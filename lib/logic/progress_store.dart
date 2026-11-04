import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../curriculum/curriculum.dart';
import '../models/exercise.dart';
import '../models/game_type.dart';
import '../models/skill.dart';
import '../models/village.dart';
import 'adaptive_engine.dart';
import 'sound.dart';

/// Résumé d'une leçon terminée (affiché dans le tableau de bord parent).
class LessonRecord {
  final String skillId;
  final DateTime date;
  final int correct;
  final int total;
  final int seconds;

  LessonRecord(this.skillId, this.date, this.correct, this.total, this.seconds);

  Map<String, dynamic> toJson() => {
        's': skillId,
        'd': date.toIso8601String(),
        'c': correct,
        't': total,
        'sec': seconds,
      };

  factory LessonRecord.fromJson(Map<String, dynamic> j) => LessonRecord(
        j['s'] as String,
        DateTime.parse(j['d'] as String),
        j['c'] as int,
        j['t'] as int,
        j['sec'] as int,
      );
}

/// Toute la progression de l'enfant, sauvegardée localement sur le téléphone.
class ProgressStore extends ChangeNotifier {
  ProgressStore._();
  static final ProgressStore instance = ProgressStore._();

  late SharedPreferences _prefs;

  String childName = '';
  int xp = 0;
  int streak = 0;
  String lastActiveDay = '';
  int totalSeconds = 0;
  bool unlockAll = false;
  int coins = 30; // cadeau de bienvenue pour construire tout de suite
  String cycleId = '';
  bool soundOn = true;
  bool musicOn = true;

  /// 'system', 'light' ou 'dark'.
  String themeMode = 'system';

  /// Abonnement Premium (version démo : aucun paiement réel).
  bool isPremium = false;
  int adCounter = 0;

  final Map<String, double> ratings = {};
  final Map<String, int> attempts = {};
  final Map<String, int> successes = {};
  final Map<String, int> completions = {};
  final List<LessonRecord> history = [];
  final Map<String, int> plays = {};

  /// Personnalisation : dernière pratique (ms) et temps de réponse par chapitre.
  final Map<String, int> lastPracticed = {};
  final Map<String, double> timeSum = {};
  final Map<String, int> timeCount = {};

  /// Cases du village : index de la case -> id de l'élément construit.
  final Map<int, String> village = {};

  // ------------------------------------------------------------------
  // Chargement / sauvegarde
  // ------------------------------------------------------------------
  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    childName = _prefs.getString('childName') ?? '';
    xp = _prefs.getInt('xp') ?? 0;
    streak = _prefs.getInt('streak') ?? 0;
    lastActiveDay = _prefs.getString('lastActiveDay') ?? '';
    totalSeconds = _prefs.getInt('totalSeconds') ?? 0;
    unlockAll = _prefs.getBool('unlockAll') ?? false;
    coins = _prefs.getInt('coins') ?? 30;
    cycleId = _prefs.getString('cycleId') ?? '';
    soundOn = _prefs.getBool('soundOn') ?? true;
    musicOn = _prefs.getBool('musicOn') ?? true;
    themeMode = _prefs.getString('themeMode') ?? 'system';
    isPremium = _prefs.getBool('isPremium') ?? false;
    adCounter = _prefs.getInt('adCounter') ?? 0;
    _readMap('lastPracticed', lastPracticed, (v) => v as int);
    _readMap('timeSum', timeSum, (v) => (v as num).toDouble());
    _readMap('timeCount', timeCount, (v) => v as int);
    Sfx.soundOn = soundOn;
    Sfx.musicOn = musicOn;
    Curriculum.current = Curriculum.byId(cycleId);
    _readMap('plays', plays, (v) => v as int);
    village.clear();
    (jsonDecode(_prefs.getString('village') ?? '{}') as Map<String, dynamic>)
        .forEach((k, v) => village[int.parse(k)] = v as String);
    _readMap('ratings', ratings, (v) => (v as num).toDouble());
    _readMap('attempts', attempts, (v) => v as int);
    _readMap('successes', successes, (v) => v as int);
    _readMap('completions', completions, (v) => v as int);
    history
      ..clear()
      ..addAll((jsonDecode(_prefs.getString('history') ?? '[]') as List)
          .map((e) => LessonRecord.fromJson(e as Map<String, dynamic>)));
    notifyListeners();
  }

  void _readMap<T>(String key, Map<String, T> target, T Function(dynamic) f) {
    target.clear();
    final raw = _prefs.getString(key);
    if (raw == null) return;
    (jsonDecode(raw) as Map<String, dynamic>)
        .forEach((k, v) => target[k] = f(v));
  }

  Future<void> _save() async {
    await _prefs.setString('childName', childName);
    await _prefs.setInt('xp', xp);
    await _prefs.setInt('streak', streak);
    await _prefs.setString('lastActiveDay', lastActiveDay);
    await _prefs.setInt('totalSeconds', totalSeconds);
    await _prefs.setBool('unlockAll', unlockAll);
    await _prefs.setInt('coins', coins);
    await _prefs.setString('cycleId', cycleId);
    await _prefs.setBool('soundOn', soundOn);
    await _prefs.setBool('musicOn', musicOn);
    await _prefs.setString('themeMode', themeMode);
    await _prefs.setBool('isPremium', isPremium);
    await _prefs.setInt('adCounter', adCounter);
    await _prefs.setString('lastPracticed', jsonEncode(lastPracticed));
    await _prefs.setString('timeSum', jsonEncode(timeSum));
    await _prefs.setString('timeCount', jsonEncode(timeCount));
    await _prefs.setString('plays', jsonEncode(plays));
    await _prefs.setString(
        'village', jsonEncode(village.map((k, v) => MapEntry('$k', v))));
    await _prefs.setString('ratings', jsonEncode(ratings));
    await _prefs.setString('attempts', jsonEncode(attempts));
    await _prefs.setString('successes', jsonEncode(successes));
    await _prefs.setString('completions', jsonEncode(completions));
    await _prefs.setString(
        'history', jsonEncode(history.map((e) => e.toJson()).toList()));
  }

  // ------------------------------------------------------------------
  // Profil
  // ------------------------------------------------------------------
  Future<void> setChildName(String name) async {
    childName = name.trim();
    await _save();
    notifyListeners();
  }

  // ------------------------------------------------------------------
  // Moteur adaptatif
  // ------------------------------------------------------------------
  double ratingOf(String skillId) =>
      ratings[skillId] ?? AdaptiveEngine.initialRating;

  int levelFor(String skillId) => AdaptiveEngine.chooseLevel(ratingOf(skillId));

  double masteryOf(String skillId) =>
      AdaptiveEngine.mastery(ratingOf(skillId));

  /// Chapitres jouables en mini-jeu dans la classe en cours.
  List<Skill> get _mixable =>
      Skills.tracked.where((s) => !s.exerciseOnly).toList();

  /// Pour le Boss (et la Révision) : on cible en priorité les points faibles.
  String pickBossSkill(Random rng, {bool review = false}) {
    final pool = _mixable;
    if (pool.isEmpty) return Skills.tracked.first.id;
    final weakShare = review ? 0.8 : 0.5;
    if (rng.nextDouble() < weakShare) {
      final sorted = [...pool]
        ..sort((a, b) => needScore(b.id).compareTo(needScore(a.id)));
      // un peu de hasard parmi les 2 plus prioritaires
      return sorted[rng.nextInt(min(2, sorted.length))].id;
    }
    return pool[rng.nextInt(pool.length)].id;
  }

  // ------------------------------------------------------------------
  // Personnalisation : rythme, lacunes, oubli
  // ------------------------------------------------------------------

  /// Jours écoulés depuis la dernière pratique d'un chapitre.
  double daysSince(String skillId) {
    final t = lastPracticed[skillId];
    if (t == null) return 999;
    return DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(t)).inHours / 24;
  }

  /// Besoin de travailler un chapitre (0 = rien à faire, ~1.5 = urgent) :
  /// lacunes (maîtrise faible) + oubli (pas revu depuis longtemps).
  double needScore(String skillId) {
    if ((attempts[skillId] ?? 0) == 0) return 0.4;
    final gap = 1 - masteryOf(skillId);
    final forgetting = (daysSince(skillId) / 7).clamp(0.0, 1.0) * 0.5;
    return gap + forgetting;
  }

  /// Temps moyen de réponse (secondes) pour un chapitre, ou global.
  double? avgSeconds([String? skillId]) {
    if (skillId != null) {
      final n = timeCount[skillId] ?? 0;
      return n == 0 ? null : timeSum[skillId]! / n;
    }
    final n = timeCount.values.fold(0, (a, b) => a + b);
    if (n == 0) return null;
    return timeSum.values.fold(0.0, (a, b) => a + b) / n;
  }

  /// Le chapitre conseillé maintenant, avec la raison.
  (Skill, String)? get recommendation {
    final chapters = Skills.all;
    (Skill, String)? best;
    var bestScore = -1.0;
    for (var i = 0; i < chapters.length; i++) {
      final ch = chapters[i];
      if (ch.isBoss || !isUnlocked(i)) continue;
      final tried = (attempts[ch.id] ?? 0) > 0;
      double score;
      String reason;
      if (!tried) {
        score = 0.55 - i * 0.01;
        reason = 'Nouveau chapitre à découvrir';
      } else {
        score = needScore(ch.id);
        final days = daysSince(ch.id);
        if (masteryOf(ch.id) < 0.45) {
          reason = 'Tu peux encore progresser ici';
        } else if (days >= 3) {
          reason = 'Pas revu depuis ${days.floor()} jours';
        } else {
          reason = 'Pour consolider';
        }
      }
      if (score > bestScore) {
        bestScore = score;
        best = (ch, reason);
      }
    }
    return best;
  }

  /// Parties jouées ces 7 derniers jours.
  int get sessionsThisWeek {
    final limit = DateTime.now().subtract(const Duration(days: 7));
    return history.where((h) => h.date.isAfter(limit)).length;
  }

  /// Enregistre une réponse. Renvoie le nouveau niveau si l'enfant
  /// vient de monter de niveau dans cette compétence (sinon null).
  int? recordAnswer(Exercise ex, bool correct, {double? seconds}) {
    lastPracticed[ex.skillId] = DateTime.now().millisecondsSinceEpoch;
    if (seconds != null && seconds > 0 && seconds < 120) {
      timeSum[ex.skillId] = (timeSum[ex.skillId] ?? 0) + seconds;
      timeCount[ex.skillId] = (timeCount[ex.skillId] ?? 0) + 1;
    }
    final before = levelFor(ex.skillId);
    ratings[ex.skillId] =
        AdaptiveEngine.update(ratingOf(ex.skillId), ex.level, correct);
    attempts[ex.skillId] = (attempts[ex.skillId] ?? 0) + 1;
    if (correct) {
      successes[ex.skillId] = (successes[ex.skillId] ?? 0) + 1;
      xp += 10;
    }
    final after = levelFor(ex.skillId);
    _save();
    notifyListeners();
    return after > before ? after : null;
  }

  Future<void> completeLesson(
      String skillId, int correct, int total, int seconds) async {
    completions[skillId] = (completions[skillId] ?? 0) + 1;
    xp += 20; // bonus de fin de leçon
    totalSeconds += seconds;
    history.insert(0, LessonRecord(skillId, DateTime.now(), correct, total, seconds));
    if (history.length > 30) history.removeLast();
    _updateStreak();
    await _save();
    notifyListeners();
  }

  void _updateStreak() {
    String fmt(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final now = DateTime.now();
    final today = fmt(now);
    final yesterday = fmt(now.subtract(const Duration(days: 1)));
    if (lastActiveDay == today) return;
    streak = lastActiveDay == yesterday ? streak + 1 : 1;
    lastActiveDay = today;
  }

  // ------------------------------------------------------------------
  // Thème et abonnement
  // ------------------------------------------------------------------
  Future<void> setThemeMode(String mode) async {
    themeMode = mode;
    await _save();
    notifyListeners();
  }

  Future<void> setPremium(bool v) async {
    isPremium = v;
    await _save();
    notifyListeners();
  }

  /// La pub « Premium » s'affiche une partie sur trois (version gratuite).
  bool shouldShowAd() {
    if (isPremium) return false;
    adCounter++;
    _save();
    return adCounter % 3 == 0;
  }

  // ------------------------------------------------------------------
  // Sons
  // ------------------------------------------------------------------
  Future<void> setSound(bool v) async {
    soundOn = v;
    Sfx.soundOn = v;
    await _save();
    notifyListeners();
  }

  Future<void> setMusic(bool v) async {
    musicOn = v;
    Sfx.musicOn = v;
    if (!v) await Sfx.stopMusic();
    await _save();
    notifyListeners();
  }

  // ------------------------------------------------------------------
  // Classe choisie (PS ... Terminale)
  // ------------------------------------------------------------------
  Future<void> setCycle(String id) async {
    cycleId = id;
    Curriculum.current = Curriculum.byId(id);
    await _save();
    notifyListeners();
  }

  // ------------------------------------------------------------------
  // Pièces, mini-jeux et village
  // ------------------------------------------------------------------
  void addCoins(int amount) {
    coins += amount;
    _save();
    notifyListeners();
  }

  /// Le jeu proposé pour une leçon change à chaque partie.
  GameType nextGameFor(Skill skill) {
    if (skill.isBoss) return GameType.duel;
    final index = Skills.all.indexOf(skill);
    final n = plays[skill.id] ?? 0;
    return GameType.rotation[(n + index) % GameType.rotation.length];
  }

  void registerPlay(String skillId) {
    plays[skillId] = (plays[skillId] ?? 0) + 1;
    _save();
  }

  bool buildItem(int tile, VillageItem item) {
    if (coins < item.price || village.containsKey(tile)) return false;
    coins -= item.price;
    village[tile] = item.id;
    Sfx.play(Sound.build);
    _save();
    notifyListeners();
    return true;
  }

  void sell(int tile) {
    final item = Village.byId(village[tile] ?? '');
    if (item == null) return;
    Sfx.play(Sound.coin);
    coins += item.price ~/ 2;
    village.remove(tile);
    _save();
    notifyListeners();
  }

  // ------------------------------------------------------------------
  // Carte des leçons
  // ------------------------------------------------------------------
  bool isUnlocked(int index) {
    if (index == 0 || unlockAll) return true;
    return (completions[Skills.all[index - 1].id] ?? 0) > 0;
  }

  bool isCompleted(String skillId) => (completions[skillId] ?? 0) > 0;

  // ------------------------------------------------------------------
  // Statistiques pour les parents
  // ------------------------------------------------------------------
  int get lessonsCompleted => completions.values.fold(0, (a, b) => a + b);

  double get globalAccuracy {
    final a = attempts.values.fold(0, (x, y) => x + y);
    final s = successes.values.fold(0, (x, y) => x + y);
    return a == 0 ? 0 : s / a;
  }

  double accuracyOf(String skillId) {
    final a = attempts[skillId] ?? 0;
    return a == 0 ? 0 : (successes[skillId] ?? 0) / a;
  }

  /// Compétence la plus faible parmi celles déjà travaillées.
  Skill? get weakestSkill {
    final worked =
        Skills.tracked.where((s) => (attempts[s.id] ?? 0) >= 3).toList();
    if (worked.isEmpty) return null;
    worked.sort((a, b) => masteryOf(a.id).compareTo(masteryOf(b.id)));
    return worked.first;
  }

  Skill? get strongestSkill {
    final worked =
        Skills.tracked.where((s) => (attempts[s.id] ?? 0) >= 3).toList();
    if (worked.length < 2) return null;
    worked.sort((a, b) => masteryOf(b.id).compareTo(masteryOf(a.id)));
    return worked.first;
  }

  // ------------------------------------------------------------------
  // Outils de démo
  // ------------------------------------------------------------------
  Future<void> setUnlockAll(bool v) async {
    unlockAll = v;
    await _save();
    notifyListeners();
  }

  Future<void> resetAll() async {
    xp = 0;
    streak = 0;
    lastActiveDay = '';
    totalSeconds = 0;
    unlockAll = false;
    coins = 30;
    plays.clear();
    village.clear();
    lastPracticed.clear();
    timeSum.clear();
    timeCount.clear();
    adCounter = 0;
    ratings.clear();
    attempts.clear();
    successes.clear();
    completions.clear();
    history.clear();
    await _save();
    notifyListeners();
  }
}
