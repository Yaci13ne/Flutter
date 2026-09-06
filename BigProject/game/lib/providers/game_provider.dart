import 'package:flutter/material.dart';
import '../models/game_board.dart';
import '../models/grid_position.dart';
import '../models/wall.dart';
import '../models/player.dart';
import '../ai/ai_engine.dart';
import '../utils/app_theme.dart';

enum AppState { home, playing, gameOver }
enum SelectionMode { none, move, wall }

class GameProvider extends ChangeNotifier {
  GameBoard? _board;
  AppState _appState = AppState.home;
  SelectionMode _selectionMode = SelectionMode.none;
  GridPosition? _wallStart; // first tile of wall being placed
  bool _aiThinking = false;
  String _statusMessage = '';
  MoveResult? _lastMoveResult;

  final AIEngine _ai = AIEngine();

  // Stats
  int _player1Wins = 0;
  int _player2Wins = 0;

  GameBoard? get board => _board;
  AppState get appState => _appState;
  SelectionMode get selectionMode => _selectionMode;
  GridPosition? get wallStart => _wallStart;
  bool get aiThinking => _aiThinking;
  String get statusMessage => _statusMessage;
  MoveResult? get lastMoveResult => _lastMoveResult;
  int get player1Wins => _player1Wins;
  int get player2Wins => _player2Wins;

  void startGame({
    required GameMode mode,
    required int gridSize,
    required bool specialTiles,
    PlayerType player2Type = PlayerType.human,
  }) {
    _board = GameBoard.generate(
      size: gridSize,
      gameMode: mode,
      player2Type: player2Type,
      withSpecialTiles: specialTiles,
    );
    _appState = AppState.playing;
    _selectionMode = SelectionMode.none;
    _wallStart = null;
    _aiThinking = false;
    _statusMessage = _buildStatusMessage();
    _lastMoveResult = null;
    notifyListeners();

    // If AI goes first
    _checkAndRunAI();
  }

  void returnHome() {
    _appState = AppState.home;
    _board = null;
    notifyListeners();
  }

  void setSelectionMode(SelectionMode mode) {
    _selectionMode = mode;
    _wallStart = null;
    final b = _board!;

    if (mode == SelectionMode.move) {
      b.highlightedMoves = b.getReachablePositions(b.currentPlayer);
    } else {
      b.highlightedMoves = [];
    }
    notifyListeners();
  }

  /// Called when user taps a tile
  void onTileTap(GridPosition pos) {
    final b = _board;
    if (b == null || b.gameOver || _aiThinking) return;
    if (b.currentPlayer.isAI) return;

    if (_selectionMode == SelectionMode.move) {
      _handleMoveTap(pos);
    } else if (_selectionMode == SelectionMode.wall) {
      _handleWallTap(pos);
    }
  }

  void _handleMoveTap(GridPosition pos) {
    final b = _board!;
    if (!b.highlightedMoves.contains(pos)) return;

    final result = b.executeMove(pos);
    _lastMoveResult = result;
    _selectionMode = SelectionMode.none;

    if (b.gameOver) {
      if (b.winnerId == 1) _player1Wins++;
      if (b.winnerId == 2) _player2Wins++;
      _appState = AppState.gameOver;
      _statusMessage = '${b.winnerId == 1 ? "Player 1" : "Player 2"} Wins!';
      notifyListeners();
      return;
    }

    _statusMessage = _buildStatusMessage();
    notifyListeners();

    // Check AI turn
    _checkAndRunAI();
  }

  void _handleWallTap(GridPosition pos) {
    final b = _board!;
    if (_wallStart == null) {
      _wallStart = pos;
      notifyListeners();
    } else {
      // Check adjacency
      final start = _wallStart!;
      final dr = (pos.row - start.row).abs();
      final dc = (pos.col - start.col).abs();

      if ((dr == 1 && dc == 0) || (dr == 0 && dc == 1)) {
        final wall = Wall.canonical(start, pos);
        final result = b.placeWall(wall);

        if (result == WallResult.placed) {
          _selectionMode = SelectionMode.none;
          _wallStart = null;
          _statusMessage = _buildStatusMessage();
          notifyListeners();
          _checkAndRunAI();
        } else if (result == WallResult.blocksPath) {
          _statusMessage = '⚠️ Wall blocks a path! Choose another position.';
          _wallStart = null;
          notifyListeners();
        } else if (result == WallResult.noWallsLeft) {
          _statusMessage = '❌ No walls remaining!';
          _wallStart = null;
          notifyListeners();
        }
      } else {
        // Non-adjacent: reset selection
        _wallStart = pos;
        notifyListeners();
      }
    }
  }

  void onTileHover(GridPosition? pos) {
    final b = _board;
    if (b == null) return;

    if (_selectionMode == SelectionMode.move && pos != null) {
      b.previewTarget = b.highlightedMoves.contains(pos) ? pos : null;
      notifyListeners();
    }
  }

  void undo() {
    final b = _board;
    if (b == null || !b.canUndo) return;
    b.undo();
    _selectionMode = SelectionMode.none;
    _wallStart = null;
    _statusMessage = _buildStatusMessage();
    notifyListeners();
  }

  Future<void> _checkAndRunAI() async {
    final b = _board;
    if (b == null || b.gameOver) return;
    if (!b.currentPlayer.isAI) return;

    _aiThinking = true;
    _statusMessage = '🤖 AI is thinking...';
    notifyListeners();

    final action = await _ai.getAction(b, b.currentPlayer);
    _aiThinking = false;

    if (b.gameOver) {
      notifyListeners();
      return;
    }

    if (action.type == AIActionType.move && action.moveTarget != null) {
      final result = b.executeMove(action.moveTarget!);
      _lastMoveResult = result;

      if (b.gameOver) {
        if (b.winnerId == 1) _player1Wins++;
        if (b.winnerId == 2) _player2Wins++;
        _appState = AppState.gameOver;
        _statusMessage = '${b.winnerId == 1 ? "Player 1" : "Player 2"} Wins!';
        notifyListeners();
        return;
      }
    } else if (action.type == AIActionType.placeWall && action.wall != null) {
      b.placeWall(action.wall!);
    }

    _selectionMode = SelectionMode.none;
    _statusMessage = _buildStatusMessage();
    notifyListeners();

    // Chain AI turns if needed
    await _checkAndRunAI();
  }

  String _buildStatusMessage() {
    final b = _board;
    if (b == null) return '';
    final p = b.currentPlayer;
    final name = p.isAI ? '🤖 AI' : p.name;
    return "$name's turn — Walls: ${p.wallsRemaining} | Undos: ${p.undosRemaining}";
  }
}
