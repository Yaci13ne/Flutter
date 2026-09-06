import 'package:flutter/material.dart';
import '../models/game_board.dart';
import '../utils/app_theme.dart';

class ColorLegendWidget extends StatelessWidget {
  final GameBoard board;

  const ColorLegendWidget({super.key, required this.board});

  @override
  Widget build(BuildContext context) {
    // Count occurrences of each color
    final counts = List.filled(TileColor.count, 0);
    for (int r = 0; r < board.size; r++) {
      for (int c = 0; c < board.size; c++) {
        counts[board.colorGrid[r][c]]++;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(TileColor.count, (i) {
          final color = AppTheme.tileColors[i];
          final name = AppTheme.tileColorNames[i];
          final isCurrentColor =
              color == AppTheme.tileColors[board.colorAt(board.currentPlayer.position)];

          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: color.withOpacity(isCurrentColor ? 0.2 : 0.07),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: color.withOpacity(isCurrentColor ? 0.7 : 0.2),
                  width: isCurrentColor ? 1.5 : 0.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    name,
                    style: TextStyle(
                      color: color.withOpacity(isCurrentColor ? 1 : 0.5),
                      fontSize: 7,
                      fontWeight: isCurrentColor ? FontWeight.w700 : FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.clip,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
