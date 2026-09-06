import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_board.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/app_theme.dart';

class ActionBarWidget extends StatelessWidget {
  final GameBoard board;

  const ActionBarWidget({super.key, required this.board});

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    final settings = context.watch<SettingsProvider>();
    final currentPlayer = board.currentPlayer;
    final isAITurn = currentPlayer.isAI || gp.aiThinking;

    if (isAITurn) {
      return _AIThinkingBar();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Move button
          Expanded(
            child: _ActionButton(
              label: 'MOVE',
              icon: Icons.open_with,
              color: currentPlayer.color,
              selected: gp.selectionMode == SelectionMode.move,
              onTap: gp.selectionMode == SelectionMode.move
                  ? () => gp.setSelectionMode(SelectionMode.none)
                  : () => gp.setSelectionMode(SelectionMode.move),
            ),
          ),
          if (settings.wallModeEnabled && currentPlayer.wallsRemaining > 0) ...[
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                label: 'WALL (${currentPlayer.wallsRemaining})',
                icon: Icons.fence,
                color: Colors.white70,
                selected: gp.selectionMode == SelectionMode.wall,
                onTap: gp.selectionMode == SelectionMode.wall
                    ? () => gp.setSelectionMode(SelectionMode.none)
                    : () => gp.setSelectionMode(SelectionMode.wall),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.2) : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : AppTheme.border,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8)]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: selected ? color : Colors.white38),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? color : Colors.white38,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AIThinkingBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(AppTheme.neonPink),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'AI IS THINKING...',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
