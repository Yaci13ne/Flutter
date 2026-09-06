import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../providers/game_provider.dart';
import '../models/game_board.dart';
import '../models/player.dart';
import '../utils/app_theme.dart';
import '../widgets/game_grid_widget.dart';
import '../widgets/action_bar_widget.dart';
import '../widgets/player_info_widget.dart';
import '../widgets/move_result_overlay.dart';
import '../widgets/color_legend_widget.dart';
import '../widgets/path_indicator_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _turnAnimController;
  int _lastPlayerIndex = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _turnAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _turnAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gp, _) {
        final board = gp.board;
        if (board == null) return const SizedBox();

        if (board.currentPlayerIndex != _lastPlayerIndex) {
          _lastPlayerIndex = board.currentPlayerIndex;
          _turnAnimController.forward(from: 0);
          HapticFeedback.lightImpact();
        }

        if (gp.appState == AppState.gameOver &&
            _confettiController.state != ConfettiControllerState.playing) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _confettiController.play();
            HapticFeedback.heavyImpact();
          });
        }

        return Scaffold(
          backgroundColor: AppTheme.background,
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    _buildTopBar(context, gp, board),
                    PlayerInfoWidget(
                      player: board.player2,
                      isActive: board.currentPlayerIndex == 1 && !board.gameOver,
                      goalLabel: '▼ GOAL',
                    ),
                    const SizedBox(height: 6),
                    PathIndicatorWidget(board: board),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: GameGridWidget(board: board),
                      ),
                    ),
                    const SizedBox(height: 6),
                    ColorLegendWidget(board: board),
                    const SizedBox(height: 8),
                    PlayerInfoWidget(
                      player: board.player1,
                      isActive: board.currentPlayerIndex == 0 && !board.gameOver,
                      goalLabel: '▲ GOAL',
                    ),
                    const SizedBox(height: 8),
                    if (!board.gameOver) ActionBarWidget(board: board),
                    const SizedBox(height: 8),
                    _buildStatusBar(gp),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  colors: AppTheme.tileColors,
                  numberOfParticles: 40,
                  gravity: 0.12,
                  emissionFrequency: 0.05,
                ),
              ),
              if (gp.lastMoveResult != null)
                MoveResultOverlay(result: gp.lastMoveResult!),
              if (gp.appState == AppState.gameOver)
                _buildWinOverlay(context, gp, board),
              if (gp.aiThinking)
                Positioned(
                  bottom: 130,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.neonPink.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(AppTheme.neonPink),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'AI thinking...',
                            style: TextStyle(color: Colors.white54, fontSize: 13),
                          ),
                        ],
                      ),
                    ).animate(onPlay: (c) => c.repeat())
                        .shimmer(duration: 1500.ms, color: AppTheme.neonPink.withOpacity(0.2)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, GameProvider gp, GameBoard board) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white38, size: 20),
            onPressed: () => _showExitDialog(context, gp),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.border),
            ),
            child: Text(
              'TURN ${board.turnNumber}',
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 11,
                letterSpacing: 3,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.undo,
              color: board.canUndo ? Colors.white54 : Colors.white12,
              size: 20,
            ),
            onPressed: board.canUndo ? gp.undo : null,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar(GameProvider gp) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.border),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            gp.statusMessage,
            key: ValueKey(gp.statusMessage),
            style: const TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 0.5),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildWinOverlay(BuildContext context, GameProvider gp, GameBoard board) {
    final winnerId = board.winnerId!;
    final isP1 = winnerId == 1;
    final color = isP1 ? AppTheme.player1Color : AppTheme.player2Color;
    final neon = isP1 ? AppTheme.neonBlue : AppTheme.neonPink;

    return Container(
      color: Colors.black.withOpacity(0.88),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 72))
                .animate()
                .scale(begin: const Offset(0, 0), duration: 700.ms, curve: Curves.elasticOut)
                .rotate(begin: -0.1, end: 0),
            const SizedBox(height: 20),
            ShaderMask(
              shaderCallback: (bounds) =>
                  LinearGradient(colors: [color, neon, Colors.white], stops: const [0, 0.5, 1])
                      .createShader(bounds),
              child: Text(
                isP1
                    ? (board.player1.isAI ? 'AI WINS!' : 'PLAYER 1\nWINS!')
                    : (board.player2.isAI ? 'AI WINS!' : 'PLAYER 2\nWINS!'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                  color: Colors.white,
                ),
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
            const SizedBox(height: 12),
            Text(
              'Completed in ${board.turnNumber} turns',
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14, letterSpacing: 2),
            ).animate().fadeIn(delay: 600.ms),
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ScorePill(label: 'P1', wins: gp.player1Wins, color: AppTheme.player1Color),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('—', style: TextStyle(color: Colors.white24)),
                ),
                _ScorePill(label: 'P2', wins: gp.player2Wins, color: AppTheme.player2Color),
              ],
            ).animate().fadeIn(delay: 700.ms),
            const SizedBox(height: 44),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _WinActionButton(
                  label: 'PLAY AGAIN',
                  color: neon,
                  icon: Icons.replay,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    gp.startGame(
                      mode: board.gameMode,
                      gridSize: board.size,
                      specialTiles: board.specialTiles.isNotEmpty,
                      player2Type: board.player2.type,
                    );
                  },
                ),
                const SizedBox(width: 14),
                _WinActionButton(
                  label: 'HOME',
                  color: Colors.white38,
                  icon: Icons.home,
                  outlined: true,
                  onTap: () {
                    gp.returnHome();
                    Navigator.pop(context);
                  },
                ),
              ],
            ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.4),
          ],
        ),
      ),
    );
  }

  void _showExitDialog(BuildContext context, GameProvider gp) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (_) => Dialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Quit Game?',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Your progress will be lost.',
                  style: TextStyle(color: Colors.white54, fontSize: 13)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.2),
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        gp.returnHome();
                        Navigator.pop(context);
                      },
                      child: const Text('QUIT'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  final String label;
  final int wins;
  final Color color;
  const _ScorePill({required this.label, required this.wins, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text('$wins',
              style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900)),
          Text(label,
              style: TextStyle(color: color.withOpacity(0.6), fontSize: 10, letterSpacing: 2)),
        ],
      ),
    );
  }
}

class _WinActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  final bool outlined;
  const _WinActionButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
    this.outlined = false,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : color.withOpacity(0.15),
          border: Border.all(color: outlined ? Colors.white24 : color, width: outlined ? 1 : 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: outlined ? Colors.white38 : color),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: outlined ? Colors.white54 : color,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }
}
