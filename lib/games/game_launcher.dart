import 'package:flutter/material.dart';

import '../models/game_type.dart';
import '../models/skill.dart';
import 'balloons_game.dart';
import 'duel_game.dart';
import 'fruits_game.dart';
import 'race_game.dart';

Widget gameScreenFor(Skill skill, GameType type) => switch (type) {
      GameType.balloons => BalloonsGame(skill: skill),
      GameType.fruits => FruitsGame(skill: skill),
      GameType.race => RaceGame(skill: skill),
      GameType.duel => DuelGame(skill: skill),
    };
