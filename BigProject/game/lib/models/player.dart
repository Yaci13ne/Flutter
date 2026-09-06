import 'package:flutter/material.dart';
import 'grid_position.dart';
import '../utils/app_theme.dart';

enum PlayerType { human, aiEasy, aiMedium, aiHard }

class Player {
  final int id; // 1 or 2
  GridPosition position;
  int wallsRemaining;
  int undosRemaining;
  int trappedTurns; // turns to skip due to trap tile
  bool hasBooster; // can move twice this turn
  final PlayerType type;

  Player({
    required this.id,
    required this.position,
    this.wallsRemaining = 10,
    this.undosRemaining = 3,
    this.trappedTurns = 0,
    this.hasBooster = false,
    this.type = PlayerType.human,
  });

  Color get color =>
      id == 1 ? AppTheme.player1Color : AppTheme.player2Color;

  Color get neonColor =>
      id == 1 ? AppTheme.neonBlue : AppTheme.neonPink;

  String get name => id == 1 ? 'Player 1' : 'Player 2';

  String get tokenEmoji => id == 1 ? '●' : '●';

  bool get isHuman => type == PlayerType.human;
  bool get isAI => type != PlayerType.human;

  Player copyWith({
    GridPosition? position,
    int? wallsRemaining,
    int? undosRemaining,
    int? trappedTurns,
    bool? hasBooster,
  }) {
    return Player(
      id: id,
      position: position ?? this.position,
      wallsRemaining: wallsRemaining ?? this.wallsRemaining,
      undosRemaining: undosRemaining ?? this.undosRemaining,
      trappedTurns: trappedTurns ?? this.trappedTurns,
      hasBooster: hasBooster ?? this.hasBooster,
      type: type,
    );
  }
}
