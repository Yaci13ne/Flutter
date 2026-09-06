import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import '../models/game_board.dart';
import '../models/player.dart';
import '../utils/app_theme.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              _buildTitle(context),
              const Spacer(),
              _buildPlayerScores(context),
              const SizedBox(height: 40),
              _buildMenuButtons(context),
              const Spacer(flex: 2),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppTheme.neonBlue, AppTheme.neonPink],
          ).createShader(bounds),
          child: const Text(
            'COLOR\nPATH',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w900,
              height: 1.0,
              letterSpacing: -2,
              color: Colors.white,
            ),
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3),
        const SizedBox(height: 8),
        Text(
          'CHALLENGE',
          style: TextStyle(
            fontSize: 14,
            letterSpacing: 8,
            color: Colors.white.withOpacity(0.4),
            fontWeight: FontWeight.w300,
          ),
        ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
      ],
    );
  }

  Widget _buildPlayerScores(BuildContext context) {
    final gp = context.watch<GameProvider>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ScoreBadge(
          label: 'Player 1',
          score: gp.player1Wins,
          color: AppTheme.player1Color,
        ),
        const SizedBox(width: 24),
        const Text('VS', style: TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 4)),
        const SizedBox(width: 24),
        _ScoreBadge(
          label: 'Player 2',
          score: gp.player2Wins,
          color: AppTheme.player2Color,
        ),
      ],
    ).animate().fadeIn(delay: 400.ms, duration: 500.ms);
  }

  Widget _buildMenuButtons(BuildContext context) {
    return Column(
      children: [
        _MenuButton(
          label: '2 PLAYERS',
          icon: Icons.people,
          color: AppTheme.neonBlue,
          onTap: () => _startGame(context, GameMode.twoPlayer, PlayerType.human),
          delay: 500,
        ),
        const SizedBox(height: 12),
        _MenuButton(
          label: 'VS AI — EASY',
          icon: Icons.android,
          color: AppTheme.neonGreen,
          onTap: () => _startGame(context, GameMode.vsAI, PlayerType.aiEasy),
          delay: 600,
        ),
        const SizedBox(height: 12),
        _MenuButton(
          label: 'VS AI — MEDIUM',
          icon: Icons.android,
          color: AppTheme.neonYellow,
          onTap: () => _startGame(context, GameMode.vsAI, PlayerType.aiMedium),
          delay: 700,
        ),
        const SizedBox(height: 12),
        _MenuButton(
          label: 'VS AI — HARD',
          icon: Icons.android,
          color: AppTheme.neonPink,
          onTap: () => _startGame(context, GameMode.vsAI, PlayerType.aiHard),
          delay: 800,
        ),
        const SizedBox(height: 24),
        _MenuButton(
          label: 'SETTINGS',
          icon: Icons.settings,
          color: Colors.white38,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
          delay: 900,
          outlined: true,
        ),
      ],
    );
  }

  void _startGame(BuildContext context, GameMode mode, PlayerType p2type) {
    final settings = context.read<SettingsProvider>();
    context.read<GameProvider>().startGame(
      mode: mode,
      gridSize: settings.gridSize,
      specialTiles: settings.specialTilesEnabled,
      player2Type: p2type,
    );
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const GameScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildFooter() {
    return Text(
      'Strategy · Speed · Color',
      style: TextStyle(
        color: Colors.white.withOpacity(0.2),
        fontSize: 11,
        letterSpacing: 3,
      ),
    ).animate().fadeIn(delay: 1000.ms);
  }
}

class _ScoreBadge extends StatelessWidget {
  final String label;
  final int score;
  final Color color;

  const _ScoreBadge({
    required this.label,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$score',
          style: TextStyle(
            color: color,
            fontSize: 32,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.6),
            fontSize: 11,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int delay;
  final bool outlined;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.delay = 0,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : color.withOpacity(0.1),
          border: Border.all(
            color: outlined ? Colors.white24 : color.withOpacity(0.5),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: outlined ? Colors.white38 : color, size: 20),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: outlined ? Colors.white54 : color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms)
        .slideX(begin: 0.2);
  }
}
