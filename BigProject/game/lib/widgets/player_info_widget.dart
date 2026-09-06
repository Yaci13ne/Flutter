import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/player.dart';
import '../utils/app_theme.dart';

class PlayerInfoWidget extends StatelessWidget {
  final Player player;
  final bool isActive;
  final String goalLabel;

  const PlayerInfoWidget({
    super.key,
    required this.player,
    required this.isActive,
    required this.goalLabel,
  });

  @override
  Widget build(BuildContext context) {
    final color = player.color;
    final neon = player.neonColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.1) : AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? color.withOpacity(0.6) : AppTheme.border,
          width: isActive ? 1.5 : 1,
        ),
        boxShadow: isActive
            ? [BoxShadow(color: neon.withOpacity(0.15), blurRadius: 12, spreadRadius: 2)]
            : null,
      ),
      child: Row(
        children: [
          // Token indicator
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withOpacity(isActive ? 0.9 : 0.3),
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [BoxShadow(color: neon, blurRadius: 8, spreadRadius: 1)]
                  : null,
            ),
            child: Center(
              child: Text(
                '${player.id}',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      player.isAI ? '🤖 AI PLAYER' : player.name.toUpperCase(),
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: neon.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: neon.withOpacity(0.5)),
                        ),
                        child: Text(
                          'YOUR TURN',
                          style: TextStyle(
                            color: neon,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ).animate(onPlay: (c) => c.repeat())
                          .fadeIn(duration: 600.ms)
                          .then()
                          .fadeOut(duration: 600.ms),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _Stat(
                      icon: '🧱',
                      value: player.wallsRemaining,
                      label: 'walls',
                      color: isActive ? Colors.white70 : Colors.white30,
                    ),
                    const SizedBox(width: 16),
                    _Stat(
                      icon: '↩️',
                      value: player.undosRemaining,
                      label: 'undos',
                      color: isActive ? Colors.white70 : Colors.white30,
                    ),
                    if (player.trappedTurns > 0) ...[
                      const SizedBox(width: 16),
                      Text(
                        '💀 TRAPPED',
                        style: TextStyle(
                          color: Colors.red.shade400,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    if (player.hasBooster) ...[
                      const SizedBox(width: 16),
                      Text(
                        '🚀 BOOST',
                        style: TextStyle(
                          color: AppTheme.neonGreen,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Text(
            goalLabel,
            style: TextStyle(
              color: color.withOpacity(isActive ? 0.8 : 0.3),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String icon;
  final int value;
  final String label;
  final Color color;

  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 10)),
        const SizedBox(width: 3),
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(color: color.withOpacity(0.6), fontSize: 10),
        ),
      ],
    );
  }
}
