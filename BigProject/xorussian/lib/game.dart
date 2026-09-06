import 'dart:async';
import 'package:flutter/material.dart';
import 'package:xorussian/doll.dart';
import 'package:xorussian/main.dart';
import 'package:xorussian/result.dart';
import 'package:xorussian/theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:xorussian/network_service.dart';

class GamePage extends StatefulWidget {
  final String blueName;
  final String redName;
  final String? roomCode; 
  final bool isHost;
  final int blueWins;
  final int redWins;
  const GamePage({
    super.key,
    required this.blueName,
    required this.redName,
    this.roomCode,
    this.isHost = true,
    this.blueWins = 0,
    this.redWins = 0,
  });
  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final List<List<Doll>> board = List.generate(9, (_) => []);
  bool blueTurn = true;
  String winner = '';

  int blueWins = 0;
  int redWins = 0;

  late List<Doll> bluePieces;
  late List<Doll> redPieces;

  final NetworkService _network = NetworkService();
  StreamSubscription? _roomSubscription;
  bool _isOpponentConnected = false;
  bool _winHandled = false;

  String _currentBlueName = '';
  String _currentRedName = '';

  @override
  void initState() {
    super.initState();
    resetPieces();
    blueWins = widget.blueWins;
    redWins = widget.redWins;
    _currentBlueName = widget.blueName;
    _currentRedName = widget.redName;

    if (widget.roomCode != null) {
      _roomSubscription = _network.streamRoom(widget.roomCode!).listen((state) {
        if (state != null) {
          _syncStateFromServer(state);
        }
      });
    } else {
      _isOpponentConnected = true; // Local play
    }
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    super.dispose();
  }

  void _syncStateFromServer(RoomState state) {
    if (!mounted) return;

  
    int localMoveCount = 18 - (bluePieces.length + redPieces.length);
    int serverMoveCount = 18 - (state.bluePieces.length + state.redPieces.length);
    
    if (_isOpponentConnected && serverMoveCount == localMoveCount && state.winner == winner) {
      return;
    }

*9    final previousWinner = winner;

    setState(() {
      _isOpponentConnected = state.status != 'waiting';
      _currentBlueName = state.hostName;
      _currentRedName = state.guestName.isEmpty
          ? 'Waiting...'
          : state.guestName;

      for (int i = 0; i < 9; i++) {
        board[i] = List.from(state.board[i]);
      }
      blueTurn = state.blueTurn;
      winner = state.winner;
      bluePieces = List.from(state.bluePieces);
      redPieces = List.from(state.redPieces);
    });

    if (winner.isNotEmpty && previousWinner.isEmpty && !_winHandled) {
      _handleWin();
    }
  }

  void resetPieces() {
    final sizes = [
      DollSize.xs,
      DollSize.s,
      DollSize.m,
      DollSize.l,
      DollSize.xl,
      DollSize.xs,
      DollSize.s,
      DollSize.m,
      DollSize.l,
    ];
    bluePieces = sizes.map((s) => Doll('X', s)).toList();
    redPieces = sizes.map((s) => Doll('O', s)).toList();
  }

  bool canPlace(int index, Doll doll) {
    if (board[index].isEmpty) return true;
    return doll.size.index > board[index].last.size.index;
  }

  void place(int index, Doll doll) {
    if (winner.isNotEmpty || !canPlace(index, doll)) return;
    if (!_isOpponentConnected) return;

    // Online turn enforcement: Only the local player can move on their turn
    if (widget.roomCode != null) {
      if (widget.isHost && !blueTurn) return; // Host plays Blue only
      if (!widget.isHost && blueTurn) return; // Guest plays Red only
    }

    setState(() {
      board[index].add(doll);

      if (doll.owner == 'X') {
        final i = bluePieces.indexWhere((d) => d.size == doll.size);
        if (i != -1) bluePieces.removeAt(i);
      } else {
        final i = redPieces.indexWhere((d) => d.size == doll.size);
        if (i != -1) redPieces.removeAt(i);
      }

      blueTurn = !blueTurn;
      winner = checkWinner();
    });

    if (widget.roomCode != null) {
      _network.updateGameState(
        widget.roomCode!,
        RoomState(
          status: 'playing',
          joinCode: widget.roomCode!,
          hostName: _currentBlueName,
          guestName: _currentRedName,
          board: board,
          blueTurn: blueTurn,
          winner: winner,
          bluePieces: bluePieces,
          redPieces: redPieces,
          hostRematch: false,
          guestRematch: false,
        ),
      );
      // If WE caused the win, handle it here directly locally. 
      // The opponent will handle it via their server sync.
      if (winner.isNotEmpty && !_winHandled) {
        _handleWin();
      }
    } else {
      // Local play: handle win directly since there is no server sync
      if (winner.isNotEmpty && !_winHandled) {
        _handleWin();
      }
    }
  }

  void _handleWin() {
    _winHandled = true;
    if (winner == 'X') blueWins++;
    if (winner == 'O') redWins++;

    String resultText;
    if (winner == 'Draw') {
      resultText = 'Draw!';
    } else if (winner == 'X') {
      resultText = 'Winner: $_currentBlueName';
    } else {
      resultText = 'Winner: $_currentRedName';
    }

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(
            result: resultText,
            blueName: _currentBlueName,
            redName: _currentRedName,
            blueWins: blueWins,
            redWins: redWins,
            winnerColor: winner == 'X'
                ? AppTheme.primaryBlue
                : (winner == 'O' ? AppTheme.primaryRed : Colors.white),
            roomCode: widget.roomCode,
            isHost: widget.isHost,
          ),
        ),
      );
    });
  }

  String checkWinner() {
    final top = board.map((c) => c.isEmpty ? '' : c.last.owner).toList();
    const wins = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var w in wins) {
      if (top[w[0]] != '' && top[w[0]] == top[w[1]] && top[w[1]] == top[w[2]]) {
        return top[w[0]];
      }
    }
    if (bluePieces.isEmpty && redPieces.isEmpty) return 'Draw';
    return '';
  }

  double sizeToPixels(DollSize size) {
    switch (size) {
      case DollSize.xs:
        return 32;
      case DollSize.s:
        return 42;
      case DollSize.m:
        return 52;
      case DollSize.l:
        return 62;
      case DollSize.xl:
        return 72;
    }
  }

  Widget buildDoll(Doll doll) {
    return Image.asset(
      doll.owner == 'X' ? 'assets/blue.png' : 'assets/red.png',
      width: sizeToPixels(doll.size),
      height: sizeToPixels(doll.size),
      fit: BoxFit.contain,
    );
  }

  Widget draggableDoll(Doll doll) {
    return Draggable<Doll>(
      data: doll,
      feedback: Transform.scale(scale: 1.2, child: buildDoll(doll)),
      childWhenDragging: Opacity(opacity: 0.2, child: buildDoll(doll)),
      child: buildDoll(doll),
    );
  }

  void reset() {
    if (widget.roomCode != null && !widget.isHost)
      return; // Only host can reset online

    setState(() {
      for (var c in board) {
        c.clear();
      }
      blueTurn = true;
      winner = '';
      _winHandled = false;
      resetPieces();
    });

    if (widget.roomCode != null) {
      _network.updateGameState(
        widget.roomCode!,
        RoomState(
          status: 'playing',
          joinCode: widget.roomCode!,
          hostName: _currentBlueName,
          guestName: _currentRedName,
          board: board,
          blueTurn: blueTurn,
          winner: winner,
          bluePieces: bluePieces,
          redPieces: redPieces,
          hostRematch: false,
          guestRematch: false,
        ),
      );
    }
  }

  Widget buildPlayerDock({required bool isBlue}) {
    final pieces = isBlue ? bluePieces : redPieces;
    final color = isBlue ? AppTheme.primaryBlue : AppTheme.primaryRed;

    // Is it this color's turn?
    bool isMyTurn = (isBlue && blueTurn) || (!isBlue && !blueTurn);

    // In online mode, a dock is only interactive on its own machine
    bool isActive = winner.isEmpty && isMyTurn && _isOpponentConnected;
    if (widget.roomCode != null) {
      if (isBlue && !widget.isHost) isActive = false;
      if (!isBlue && widget.isHost) isActive = false;
    }

    final opacity = isActive ? 1.0 : 0.4;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive
                ? color.withValues(alpha: 0.5)
                : AppTheme.borderColor,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        height: 100,
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: pieces
                  .map(
                    (doll) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: isActive ? draggableDoll(doll) : buildDoll(doll),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentOwner = blueTurn ? 'X' : 'O';
    final statusColor = winner.isEmpty
        ? (blueTurn ? AppTheme.primaryBlue : AppTheme.primaryRed)
        : (winner == 'X'
              ? AppTheme.primaryBlue
              : (winner == 'O' ? AppTheme.primaryRed : Colors.white));

    String statusText;
    if (winner.isNotEmpty) {
      statusText = winner == 'Draw'
          ? 'Draw!'
          : '${winner == 'X' ? _currentBlueName : _currentRedName} Wins!';
    } else if (!_isOpponentConnected) {
      statusText = 'Waiting for Opponent... Code: ${widget.roomCode}';
    } else {
      statusText = '${blueTurn ? _currentBlueName : _currentRedName}\'s Turn';
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.coreBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        _roomSubscription?.cancel();
                        Navigator.pop(context);
                      },
                    ),
                    Expanded(
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                              letterSpacing: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white70),
                      onPressed: (widget.roomCode == null || widget.isHost)
                          ? reset
                          : null,
                    ),
                  ],
                ),
              ),

              // Top Dock (Red)
              buildPlayerDock(isBlue: false),

              // Board
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(8),
                        itemCount: 9,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                            ),
                        itemBuilder: (context, index) {
                          return DragTarget<Doll>(
                            onWillAcceptWithDetails: (details) =>
                                _isOpponentConnected &&
                                details.data.owner == currentOwner &&
                                canPlace(index, details.data),
                            onAcceptWithDetails: (details) =>
                                place(index, details.data),
                            builder: (context, candidateData, rejectedData) {
                              final isHovered = candidateData.isNotEmpty;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: isHovered
                                      ? statusColor.withValues(alpha: 0.2)
                                      : Colors.black12,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isHovered
                                        ? statusColor
                                        : Colors.white12,
                                  ),
                                ),
                                child: Center(
                                  child: board[index].isEmpty
                                      ? null
                                      : buildDoll(
                                          board[index].last,
                                        ).animate().scale(
                                          duration: 300.ms,
                                          curve: Curves.easeOutBack,
                                        ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Dock (Blue)
              buildPlayerDock(isBlue: true),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
