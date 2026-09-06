import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../models/tile_color.dart';
import 'dart:math';

class ColorGeneratorWidget extends StatefulWidget {
  const ColorGeneratorWidget({super.key});

  @override
  State<ColorGeneratorWidget> createState() => _ColorGeneratorWidgetState();
}

class _ColorGeneratorWidgetState extends State<ColorGeneratorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinCtrl;

  int _currentColorIndex = 0;
  Timer? _spinTimer;

  final List<TileColor> _allColors = TileColor.values;

  bool _isVisible = true;
  bool _wasSpinning = false;

  @override
  void initState() {
    super.initState();

    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      upperBound: 2 * pi,
    )..addListener(() {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    _spinTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    /// ✅ Detect when spin JUST finished
    if (_wasSpinning && !gameState.isSpinning) {
      // Show result briefly (1 frame), then hide
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isVisible = false;
          });
        }
      });
    }

    _wasSpinning = gameState.isSpinning;

    /// ✅ Handle spinning
    if (gameState.isSpinning) {
      if (!_spinCtrl.isAnimating) {
        _spinCtrl.repeat();

        // 🔥 Make sure it's visible again when spinning starts
        _isVisible = true;

        _spinTimer?.cancel();
        _spinTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
          if (mounted && gameState.isSpinning) {
            setState(() {
              _currentColorIndex = (_currentColorIndex + 1) % _allColors.length;
            });
          }
        });
      }
    } else {
      if (_spinCtrl.isAnimating) {
        _spinCtrl.stop();
        _spinTimer?.cancel();
        _spinTimer = null;
      }

      if (gameState.lastSpunColor != null) {
        _currentColorIndex = _allColors.indexOf(gameState.lastSpunColor!);
      }
    }

    /// ✅ If hidden → don't render at all (better than opacity)
    if (!_isVisible) {
      return const SizedBox.shrink();
    }

    /// Display logic
    Color displayColor;
    String displayLabel;

    if (gameState.isSpinning) {
      final spinningColor = _allColors[_currentColorIndex];
      displayColor = spinningColor.color;
      displayLabel = spinningColor.label[0];
    } else if (gameState.lastSpunColor != null) {
      displayColor = gameState.lastSpunColor!.color;
      displayLabel = gameState.lastSpunColor!.label[0];
    } else {
      displayColor = Colors.white24;
      displayLabel = '?';
    }

    final angle = gameState.isSpinning ? _spinCtrl.value : 0.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 100,
      height: 100,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          decoration: BoxDecoration(
            gradient: gameState.isSpinning
                ? SweepGradient(
                    colors: _allColors.map((c) => c.color).toList(),
                    stops: const [
                      0.0,
                      0.142,
                      0.284,
                      0.426,
                      0.568,
                      0.71,
                      0.852,
                      1.0,
                    ],
                  )
                : null,
            color: !gameState.isSpinning ? displayColor : null,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: displayColor.withOpacity(0.5),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: gameState.isSpinning
                ? const Icon(Icons.sync, color: Colors.white, size: 40)
                : Text(
                    displayLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 3,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
