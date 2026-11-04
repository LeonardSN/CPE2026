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

  final Map<String, double> ratings = {};
  final Map<String, int> attempts = {};
  final Map<String, int> successes = {};
  final Map<String, int> completions = {};
  final List<LessonRecord> history = [];
  final Map<String, int> plays = {};

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

  /// Pour le Boss : on cible en priorité la compétence la plus faible.
  String pickBossSkill(Random rng) {
    if (rng.nextDouble() < 0.5) {
      final sorted = [...Skills.tracked]
        ..sort((a, b) => masteryOf(a.id).compareTo(masteryOf(b.id)));
      return sorted.first.id;
    }
    return Skills.tracked[rng.nextInt(Skills.tracked.length)].id;
  }

  /// Enregistre une réponse. Renvoie le nouveau niveau si l'enfant
  /// vient de monter de niveau dans cette compétence (sinon null).
  int? recordAnswer(Exercise ex, bool correct) {
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
  // Cycle d'études (primaire, collège, lycée)
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
    ratings.clear();
    attempts.clear();
    successes.clear();
    completions.clear();
    history.clear();
    await _save();
    notifyListeners();
  }
}
