import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/game_board.dart';
import '../utils/app_theme.dart';

class MoveResultOverlay extends StatelessWidget {
  final MoveResult result;

  const MoveResultOverlay({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = _getDisplay(result);
    if (icon == null) return const SizedBox();

    return Positioned(
      top: MediaQuery.of(context).size.height * 0.4,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 200.ms)
            .then(delay: 1200.ms)
            .fadeOut(duration: 400.ms),
      ),
    );
  }

  (String?, String, Color) _getDisplay(MoveResult result) {
    switch (result) {
      case MoveResult.teleported:
        return ('⚡', 'TELEPORTED!', AppTheme.neonPurple);
      case MoveResult.trapped:
        return ('💀', 'TRAPPED! SKIP NEXT TURN', Colors.redAccent);
      case MoveResult.boosterActive:
        return ('🚀', 'BOOST! MOVE AGAIN', AppTheme.neonGreen);
      case MoveResult.colorSwitched:
        return ('🔄', 'COLOR SWITCHED!', AppTheme.neonYellow);
      case MoveResult.win:
        return ('🏆', 'WINNER!', AppTheme.neonBlue);
      default:
        return (null, '', Colors.white);
    }
  }
}
