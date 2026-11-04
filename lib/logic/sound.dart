import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Effets sonores et musique de l'app.
/// Les sons sont dans assets/sounds/ (générés par programme : libres de droits).
///
/// Utilisation : Sfx.play(Sound.correct);
enum Sound {
  tap,
  correct,
  wrong,
  pop,
  coin,
  catchFruit('catch'),
  hit,
  monster,
  beep,
  go,
  levelup,
  win,
  lose,
  build;

  final String? _file;
  const Sound([this._file]);
  String get file => 'sounds/${_file ?? name}.wav';
}

class Sfx {
  static bool soundOn = true;
  static bool musicOn = true;

  static final Map<Sound, AudioPlayer> _players = {};
  static AudioPlayer? _music;

  static Future<void> play(Sound s, {double volume = 1}) async {
    if (!soundOn) return;
    try {
      final p = _players.putIfAbsent(s, () {
        final player = AudioPlayer();
        player.setReleaseMode(ReleaseMode.stop);
        return player;
      });
      await p.stop();
      await p.setVolume(volume);
      await p.play(AssetSource(s.file));
    } catch (e) {
      // Le son ne doit jamais faire planter le jeu.
      debugPrint('Son impossible ($s) : $e');
    }
  }

  /// Musique d'ambiance en boucle pendant les mini-jeux.
  static Future<void> startMusic() async {
    if (!musicOn) return;
    try {
      _music ??= AudioPlayer();
      await _music!.setReleaseMode(ReleaseMode.loop);
      await _music!.setVolume(0.35);
      await _music!.play(AssetSource('sounds/music.mp3'));
    } catch (e) {
      debugPrint('Musique impossible : $e');
    }
  }

  static Future<void> stopMusic() async {
    try {
      await _music?.stop();
    } catch (_) {}
  }
}
