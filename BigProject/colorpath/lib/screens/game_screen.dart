// screens/game_screen.dart - remove the old AbilityPanel import since we're using central overlay

import 'package:colorpath/models/tile_color.dart';
import 'package:colorpath/widgets/ability_panel.dart';
import 'package:colorpath/widgets/color_generator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/ability.dart';
import '../models/character.dart';
import '../models/game_state.dart';
import '../widgets/board_widget.dart';
import 'character_select_screen.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    if (gameState.phase == 'select') {
      return const CharacterSelectScreen();
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  flex: 2,
                  child: RotatedBox(
                    quarterTurns: 2,
                    child: PlayerHub(
                      playerNumber: 2,
                      character: gameState.p2Character,
                      isActive: gameState.currentPlayer == 2 &&
                          gameState.winner == null,
                    ),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const GameBoardWidget(),
                      Positioned(
                        top: 20,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(60),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const ColorGeneratorWidget(),
                        ),
                      ),
                      if (gameState.winner != null)
                        _WinnerOverlay(
                          winner: gameState.winner!,
                          character: gameState.winner == 1
                              ? gameState.p1Character
                              : gameState.p2Character,
                        ),
                      if (gameState.abilityBeingAnimated != null)
                        _AbilityAnimationOverlay(
                          ability: gameState.abilityBeingAnimated!,
                          character: gameState.currentCharacter,
                        ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: PlayerHub(
                    playerNumber: 1,
                    character: gameState.p1Character,
                    isActive: gameState.currentPlayer == 1 &&
                        gameState.winner == null,
                  ),
                ),
              ],
            ),
            // Central overlay for steal picker
            if (gameState.abilitySubPhase ==
                    AbilitySubPhase.stealChooseAbility &&
                gameState.stealableAbilities.isNotEmpty)
              _CentralStealPicker(abilities: gameState.stealableAbilities),
            // Central overlay for bicycle kick color picker
            if (gameState.abilitySubPhase ==
                AbilitySubPhase.bicycleKickChooseColor)
              _CentralBicycleKickColorPicker(),
          ],
        ),
      ),
    );
  }
}

// Central steal picker overlay
class _CentralStealPicker extends StatelessWidget {
  final List<Ability> abilities;

  const _CentralStealPicker({required this.abilities});

  @override
  Widget build(BuildContext context) {
    final gameState = context.read<GameState>();

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFCC44FF),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🎭 STEAL ABILITY',
                style: GoogleFonts.orbitron(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFCC44FF),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose an ability to steal from your opponent',
                style: GoogleFonts.rubik(
                  fontSize: 12,
                  color: Colors.white54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ...abilities.map((ability) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      // screens/game_screen.dart - update _CentralStealPicker onTap

                      onTap: () {
                        // First close the dialog
                        Navigator.of(context).pop();
                        // Then execute the steal after a short delay to avoid conflicts
                        Future.delayed(const Duration(milliseconds: 50), () {
                          gameState.selectStealAbility(ability);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFCC44FF).withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFCC44FF).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                ability.icon,
                                color: const Color(0xFFCC44FF),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ability.name,
                                    style: GoogleFonts.orbitron(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    ability.description,
                                    style: GoogleFonts.rubik(
                                      fontSize: 10,
                                      color: Colors.white54,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD700).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${ability.remainingUses}',
                                style: GoogleFonts.rubik(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFFFD700),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  gameState.abilitySubPhase = AbilitySubPhase.none;
                  gameState.activeAbility = null;
                  gameState.stealableAbilities = [];
                  gameState.resetAbilityUsedThisTurn(); // ← USE THIS
                  gameState.notifyListeners();
                },
                child: Text(
                  'Cancel',
                  style: GoogleFonts.rubik(
                    fontSize: 12,
                    color: Colors.white38,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Central bicycle kick color picker
class _CentralBicycleKickColorPicker extends StatelessWidget {
  const _CentralBicycleKickColorPicker();

  @override
  Widget build(BuildContext context) {
    final gameState = context.read<GameState>();

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFFFD700),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '⚽ BICYCLE KICK',
                style: GoogleFonts.orbitron(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFFFD700),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a color to target',
                style: GoogleFonts.rubik(
                  fontSize: 12,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: TileColor.values.map((color) {
                  return GestureDetector(
                    onTap: () {
                      gameState.selectBicycleKickColor(color);
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color.color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: color.color.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          color.label[0],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(offset: Offset(1, 1), blurRadius: 2),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  gameState.abilitySubPhase = AbilitySubPhase.none;
                  gameState.activeAbility = null;
                  gameState.bicycleKickChosenColor = null;
                  gameState.resetAbilityUsedThisTurn(); // ← USE THIS
                  gameState.notifyListeners();
                },
                child: Text(
                  'Cancel',
                  style: GoogleFonts.rubik(
                    fontSize: 12,
                    color: Colors.white38,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Winner overlay widget
class _WinnerOverlay extends StatelessWidget {
  final int winner;
  final GameCharacter? character;

  const _WinnerOverlay({required this.winner, this.character});

  @override
  Widget build(BuildContext context) {
    final gs = context.read<GameState>();

    GameCharacter? recentUnlock;
    if (winner == 1) {
      final unlockedIds = gs.p1UnlockedCharacters.toList();
      for (final id in kUnlockOrder.reversed) {
        if (unlockedIds.contains(id)) {
          recentUnlock = kAllCharacters.firstWhere((c) => c.id == id);
          break;
        }
      }
    } else {
      final unlockedIds = gs.p2UnlockedCharacters.toList();
      for (final id in kUnlockOrder.reversed) {
        if (unlockedIds.contains(id)) {
          recentUnlock = kAllCharacters.firstWhere((c) => c.id == id);
          break;
        }
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD700), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🏆', style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 6),
          Text(
            '${character?.name ?? 'PLAYER $winner'} WINS!',
            style: GoogleFonts.orbitron(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFFFD700),
              letterSpacing: 2,
            ),
          ),
          if (recentUnlock != null && !recentUnlock.startsUnlocked) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFFFD700).withOpacity(0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '🏆',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'UNLOCKED: ${recentUnlock.name}',
                        style: GoogleFonts.orbitron(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFFD700),
                        ),
                      ),
                      Text(
                        recentUnlock.subtitle,
                        style: GoogleFonts.rubik(
                          fontSize: 10,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () => context.read<GameState>().restartGame(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  'PLAY AGAIN',
                  style: GoogleFonts.orbitron(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PlayerHub extends StatelessWidget {
  final int playerNumber;
  final GameCharacter? character;
  final bool isActive;

  const PlayerHub({
    super.key,
    required this.playerNumber,
    required this.character,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final hasPendingChoice = gameState.pendingChoices.isNotEmpty &&
        gameState.currentPlayer == playerNumber;

    final isStealPhase =
        gameState.abilitySubPhase == AbilitySubPhase.stealChooseAbility;
    final isBicyclePhase =
        gameState.abilitySubPhase == AbilitySubPhase.bicycleKickChooseColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withOpacity(0.07) : Colors.transparent,
        border: isActive
            ? Border(
                bottom: BorderSide(
                  color: playerNumber == 1
                      ? const Color(0xFF4BACFF).withOpacity(0.4)
                      : const Color(0xFFFF4B4B).withOpacity(0.4),
                ),
              )
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                  border: Border.all(
                    color: isActive
                        ? (playerNumber == 1
                            ? const Color(0xFF4BACFF)
                            : const Color(0xFFFF4B4B))
                        : Colors.white12,
                    width: isActive ? 2 : 1,
                  ),
                  image: character != null
                      ? DecorationImage(
                          image: AssetImage(character!.imagePath),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {
                            debugPrint(
                                'Error loading character image: ${character!.imagePath}');
                          },
                        )
                      : null,
                ),
                child: character == null
                    ? Center(
                        child: Text(
                          playerNumber == 1 ? '▶' : '◀',
                          style: const TextStyle(fontSize: 20),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character?.name ?? 'Player $playerNumber',
                      style: GoogleFonts.orbitron(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isActive ? Colors.white : Colors.white38,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            character?.subtitle ?? '',
                            style: GoogleFonts.rubik(
                              fontSize: 10,
                              color: Colors.white24,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '🏆 ${playerNumber == 1 ? gameState.p1Wins : gameState.p2Wins}',
                            style: GoogleFonts.rubik(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFFD700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isActive &&
                  !hasPendingChoice &&
                  gameState.activeAbility == null &&
                  !isStealPhase &&
                  !isBicyclePhase)
                ElevatedButton(
                  onPressed: (gameState.isSpinning ||
                          gameState.winner != null ||
                          gameState.activeAbility != null)
                      ? null
                      : () => context.read<GameState>().spinColor(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 10,
                    ),
                    backgroundColor: gameState.doubleMovePendingSecondRoll
                        ? const Color(0xFFFFD700)
                        : Colors.white,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.white12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    gameState.isSpinning
                        ? 'Spinning...'
                        : gameState.doubleMovePendingSecondRoll
                            ? '⚡ ROLL x2'
                            : 'ROLL',
                    style: GoogleFonts.orbitron(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else if (gameState.activeAbility != null && isActive)
                Text(
                  '🎯 Tap a highlighted tile!',
                  style: GoogleFonts.rubik(
                      fontSize: 12, color: const Color(0xFFCC44FF)),
                )
              else if (hasPendingChoice)
                Text(
                  '🎯 Tap a tile!',
                  style: GoogleFonts.rubik(fontSize: 12, color: Colors.white54),
                )
              else if (!isActive)
                Text(
                  'Waiting...',
                  style: GoogleFonts.rubik(fontSize: 12, color: Colors.white24),
                ),
            ],
          ),
          if (isActive &&
              !hasPendingChoice &&
              gameState.activeAbility == null &&
              !isStealPhase &&
              !isBicyclePhase) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AbilityPanel(isActive: isActive),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AbilityAnimationOverlay extends StatefulWidget {
  final Ability ability;
  final GameCharacter? character;

  const _AbilityAnimationOverlay({
    required this.ability,
    required this.character,
  });

  @override
  State<_AbilityAnimationOverlay> createState() =>
      _AbilityAnimationOverlayState();
}

class _AbilityAnimationOverlayState extends State<_AbilityAnimationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      alignment: Alignment.center,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFCC44FF),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFCC44FF).withOpacity(0.6),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.ability.icon,
                      size: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.ability.name.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.orbitron(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: const Color(0xFFCC44FF).withOpacity(0.8),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    if (widget.character != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${widget.character!.name} casts ability!',
                        style: GoogleFonts.rubik(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFCC44FF),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
