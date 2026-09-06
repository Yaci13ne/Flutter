import 'dart:math';
import 'dart:collection';
import 'grid_position.dart';
import 'wall.dart';
import 'player.dart';
import 'special_tile.dart';
import '../utils/app_theme.dart';

enum GameMode { twoPlayer, vsAI }
enum GridSize { small, large } // 8x8 or 10x10
enum TurnPhase { selectAction, move, placeWall, boosterSecondMove }

class GameBoard {
  final int size;
  final List<List<int>> colorGrid; // color indices
  final Set<Wall> walls;
  final Map<GridPosition, SpecialTile> specialTiles;
  final Player player1;
  final Player player2;
  int currentPlayerIndex; // 0 = player1, 1 = player2
  TurnPhase turnPhase;
  int turnNumber;
  bool gameOver;
  int? winnerId;
  List<GridPosition> highlightedMoves;
  GridPosition? previewTarget;
  GameMode gameMode;

  // For undo system
  final List<GameSnapshot> _history = [];

  GameBoard({
    required this.size,
    required this.colorGrid,
    required this.player1,
    required this.player2,
    required this.gameMode,
    Set<Wall>? walls,
    Map<GridPosition, SpecialTile>? specialTiles,
    this.currentPlayerIndex = 0,
    this.turnPhase = TurnPhase.selectAction,
    this.turnNumber = 1,
    this.gameOver = false,
    this.winnerId,
    List<GridPosition>? highlightedMoves,
    this.previewTarget,
  })  : walls = walls ?? {},
        specialTiles = specialTiles ?? {},
        highlightedMoves = highlightedMoves ?? [];

  Player get currentPlayer => currentPlayerIndex == 0 ? player1 : player2;
  Player get opponentPlayer => currentPlayerIndex == 0 ? player2 : player1;

  int get player1GoalRow => size - 1; // Player 1 goes to bottom
  int get player2GoalRow => 0; // Player 2 goes to top

  bool isPlayer1StartRow(int row) => row == 0;
  bool isPlayer2StartRow(int row) => row == size - 1;

  bool isGoalRow(int row, int playerId) {
    return playerId == 1 ? row == player1GoalRow : row == player2GoalRow;
  }

  /// Generate a random board with controlled color distribution
  static GameBoard generate({
    required int size,
    required GameMode gameMode,
    required PlayerType player2Type,
    bool withSpecialTiles = false,
  }) {
    final rng = Random();
    final colorGrid = List.generate(
      size,
      (_) => List.generate(size, (_) => 0),
    );

    // Assign colors ensuring min 3-4 occurrences per color
    final totalTiles = size * size;
    final colorCount = TileColor.count;
    final minPerColor = (totalTiles / colorCount).floor();

    final colorList = <int>[];
    for (int c = 0; c < colorCount; c++) {
      colorList.addAll(List.filled(minPerColor, c));
    }
    // Fill remaining randomly
    while (colorList.length < totalTiles) {
      colorList.add(rng.nextInt(colorCount));
    }
    colorList.shuffle(rng);

    int idx = 0;
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        colorGrid[r][c] = colorList[idx++];
      }
    }

    final player1StartCol = size ~/ 2;
    final player2StartCol = size ~/ 2;

    final player1 = Player(
      id: 1,
      position: GridPosition(0, player1StartCol),
      type: PlayerType.human,
    );

    final player2 = Player(
      id: 2,
      position: GridPosition(size - 1, player2StartCol),
      type: player2Type,
    );

    final Map<GridPosition, SpecialTile> specialTilesMap = {};

    if (withSpecialTiles) {
      // Place a few special tiles, avoiding start positions
      final specialPositions = <GridPosition>{};
      final avoid = {player1.position, player2.position};

      _placeSpecialTile(
        specialPositions, avoid, size, rng, specialTilesMap,
        SpecialTileType.teleport, colorGrid,
      );
      _placeSpecialTile(
        specialPositions, avoid, size, rng, specialTilesMap,
        SpecialTileType.trap, colorGrid,
      );
      _placeSpecialTile(
        specialPositions, avoid, size, rng, specialTilesMap,
        SpecialTileType.booster, colorGrid,
      );
      _placeSpecialTile(
        specialPositions, avoid, size, rng, specialTilesMap,
        SpecialTileType.colorSwitch, colorGrid,
      );
    }

    return GameBoard(
      size: size,
      colorGrid: colorGrid,
      player1: player1,
      player2: player2,
      gameMode: gameMode,
      specialTiles: specialTilesMap,
    );
  }

  static void _placeSpecialTile(
    Set<GridPosition> placed,
    Set<GridPosition> avoid,
    int size,
    Random rng,
    Map<GridPosition, SpecialTile> map,
    SpecialTileType type,
    List<List<int>> colorGrid,
  ) {
    for (int attempts = 0; attempts < 50; attempts++) {
      final pos = GridPosition(
        1 + rng.nextInt(size - 2),
        rng.nextInt(size),
      );
      if (!placed.contains(pos) && !avoid.contains(pos)) {
        placed.add(pos);
        GridPosition? teleTarget;
        if (type == SpecialTileType.teleport) {
          GridPosition t;
          do {
            t = GridPosition(1 + rng.nextInt(size - 2), rng.nextInt(size));
          } while (placed.contains(t) || avoid.contains(t));
          teleTarget = t;
        }
        map[pos] = SpecialTile(
          position: pos,
          type: type,
          teleportTarget: teleTarget,
        );
        return;
      }
    }
  }

  int colorAt(GridPosition pos) => colorGrid[pos.row][pos.col];

  bool isInBounds(GridPosition pos) =>
      pos.row >= 0 && pos.row < size && pos.col >= 0 && pos.col < size;

  bool isWallBetween(GridPosition a, GridPosition b) {
    final w = Wall.canonical(a, b);
    return walls.contains(w);
  }

  /// Find the target position when moving in a direction from [from]
  /// Returns null if no valid move exists
  GridPosition? getMovementTarget(GridPosition from, Direction dir) {
    final targetColor = colorAt(from);
    final delta = dir.delta;
    GridPosition current = from + delta;

    while (isInBounds(current)) {
      final prev = GridPosition(current.row - delta.row, current.col - delta.col);
      if (isWallBetween(prev, current)) break;
      if (colorAt(current) == targetColor) return current;
      current = current + delta;
    }
    return null;
  }

  /// Get all reachable positions for current player
  List<GridPosition> getReachablePositions(Player player) {
    final result = <GridPosition>[];
    for (final dir in Direction.values) {
      final target = getMovementTarget(player.position, dir);
      if (target != null) result.add(target);
    }
    return result;
  }

  /// BFS: Check if [playerId] has at least one path to their goal row
  bool hasPathToGoal(int playerId) {
    final playerPos = playerId == 1 ? player1.position : player2.position;
    final goalRow = playerId == 1 ? player1GoalRow : player2GoalRow;

    final visited = <GridPosition>{};
    final queue = Queue<GridPosition>();
    queue.add(playerPos);
    visited.add(playerPos);

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      if (current.row == goalRow) return true;

      for (final dir in Direction.values) {
        final target = getMovementTarget(current, dir);
        if (target != null && !visited.contains(target)) {
          visited.add(target);
          queue.add(target);
        }
      }
    }
    return false;
  }

  /// Validate wall placement: both players must still have a path
  bool isValidWallPlacement(Wall wall) {
    if (walls.contains(wall)) return false;

    // Temporarily add wall
    walls.add(wall);
    final valid = hasPathToGoal(1) && hasPathToGoal(2);
    walls.remove(wall);
    return valid;
  }

  /// BFS distance to goal (for AI heuristics)
  int distanceToGoal(int playerId) {
    final playerPos = playerId == 1 ? player1.position : player2.position;
    final goalRow = playerId == 1 ? player1GoalRow : player2GoalRow;

    final visited = <GridPosition>{};
    final queue = Queue<List<dynamic>>(); // [pos, distance]
    queue.add([playerPos, 0]);
    visited.add(playerPos);

    while (queue.isNotEmpty) {
      final item = queue.removeFirst();
      final current = item[0] as GridPosition;
      final dist = item[1] as int;

      if (current.row == goalRow) return dist;

      for (final dir in Direction.values) {
        final target = getMovementTarget(current, dir);
        if (target != null && !visited.contains(target)) {
          visited.add(target);
          queue.add([target, dist + 1]);
        }
      }
    }
    return 999;
  }

  /// Execute a player move
  MoveResult executeMove(GridPosition target) {
    final player = currentPlayer;

    // Check win condition
    if (isGoalRow(target.row, player.id)) {
      _applyPlayerMove(player, target);
      gameOver = true;
      winnerId = player.id;
      return MoveResult.win;
    }

    _applyPlayerMove(player, target);

    // Check special tile
    final special = specialTiles[target];
    if (special != null && special.isActive) {
      return _applySpecialTile(player, special);
    }

    if (player.hasBooster && turnPhase == TurnPhase.move) {
      final p = currentPlayer;
      p.hasBooster = false;
      turnPhase = TurnPhase.boosterSecondMove;
      highlightedMoves = getReachablePositions(p);
      return MoveResult.boosterActive;
    }

    _endTurn();
    return MoveResult.success;
  }

  void _applyPlayerMove(Player player, GridPosition target) {
    _saveSnapshot();
    player.position = target;
    highlightedMoves = [];
    previewTarget = null;
  }

  MoveResult _applySpecialTile(Player player, SpecialTile special) {
    switch (special.type) {
      case SpecialTileType.teleport:
        if (special.teleportTarget != null) {
          player.position = special.teleportTarget!;
          if (isGoalRow(player.position.row, player.id)) {
            gameOver = true;
            winnerId = player.id;
            return MoveResult.win;
          }
        }
        _endTurn();
        return MoveResult.teleported;

      case SpecialTileType.trap:
        player.trappedTurns = 1;
        _endTurn();
        return MoveResult.trapped;

      case SpecialTileType.booster:
        player.hasBooster = true;
        turnPhase = TurnPhase.boosterSecondMove;
        highlightedMoves = getReachablePositions(player);
        return MoveResult.boosterActive;

      case SpecialTileType.colorSwitch:
        // Change the tile's color temporarily
        final pos = special.position;
        colorGrid[pos.row][pos.col] = (colorGrid[pos.row][pos.col] + 1) % TileColor.count;
        special.isActive = false;
        _endTurn();
        return MoveResult.colorSwitched;

      case SpecialTileType.none:
        _endTurn();
        return MoveResult.success;
    }
  }

  /// Place a wall between two adjacent tiles
  WallResult placeWall(Wall wall) {
    final player = currentPlayer;
    if (player.wallsRemaining <= 0) return WallResult.noWallsLeft;
    if (!isValidWallPlacement(wall)) return WallResult.blocksPath;

    _saveSnapshot();
    walls.add(wall);
    player.wallsRemaining--;
    _endTurn();
    return WallResult.placed;
  }

  void _endTurn() {
    turnPhase = TurnPhase.selectAction;
    highlightedMoves = [];
    previewTarget = null;

    // Switch player
    currentPlayerIndex = 1 - currentPlayerIndex;
    turnNumber++;

    // Handle trapped players
    final next = currentPlayer;
    if (next.trappedTurns > 0) {
      next.trappedTurns--;
      currentPlayerIndex = 1 - currentPlayerIndex;
      turnNumber++;
    }
  }

  void _saveSnapshot() {
    _history.add(GameSnapshot(
      player1Position: player1.position,
      player2Position: player2.position,
      walls: Set.from(walls),
      colorGrid: colorGrid.map((r) => List<int>.from(r)).toList(),
      player1WallsRemaining: player1.wallsRemaining,
      player2WallsRemaining: player2.wallsRemaining,
      currentPlayerIndex: currentPlayerIndex,
      turnNumber: turnNumber,
    ));
    if (_history.length > 10) _history.removeAt(0);
  }

  bool get canUndo {
    final player = currentPlayer;
    return _history.isNotEmpty && player.undosRemaining > 0;
  }

  void undo() {
    if (!canUndo) return;
    final snapshot = _history.removeLast();
    player1.position = snapshot.player1Position;
    player2.position = snapshot.player2Position;
    walls
      ..clear()
      ..addAll(snapshot.walls);
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        colorGrid[r][c] = snapshot.colorGrid[r][c];
      }
    }
    player1.wallsRemaining = snapshot.player1WallsRemaining;
    player2.wallsRemaining = snapshot.player2WallsRemaining;
    currentPlayerIndex = snapshot.currentPlayerIndex;
    turnNumber = snapshot.turnNumber;
    currentPlayer.undosRemaining--;
    turnPhase = TurnPhase.selectAction;
    highlightedMoves = [];
    previewTarget = null;
    gameOver = false;
    winnerId = null;
  }
}

enum MoveResult { success, win, teleported, trapped, boosterActive, colorSwitched }
enum WallResult { placed, blocksPath, noWallsLeft }

class GameSnapshot {
  final GridPosition player1Position;
  final GridPosition player2Position;
  final Set<Wall> walls;
  final List<List<int>> colorGrid;
  final int player1WallsRemaining;
  final int player2WallsRemaining;
  final int currentPlayerIndex;
  final int turnNumber;

  GameSnapshot({
    required this.player1Position,
    required this.player2Position,
    required this.walls,
    required this.colorGrid,
    required this.player1WallsRemaining,
    required this.player2WallsRemaining,
    required this.currentPlayerIndex,
    required this.turnNumber,
  });
}
