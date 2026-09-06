import 'package:flutter/material.dart';
import '../models/game_board.dart';
import '../utils/app_theme.dart';

class PathIndicatorWidget extends StatelessWidget {
  final GameBoard board;

  const PathIndicatorWidget({super.key, required this.board});

  @override
  Widget build(BuildContext context) {
    final p1Dist = board.distanceToGoal(1);
    final p2Dist = board.distanceToGoal(2);
    final total = (p1Dist + p2Dist).clamp(1, 999);

    // Progress: how close each player is (lower dist = higher progress)
    final p1Progress = p2Dist / total;
    final p2Progress = p1Dist / total;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _DistBadge(
            dist: p1Dist,
            color: AppTheme.player1Color,
            label: 'P1',
            isActive: board.currentPlayerIndex == 0,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                // Track
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                // P1 progress (left side)
                FractionallySizedBox(
                  widthFactor: p1Progress.clamp(0.0, 0.5),
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppTheme.player1Color,
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.neonBlue.withOpacity(0.5),
                          blurRadius: 4,
                        )
                      ],
                    ),
                  ),
                ),
                // P2 progress (right side)
                Align(
                  alignment: Alignment.centerRight,
                  child: FractionallySizedBox(
                    widthFactor: p2Progress.clamp(0.0, 0.5),
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppTheme.player2Color,
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.neonPink.withOpacity(0.5),
                            blurRadius: 4,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _DistBadge(
            dist: p2Dist,
            color: AppTheme.player2Color,
            label: 'P2',
            isActive: board.currentPlayerIndex == 1,
          ),
        ],
      ),
    );
  }
}

class _DistBadge extends StatelessWidget {
  final int dist;
  final Color color;
  final String label;
  final bool isActive;

  const _DistBadge({
    required this.dist,
    required this.color,
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(isActive ? 0.15 : 0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(isActive ? 0.5 : 0.2),
          width: isActive ? 1 : 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.7),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            dist >= 999 ? '∞' : '$dist',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
