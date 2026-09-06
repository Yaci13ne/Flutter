// widgets/board_widget.dart
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:colorpath/maze_node.dart';
import 'package:colorpath/models/character.dart';
import 'package:colorpath/models/tile_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_state.dart';
import 'color_generator.dart';

class GameBoardWidget extends StatefulWidget {
  const GameBoardWidget({super.key});

  @override
  State<GameBoardWidget> createState() => _GameBoardWidgetState();
}

class _GameBoardWidgetState extends State<GameBoardWidget> {
  int? _hoveredNodeId;
  final Map<String, ui.Image> _cachedImages = {};

  Future<ui.Image?> _loadImage(String path, double size) async {
    if (_cachedImages.containsKey(path)) {
      return _cachedImages[path];
    }

    try {
      final ByteData data = await rootBundle.load(path);
      final Uint8List bytes = data.buffer.asUint8List();
      final Completer<ui.Image> completer = Completer();

      ui.decodeImageFromList(bytes, (ui.Image img) {
        _cachedImages[path] = img;
        completer.complete(img);
      });

      return await completer.future;
    } catch (e) {
      debugPrint('Error loading image: $path - $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gameState = context.watch<GameState>();
        return MouseRegion(
          onHover: (event) {
            if (gameState.winner != null || gameState.isSpinning) {
              if (_hoveredNodeId != null) {
                gameState.clearPreviewPath();
                _hoveredNodeId = null;
              }
              return;
            }

            // Allow hover preview for both normal pending choices AND active ability highlights
            final hasHighlights = gameState.pendingChoices.isNotEmpty ||
                (gameState.activeAbility != null &&
                    gameState.highlightedNodes.isNotEmpty);
            if (!hasHighlights) {
              if (_hoveredNodeId != null) {
                gameState.clearPreviewPath();
                _hoveredNodeId = null;
              }
              return;
            }

            final size = Size(constraints.maxWidth, constraints.maxHeight);
            final mousePosition = event.localPosition;

            MazeNode? hoveredNode;
            double minDistance = 35.0;

            for (final node in gameState.maze) {
              final nodePos = Offset(node.x * size.width, node.y * size.height);
              final distance = (mousePosition - nodePos).distance;

              if (distance < minDistance) {
                minDistance = distance;
                hoveredNode = node;
              }
            }

            if (hoveredNode != null &&
                gameState.highlightedNodes.contains(hoveredNode.id)) {
              if (_hoveredNodeId != hoveredNode.id) {
                _hoveredNodeId = hoveredNode.id;
                // Only show path preview for pending choices, not ability jumps
                if (gameState.pendingChoices.isNotEmpty) {
                  gameState.setPreviewPath(hoveredNode.id);
                }
              }
            } else if (_hoveredNodeId != null) {
              gameState.clearPreviewPath();
              _hoveredNodeId = null;
            }
          },
          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: GestureDetector(
              onTapDown: (details) {
                if (gameState.winner != null || gameState.isSpinning) return;

                final size = Size(constraints.maxWidth, constraints.maxHeight);
                final tapPosition = details.localPosition;

                MazeNode? tappedNode;
                double minDistance = 50.0; // increased tap radius

                for (final node in gameState.maze) {
                  final nodePos = Offset(
                    node.x * size.width,
                    node.y * size.height,
                  );
                  final distance = (tapPosition - nodePos).distance;

                  if (distance < minDistance) {
                    minDistance = distance;
                    tappedNode = node;
                  }
                }

                // Handle ability moves — tap must be on a highlighted tile
                if (gameState.activeAbility != null && tappedNode != null) {
                  if (gameState.highlightedNodes.contains(tappedNode.id)) {
                    gameState.executeAbilityMove(tappedNode.id);
                  }
                  return;
                }

                // Normal pending choice move
                if (tappedNode != null &&
                    gameState.highlightedNodes.contains(tappedNode.id) &&
                    gameState.pendingChoices.isNotEmpty) {
                  _animateMovementAlongPath(context, gameState, tappedNode.id);
                }
              },
              child: CustomPaint(
                painter: BoardPainter(
                  gameState: gameState,
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  hoveredNodeId: _hoveredNodeId,
                  loadImage: _loadImage,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _animateMovementAlongPath(
    BuildContext context,
    GameState gameState,
    int targetNodeId,
  ) async {
    final startId =
        gameState.currentPosition < 0 ? 0 : gameState.currentPosition;
    final path = gameState.findShortestPath(startId, targetNodeId);

    if (path.length <= 1) {
      // Just move directly
      gameState.chooseMoveOption(targetNodeId);
      return;
    }

    // Bug 12 fix: use proper method instead of direct mutation
    gameState.setPreviewPath(targetNodeId);

    await Future.delayed(const Duration(milliseconds: 500));

    // Animate step by step
    for (int i = 1; i < path.length; i++) {
      final nextNodeId = path[i];

      // Update position step by step
      gameState.updatePositionDuringAnimation(nextNodeId);

      // Small delay between steps
      await Future.delayed(const Duration(milliseconds: 200));

      // Check if we reached a finish tile during animation
      final node = gameState.maze[nextNodeId];
      if (node.isFinish) {
        // Finish reached during animation - end the game
        gameState.clearPreviewPath();
        gameState.completeMoveAnimation(targetNodeId);
        return;
      }
    }

    // Clear preview and complete the move
    gameState.clearPreviewPath();
    gameState.completeMoveAnimation(targetNodeId);
  }
}

// ── Board painter ─────────────────────────────────────────────────────────────

class BoardPainter extends CustomPainter {
  final GameState gameState;
  final Size size;
  final int? hoveredNodeId;
  final Future<ui.Image?> Function(String, double)? loadImage;

  BoardPainter({
    required this.gameState,
    required this.size,
    this.hoveredNodeId,
    this.loadImage,
  });

  Offset _pos(MazeNode node) =>
      Offset(node.x * size.width, node.y * size.height);

  @override
  void paint(Canvas canvas, Size size) {
    final maze = gameState.maze;
    if (maze.isEmpty) return;

    // Draw path preview first (so it's underneath nodes)
    _drawPathPreview(canvas, maze);
    _drawEdges(canvas, maze);
    _drawNodes(canvas, maze);
    _drawPlayers(canvas, maze);

    // Draw instruction overlay when choices are available
    if (gameState.pendingChoices.isNotEmpty && gameState.winner == null) {
      _drawInstructionOverlay(canvas);
    }
  }

  void _drawPathPreview(Canvas canvas, List<MazeNode> maze) {
    if (gameState.previewPath == null || gameState.previewPath!.length < 2)
      return;

    final path = gameState.previewPath!;
    final paint = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.8)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw the path edges
    for (int i = 0; i < path.length - 1; i++) {
      final fromNode = maze[path[i]];
      final toNode = maze[path[i + 1]];
      canvas.drawLine(_pos(fromNode), _pos(toNode), paint);
    }

    // Draw direction arrows along the path
    for (int i = 0; i < path.length - 1; i++) {
      final fromNode = maze[path[i]];
      final toNode = maze[path[i + 1]];
      final fromPos = _pos(fromNode);
      final toPos = _pos(toNode);

      // Draw arrow at midpoint
      final midPoint = Offset(
        (fromPos.dx + toPos.dx) / 2,
        (fromPos.dy + toPos.dy) / 2,
      );

      final angle = atan2(toPos.dy - fromPos.dy, toPos.dx - fromPos.dx);

      final arrowPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      final arrowPath = Path();
      final arrowSize = 8.0;
      final arrowPoint = Offset(
        midPoint.dx + cos(angle) * 10,
        midPoint.dy + sin(angle) * 10,
      );

      arrowPath.moveTo(arrowPoint.dx, arrowPoint.dy);
      arrowPath.lineTo(
        arrowPoint.dx - arrowSize * cos(angle - pi / 6),
        arrowPoint.dy - arrowSize * sin(angle - pi / 6),
      );
      arrowPath.lineTo(
        arrowPoint.dx - arrowSize * cos(angle + pi / 6),
        arrowPoint.dy - arrowSize * sin(angle + pi / 6),
      );
      arrowPath.close();

      canvas.drawPath(arrowPath, arrowPaint);
    }
  }

  void _drawEdges(Canvas canvas, List<MazeNode> maze) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final drawn = <String>{};
    for (final node in maze) {
      for (final nid in node.neighbours) {
        final key = node.id < nid ? '${node.id}-$nid' : '$nid-${node.id}';
        if (drawn.contains(key)) continue;
        drawn.add(key);
        final neighbour = maze[nid];
        final isHighlightedEdge =
            gameState.highlightedNodes.contains(node.id) ||
                gameState.highlightedNodes.contains(nid);
        canvas.drawLine(
          _pos(node),
          _pos(neighbour),
          isHighlightedEdge ? highlightPaint : paint,
        );
      }
    }
  }

  void _drawNodes(Canvas canvas, List<MazeNode> maze) {
    for (final node in maze) {
      final pos = _pos(node);
      final isHighlighted = gameState.highlightedNodes.contains(node.id);
      final isValidMove = gameState.pendingChoices.isNotEmpty &&
          gameState.highlightedNodes.contains(node.id);
      final isAbilityTarget = gameState.activeAbility != null &&
          gameState.highlightedNodes.contains(node.id);
      final isInPreviewPath = gameState.previewPath?.contains(node.id) ?? false;

      // Find distance info for this node if it's a valid move
      MoveOption? moveOption;
      if (isValidMove) {
        for (final opt in gameState.pendingChoices) {
          if (opt.nodeId == node.id) {
            moveOption = opt;
            break;
          }
        }
      }

      if (node.isStart) {
        _drawStartNode(canvas, pos, isInPreviewPath);
        continue;
      }

      if (node.isFinish) {
        _drawFinishNode(canvas, pos, isValidMove, moveOption, isInPreviewPath);
        continue;
      }

      final tileColor = node.color!.color;
      final radius = 18.0;

      // Draw WHITE CIRCLE for valid moves (closest tiles)
      if (isValidMove) {
        final pulseIntensity = 0.7 + (DateTime.now().millisecond / 1000) * 0.3;

        canvas.drawCircle(
          pos,
          radius + 10,
          Paint()
            ..color = Colors.white.withOpacity(pulseIntensity * 0.8)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4,
        );

        canvas.drawCircle(
          pos,
          radius + 6,
          Paint()
            ..color = Colors.white.withOpacity(0.4)
            ..style = PaintingStyle.fill,
        );

        canvas.drawCircle(
          pos,
          radius + 2,
          Paint()
            ..color = Colors.white.withOpacity(0.3)
            ..style = PaintingStyle.fill,
        );
      }

      // Draw PURPLE/MAGENTA ring for ability target tiles
      if (isAbilityTarget && !isValidMove) {
        final pulseIntensity = 0.6 + (DateTime.now().millisecond / 1000) * 0.4;
        canvas.drawCircle(
          pos,
          radius + 8,
          Paint()
            ..color = const Color(0xFFCC44FF).withOpacity(pulseIntensity * 0.7)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
        canvas.drawCircle(
          pos,
          radius + 4,
          Paint()
            ..color = const Color(0xFFCC44FF).withOpacity(0.25)
            ..style = PaintingStyle.fill,
        );
      }

      // Add glow for nodes in preview path
      if (isInPreviewPath && !isValidMove) {
        canvas.drawCircle(
          pos,
          radius + 4,
          Paint()
            ..color = const Color(0xFFFFD700).withOpacity(0.3)
            ..style = PaintingStyle.fill,
        );
      }

      // Draw the tile itself
      canvas.drawCircle(
        pos,
        radius,
        Paint()
          ..color = tileColor
          ..style = PaintingStyle.fill,
      );

      // Border
      canvas.drawCircle(
        pos,
        radius,
        Paint()
          ..color = Colors.white.withOpacity(isHighlighted ? 0.95 : 0.5)
          ..strokeWidth = isHighlighted ? 2.5 : 1.5
          ..style = PaintingStyle.stroke,
      );

      // Add step indicator for valid move tiles
      if (isValidMove && moveOption != null) {
        final steps = moveOption.steps;
        final stepText =
            steps == 0 ? '★' : '$steps step${steps != 1 ? 's' : ''}';
        final textPainter = TextPainter(
          text: TextSpan(
            text: stepText,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [Shadow(offset: Offset(1, 1), blurRadius: 2)],
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(pos.dx - textPainter.width / 2, pos.dy - radius - 12),
        );
      }
    }
  }

  void _drawStartNode(Canvas canvas, Offset pos, bool isInPreviewPath) {
    final radius = 20.0;

    if (isInPreviewPath) {
      canvas.drawCircle(
        pos,
        radius + 4,
        Paint()
          ..color = const Color(0xFFFFD700).withOpacity(0.3)
          ..style = PaintingStyle.fill,
      );
    }

    canvas.drawCircle(
      pos,
      radius + 5,
      Paint()..color = Colors.white.withOpacity(0.18),
    );
    canvas.drawCircle(pos, radius, Paint()..color = Colors.white24);
    canvas.drawCircle(
      pos,
      radius,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );

    final tp = TextPainter(
      text: const TextSpan(
        text: '▶',
        style: TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawFinishNode(
    Canvas canvas,
    Offset pos,
    bool isValidMove,
    MoveOption? moveOption,
    bool isInPreviewPath,
  ) {
    final radius = 28.0;
    final baseColor = const Color(0xFFFFD700);

    if (isInPreviewPath) {
      canvas.drawCircle(
        pos,
        radius + 8,
        Paint()
          ..color = baseColor.withOpacity(0.4)
          ..style = PaintingStyle.fill,
      );
    }

    if (isValidMove) {
      final pulseIntensity = 0.6 + (DateTime.now().millisecond / 1000) * 0.4;

      canvas.drawCircle(
        pos,
        radius + 12,
        Paint()
          ..color = Colors.white.withOpacity(pulseIntensity * 0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5,
      );

      canvas.drawCircle(
        pos,
        radius + 8,
        Paint()
          ..color = Colors.white.withOpacity(0.4)
          ..style = PaintingStyle.fill,
      );

      canvas.drawCircle(
        pos,
        radius + 4,
        Paint()
          ..color = baseColor.withOpacity(0.5)
          ..style = PaintingStyle.fill,
      );
    }

    canvas.drawCircle(
      pos,
      radius,
      Paint()
        ..color = baseColor
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      pos,
      radius,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );

    final tp = TextPainter(
      text: const TextSpan(
        text: '👑',
        style: TextStyle(fontSize: 28, color: Colors.black),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));

    if (isValidMove && moveOption != null) {
      final steps = moveOption.steps;
      final stepText = '$steps step${steps != 1 ? 's' : ''} to goal';
      final textPainter = TextPainter(
        text: TextSpan(
          text: stepText,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(offset: Offset(1, 1), blurRadius: 2)],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(pos.dx - textPainter.width / 2, pos.dy + radius + 8),
      );
    }
  }

  void _drawInstructionOverlay(Canvas canvas) {
    final center = Offset(size.width / 2, size.height / 2);
    final text = TextPainter(
      text: TextSpan(
        text: '✨ HOVER OVER TILES TO SEE PATH - CLICK TO MOVE ✨',
        style: GoogleFonts.rubik(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(offset: Offset(1, 1), blurRadius: 3, color: Colors.black),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final bgRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy - 100),
      width: text.width + 40,
      height: text.height + 20,
    );
    canvas.drawRect(
      bgRect,
      Paint()
        ..color = Colors.black.withOpacity(0.7)
        ..style = PaintingStyle.fill,
    );

    text.paint(canvas, Offset(center.dx - text.width / 2, center.dy - 110));
  }

  void _drawPlayers(Canvas canvas, List<MazeNode> maze) {
    if (gameState.p1Cloned) {
      for (final clonePos in gameState.p1CloneLocations) {
        _drawPlayerToken(
          canvas,
          maze,
          clonePos,
          const Color(0xFF4BACFF),
          gameState.p1Character,
          offsetDir: const Offset(-11, -11),
        );
      }
    }
    _drawPlayerToken(
      canvas,
      maze,
      gameState.p1Position,
      const Color(0xFF4BACFF),
      gameState.p1Character,
      offsetDir: const Offset(-11, -11),
    );

    if (gameState.p2Cloned) {
      for (final clonePos in gameState.p2CloneLocations) {
        _drawPlayerToken(
          canvas,
          maze,
          clonePos,
          const Color(0xFFFF4B4B),
          gameState.p2Character,
          offsetDir: const Offset(11, 11),
        );
      }
    }
    _drawPlayerToken(
      canvas,
      maze,
      gameState.p2Position,
      const Color(0xFFFF4B4B),
      gameState.p2Character,
      offsetDir: const Offset(11, 11),
    );
  }

  void _drawPlayerToken(
    Canvas canvas,
    List<MazeNode> maze,
    int positionId,
    Color tokenColor,
    GameCharacter? character, {
    required Offset offsetDir,
  }) {
    Offset base;
    if (positionId < 0) {
      final startNode = maze.firstWhere((n) => n.isStart);
      base = _pos(startNode) + const Offset(0, 28);
    } else {
      base = _pos(maze[positionId]);
    }

    final pos = base + offsetDir;
    const radius = 20.0;

    // Draw background circle with glow
    canvas.drawCircle(
      pos,
      radius + 4,
      Paint()..color = tokenColor.withOpacity(0.25),
    );

    // Draw white background circle
    canvas.drawCircle(pos, radius, Paint()..color = Colors.white);

    // Draw border
    canvas.drawCircle(
      pos,
      radius,
      Paint()
        ..color = tokenColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );

    // Draw character image from preloaded cache
    if (character != null) {
      final ui.Image? image = gameState.characterImages[character.id];
      if (image != null) {
        try {
          // Save canvas state
          canvas.save();

          // Create circular clip path
          final Path clipPath = Path()
            ..addOval(Rect.fromCircle(center: pos, radius: radius - 2));
          canvas.clipPath(clipPath);

          // Calculate source and destination rectangles
          final srcRect = Rect.fromLTWH(
              0, 0, image.width.toDouble(), image.height.toDouble());
          final dstRect = Rect.fromCircle(center: pos, radius: radius - 2);

          // Draw the image
          canvas.drawImageRect(image, srcRect, dstRect, Paint());

          // Restore canvas state
          canvas.restore();
        } catch (e) {
          debugPrint('Error drawing image: $e');
          _drawEmojiFallback(canvas, pos, radius, character.imagePath);
        }
      } else {
        _drawEmojiFallback(canvas, pos, radius, character.imagePath);
      }
    }
  }

  void _drawEmojiFallback(
      Canvas canvas, Offset pos, double radius, String emoji) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(pos.dx - textPainter.width / 2, pos.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant BoardPainter old) =>
      old.gameState != gameState ||
      old.hoveredNodeId != hoveredNodeId ||
      old.gameState.activeAbility != gameState.activeAbility ||
      old.gameState.highlightedNodes != gameState.highlightedNodes;
}
