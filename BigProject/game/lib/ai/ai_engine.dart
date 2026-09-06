import 'dart:math';
import 'dart:collection';
import '../models/game_board.dart';
import '../models/grid_position.dart';
import '../models/wall.dart';
import '../models/player.dart';

class AIEngine {
  final Random _rng = Random();

  /// Get AI action for the given board state
  Future<AIAction> getAction(GameBoard board, Player aiPlayer) async {
    // Simulate thinking delay
    final delay = aiPlayer.type == PlayerType.aiHard ? 800 : 400;
    await Future.delayed(Duration(milliseconds: delay));

    switch (aiPlayer.type) {
      case PlayerType.aiEasy:
        return _easyAction(board, aiPlayer);
      case PlayerType.aiMedium:
        return _mediumAction(board, aiPlayer);
      case PlayerType.aiHard:
        return _hardAction(board, aiPlayer);
      default:
        return _easyAction(board, aiPlayer);
    }
  }

  /// Easy AI: random moves with occasional wall
  AIAction _easyAction(GameBoard board, Player aiPlayer) {
    final moves = board.getReachablePositions(aiPlayer);

    // 80% chance to move
    if (moves.isNotEmpty && (_rng.nextDouble() < 0.8 || aiPlayer.wallsRemaining == 0)) {
      return AIAction.move(moves[_rng.nextInt(moves.length)]);
    }

    // Try random wall
    if (aiPlayer.wallsRemaining > 0) {
      final wall = _randomValidWall(board);
      if (wall != null) return AIAction.wall(wall);
    }

    if (moves.isNotEmpty) return AIAction.move(moves[_rng.nextInt(moves.length)]);
    return AIAction.skip();
  }

  /// Medium AI: move toward goal, occasionally block opponent
  AIAction _mediumAction(GameBoard board, Player aiPlayer) {
    final opponent = aiPlayer.id == 1 ? board.player2 : board.player1;
    final moves = board.getReachablePositions(aiPlayer);

    if (moves.isEmpty) return AIAction.skip();

    final goalRow = board.isGoalRow(0, aiPlayer.id) ? 0 : board.size - 1;

    // Check for winning move
    for (final m in moves) {
      if (board.isGoalRow(m.row, aiPlayer.id)) return AIAction.move(m);
    }

    // 30% chance to place a blocking wall
    if (aiPlayer.wallsRemaining > 0 && _rng.nextDouble() < 0.3) {
      final wall = _blockingWall(board, opponent);
      if (wall != null) return AIAction.wall(wall);
    }

    // Move toward goal row
    GridPosition? best;
    int bestDist = 999;
    for (final m in moves) {
      final dist = (m.row - goalRow).abs();
      if (dist < bestDist) {
        bestDist = dist;
        best = m;
      }
    }
    return AIAction.move(best ?? moves[_rng.nextInt(moves.length)]);
  }

  /// Hard AI: minimax-inspired, strategic wall placement
  AIAction _hardAction(GameBoard board, Player aiPlayer) {
    final moves = board.getReachablePositions(aiPlayer);

    // Check winning move first
    for (final m in moves) {
      if (board.isGoalRow(m.row, aiPlayer.id)) return AIAction.move(m);
    }

    // Evaluate: should we move or place wall?
    final myDist = board.distanceToGoal(aiPlayer.id);
    final oppId = aiPlayer.id == 1 ? 2 : 1;
    final oppDist = board.distanceToGoal(oppId);

    // If opponent is close, try to block
    if (oppDist <= 2 && aiPlayer.wallsRemaining > 0) {
      final opponent = aiPlayer.id == 1 ? board.player2 : board.player1;
      final wall = _bestBlockingWall(board, opponent, aiPlayer);
      if (wall != null) return AIAction.wall(wall);
    }

    // Move using best position (minimize BFS distance)
    if (moves.isEmpty) return AIAction.skip();

    GridPosition? best;
    int bestDist = 999;
    for (final m in moves) {
      // Temporarily move and measure BFS distance
      final orig = aiPlayer.position;
      aiPlayer.position = m;
      final d = board.distanceToGoal(aiPlayer.id);
      aiPlayer.position = orig;

      if (d < bestDist) {
        bestDist = d;
        best = m;
      }
    }

    // If current position is already optimal, consider strategic wall
    if (myDist - bestDist < 1 && aiPlayer.wallsRemaining > 0 && _rng.nextDouble() < 0.4) {
      final opponent = aiPlayer.id == 1 ? board.player2 : board.player1;
      final wall = _bestBlockingWall(board, opponent, aiPlayer);
      if (wall != null) return AIAction.wall(wall);
    }

    return AIAction.move(best ?? moves[0]);
  }

  Wall? _randomValidWall(GameBoard board) {
    for (int attempt = 0; attempt < 30; attempt++) {
      final r = _rng.nextInt(board.size - 1);
      final c = _rng.nextInt(board.size);
      final isH = _rng.nextBool();
      Wall wall;
      if (isH) {
        if (c >= board.size - 1) continue;
        wall = Wall.canonical(GridPosition(r, c), GridPosition(r, c + 1));
      } else {
        wall = Wall.canonical(GridPosition(r, c), GridPosition(r + 1, c));
      }
      if (board.isValidWallPlacement(wall)) return wall;
    }
    return null;
  }

  Wall? _blockingWall(GameBoard board, Player opponent) {
    // Find walls that slow down the opponent most
    final oppMoves = board.getReachablePositions(opponent);
    if (oppMoves.isEmpty) return null;

    for (final move in oppMoves) {
      final w = Wall.canonical(opponent.position, move);
      if (board.isValidWallPlacement(w)) return w;
    }
    return null;
  }

  Wall? _bestBlockingWall(GameBoard board, Player opponent, Player ai) {
    Wall? bestWall;
    int bestScore = -999;

    // Try walls near opponent's path
    final oppPos = opponent.position;
    for (int dr = -2; dr <= 2; dr++) {
      for (int dc = -2; dc <= 2; dc++) {
        final pos = GridPosition(oppPos.row + dr, oppPos.col + dc);
        if (!board.isInBounds(pos)) continue;

        // Try vertical and horizontal walls
        for (final next in [
          GridPosition(pos.row + 1, pos.col),
          GridPosition(pos.row, pos.col + 1),
        ]) {
          if (!board.isInBounds(next)) continue;
          final wall = Wall.canonical(pos, next);
          if (!board.isValidWallPlacement(wall)) continue;

          board.walls.add(wall);
          final oppDistAfter = board.distanceToGoal(opponent.id);
          final myDistAfter = board.distanceToGoal(ai.id);
          board.walls.remove(wall);

          final score = oppDistAfter - myDistAfter;
          if (score > bestScore) {
            bestScore = score;
            bestWall = wall;
          }
        }
      }
    }
    return bestWall;
  }
}

class AIAction {
  final AIActionType type;
  final GridPosition? moveTarget;
  final Wall? wall;

  AIAction._({required this.type, this.moveTarget, this.wall});

  factory AIAction.move(GridPosition target) =>
      AIAction._(type: AIActionType.move, moveTarget: target);

  factory AIAction.wall(Wall w) =>
      AIAction._(type: AIActionType.placeWall, wall: w);

  factory AIAction.skip() =>
      AIAction._(type: AIActionType.skip);
}

enum AIActionType { move, placeWall, skip }
