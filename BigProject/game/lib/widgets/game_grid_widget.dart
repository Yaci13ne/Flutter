import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../models/game_board.dart';
import '../models/grid_position.dart';
import '../models/wall.dart';
import '../models/special_tile.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';

class GameGridWidget extends StatelessWidget {
  final GameBoard board;

  const GameGridWidget({super.key, required this.board});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellSize = constraints.maxWidth / board.size;
          return Stack(
            children: [
              // Grid tiles
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: board.size,
                ),
                itemCount: board.size * board.size,
                itemBuilder: (context, index) {
                  final row = index ~/ board.size;
                  final col = index % board.size;
                  final pos = GridPosition(row, col);
                  return _TileWidget(
                    board: board,
                    pos: pos,
                    cellSize: cellSize,
                  );
                },
              ),
              // Wall overlays
              CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxWidth),
                painter: WallPainter(
                  walls: board.walls,
                  gridSize: board.size,
                  cellSize: cellSize,
                  wallStart: context.watch<GameProvider>().wallStart,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TileWidget extends StatelessWidget {
  final GameBoard board;
  final GridPosition pos;
  final double cellSize;

  const _TileWidget({
    required this.board,
    required this.pos,
    required this.cellSize,
  });

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    final colorIndex = board.colorGrid[pos.row][pos.col];
    final tileColor = AppTheme.tileColors[colorIndex];

    final isP1 = board.player1.position == pos;
    final isP2 = board.player2.position == pos;
    final isHighlighted = board.highlightedMoves.contains(pos);
    final isPreview = board.previewTarget == pos;
    final isWallStart = gp.wallStart == pos;
    final special = board.specialTiles[pos];

    final isP1Goal = pos.row == board.player1GoalRow;
    final isP2Goal = pos.row == board.player2GoalRow;

    final baseColor = tileColor.withOpacity(0.18);
    final borderColor = tileColor.withOpacity(0.3);

    Color? overlayColor;
    if (isP1Goal) overlayColor = AppTheme.player1Color.withOpacity(0.08);
    if (isP2Goal) overlayColor = AppTheme.player2Color.withOpacity(0.08);
    if (isHighlighted) overlayColor = tileColor.withOpacity(0.35);
    if (isPreview) overlayColor = tileColor.withOpacity(0.6);
    if (isWallStart) overlayColor = Colors.white.withOpacity(0.2);

    return GestureDetector(
      onTap: () => gp.onTileTap(pos),
      child: Container(
        margin: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: overlayColor ?? baseColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isHighlighted
                ? tileColor.withOpacity(0.8)
                : isWallStart
                    ? Colors.white
                    : borderColor,
            width: isHighlighted || isWallStart ? 1.5 : 0.5,
          ),
          boxShadow: isHighlighted
              ? [
                  BoxShadow(
                    color: tileColor.withOpacity(0.4),
                    blurRadius: 6,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Color dot
            Container(
              width: cellSize * 0.2,
              height: cellSize * 0.2,
              decoration: BoxDecoration(
                color: tileColor.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),

            // Goal stripe
            if (isP1Goal || isP2Goal)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      begin: isP1Goal
                          ? Alignment.bottomCenter
                          : Alignment.topCenter,
                      end: isP1Goal
                          ? Alignment.topCenter
                          : Alignment.bottomCenter,
                      colors: [
                        (isP1Goal
                                ? AppTheme.player1Color
                                : AppTheme.player2Color)
                            .withOpacity(0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

            // Special tile icon
            if (special != null && special.type != SpecialTileType.none)
              Text(
                special.label,
                style: TextStyle(fontSize: cellSize * 0.28),
              ),

            // Player tokens
            if (isP1)
              _PlayerToken(
                color: AppTheme.player1Color,
                size: cellSize * 0.55,
                id: 1,
              ),
            if (isP2)
              _PlayerToken(
                color: AppTheme.player2Color,
                size: cellSize * 0.55,
                id: 2,
              ),

            // Highlight pulse indicator
            if (isHighlighted && !isP1 && !isP2)
              Container(
                width: cellSize * 0.4,
                height: cellSize * 0.4,
                decoration: BoxDecoration(
                  color: tileColor.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
              )
                  .animate(onPlay: (c) => c.repeat())
                  .scale(
                      begin: const Offset(0.7, 0.7),
                      end: const Offset(1.0, 1.0),
                      duration: 800.ms,
                      curve: Curves.easeInOut)
                  .then()
                  .scale(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(0.7, 0.7),
                      duration: 800.ms,
                      curve: Curves.easeInOut),
          ],
        ),
      ),
    );
  }
}

class _PlayerToken extends StatelessWidget {
  final Color color;
  final double size;
  final int id;

  const _PlayerToken(
      {required this.color, required this.size, required this.id});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.8),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
      ),
      child: Center(
        child: Text(
          '$id',
          style: TextStyle(
            color: Colors.black,
            fontSize: size * 0.45,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    ).animate().scale(
        begin: const Offset(0, 0), duration: 250.ms, curve: Curves.elasticOut);
  }
}

/// Custom painter for wall rendering
class WallPainter extends CustomPainter {
  final Set<Wall> walls;
  final int gridSize;
  final double cellSize;
  final GridPosition? wallStart;

  WallPainter({
    required this.walls,
    required this.gridSize,
    required this.cellSize,
    this.wallStart,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    for (final wall in walls) {
      _drawWall(canvas, wall, paint);
    }

    // Highlight wall start
    if (wallStart != null) {
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      final rect = Rect.fromLTWH(
        wallStart!.col * cellSize + 2,
        wallStart!.row * cellSize + 2,
        cellSize - 4,
        cellSize - 4,
      );
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          highlightPaint);
    }
  }

  void _drawWall(Canvas canvas, Wall wall, Paint paint) {
    final a = wall.from;
    final b = wall.to;

    // Determine wall line position (between the two tiles)
    double x1, y1, x2, y2;
    const margin = 4.0;

    if (a.row == b.row) {
      // Horizontal adjacency → vertical wall
      final wallCol = (a.col < b.col ? b.col : a.col);
      x1 = wallCol * cellSize;
      y1 = a.row * cellSize + margin;
      x2 = x1;
      y2 = (a.row + 1) * cellSize - margin;
    } else {
      // Vertical adjacency → horizontal wall
      final wallRow = (a.row < b.row ? b.row : a.row);
      x1 = a.col * cellSize + margin;
      y1 = wallRow * cellSize;
      x2 = (a.col + 1) * cellSize - margin;
      y2 = y1;
    }

    canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
  }

  @override
  bool shouldRepaint(covariant WallPainter oldDelegate) =>
      oldDelegate.walls != walls || oldDelegate.wallStart != wallStart;
}
