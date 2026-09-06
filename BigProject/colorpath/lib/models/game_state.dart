// models/game_state.dart
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:colorpath/models/ability.dart';
import 'package:colorpath/models/character_abilities.dart';
import 'package:flutter/services.dart';
import 'package:colorpath/maze_node.dart';
import 'package:colorpath/models/character.dart';
import 'package:flutter/material.dart';
import 'tile_color.dart';

/// Describes one reachable move option the current player can pick.
class MoveOption {
  final int nodeId;
  final int steps;
  final String directionHint;
  const MoveOption({
    required this.nodeId,
    required this.steps,
    required this.directionHint,
  });
}

/// Sub-phases used for multi-step abilities (steal, bicycle kick, etc.)
enum AbilitySubPhase {
  none,
  // mindControl / steal: choose which opponent ability to steal+use
  stealChooseAbility,
  // stealExecute: the stolen ability is now being resolved (pick a tile)
  stealExecute,
  // Ronaldo bicycle kick: first pick a color, then pick direction tiles
  bicycleKickChooseColor,
  bicycleKickChooseTile,
}

class GameState extends ChangeNotifier {
  late List<MazeNode> maze;

  Map<String, List<Ability>> p1Abilities = {};
  Map<String, List<Ability>> p2Abilities = {};

  // ── Character state ────────────────────────────────────────────────────────
  Set<String> p1UnlockedCharacters = {};
  Set<String> p2UnlockedCharacters = {};
  final Map<String, ui.Image> characterImages = {};

  Ability? activeAbility;
  Ability? abilityBeingAnimated;
  bool _abilityUsedThisTurn = false;
  Map<String, int> activeEffects = {};
  bool p1Frozen = false;
  bool p2Frozen = false;
  bool p1Shielded = false;
  bool p2Shielded = false;
  bool p1Cloned = false;
  bool p2Cloned = false;
  List<int> p1CloneLocations = [];
  List<int> p2CloneLocations = [];
  int cloneTurnsRemaining = 0;
  bool _doubleMoveActive = false;
  bool _doubleMovePendingSecondRoll = false;

  bool get doubleMovePendingSecondRoll => _doubleMovePendingSecondRoll;
  int p1Wins = 0;
  int p2Wins = 0;

  GameCharacter? p1Character;
  GameCharacter? p2Character;

  String phase = 'select';

  // ── Board state ────────────────────────────────────────────────────────────
  int p1Position = -1;
  int p2Position = -1;
  int currentPlayer = 1;
  int? winner;

  TileColor? lastSpunColor;
  bool isSpinning = false;

  Set<int> highlightedNodes = {};
  List<MoveOption> pendingChoices = [];
  String? stuckMessage;

  List<int>? previewPath;
  int? previewTargetNode;

  // ── Multi-step ability state ───────────────────────────────────────────────
  AbilitySubPhase abilitySubPhase = AbilitySubPhase.none;

  /// For steal: list of opponent abilities the player can choose from
  List<Ability> stealableAbilities = [];

  /// For steal: the stolen ability that will be executed next
  Ability? stolenAbility;

  /// For bicycle kick: the color chosen in phase 1
  TileColor? bicycleKickChosenColor;

  final Random _rnd = Random();

  GameState() {
    for (final c in kAllCharacters) {
      if (c.startsUnlocked) {
        p1UnlockedCharacters.add(c.id);
        p2UnlockedCharacters.add(c.id);
      }
    }
    _initBoard();
  }

  void initializeAbilities(GameCharacter character, int player) {
    final charAbilities = CharacterAbilities.forCharacter(character);
    if (charAbilities != null) {
      final abilitiesCopy = charAbilities.abilities
          .map((a) => Ability(
                id: a.id,
                name: a.name,
                description: a.description,
                type: a.type,
                icon: a.icon,
                maxUses: a.maxUses,
                remainingUses: a.remainingUses,
              ))
          .toList();

      if (player == 1) {
        p1Abilities[character.id] = abilitiesCopy;
      } else {
        p2Abilities[character.id] = abilitiesCopy;
      }
    }
  }

  // ── Character helpers ──────────────────────────────────────────────────────

  List<GameCharacter> getAvailableCharacters(int player) {
    final unlockedSet =
        player == 1 ? p1UnlockedCharacters : p2UnlockedCharacters;
    return kAllCharacters.where((c) => unlockedSet.contains(c.id)).toList();
  }

  List<GameCharacter> getLockedCharacters(int player) {
    final unlockedSet =
        player == 1 ? p1UnlockedCharacters : p2UnlockedCharacters;
    return kAllCharacters.where((c) => !unlockedSet.contains(c.id)).toList();
  }

  bool isUnlocked(int player, String id) {
    final unlockedSet =
        player == 1 ? p1UnlockedCharacters : p2UnlockedCharacters;
    return unlockedSet.contains(id);
  }

  void confirmCharacters(GameCharacter p1, GameCharacter p2) {
    p1Character = p1;
    p2Character = p2;
    initializeAbilities(p1, 1);
    initializeAbilities(p2, 2);
    phase = 'game';
    _initBoard();
    notifyListeners();
  }

  void goToCharacterSelect() {
    phase = 'select';
    p1Character = null;
    p2Character = null;
    notifyListeners();
  }

  List<Ability> getCurrentPlayerAbilities() {
    final character = currentCharacter;
    if (character == null) return [];

    if (currentPlayer == 1) {
      return p1Abilities[character.id] ?? [];
    } else {
      return p2Abilities[character.id] ?? [];
    }
  }

  bool canUseAbility(Ability ability) {
    if (winner != null) return false;
    if (abilityBeingAnimated != null) return false;
    if (currentPlayer == 1 && p1Frozen) return false;
    if (currentPlayer == 2 && p2Frozen) return false;
    if (ability.remainingUses <= 0) return false;
    if (_abilityUsedThisTurn) return false;
    if (abilitySubPhase != AbilitySubPhase.none) return false;
    return true;
  }

// models/game_state.dart - fix selectStealAbility
// models/game_state.dart - fix selectStealAbility

// models/game_state.dart - fix selectStealAbility
// models/game_state.dart - ensure _finishSteal is called correctly

  void selectStealAbility(Ability chosen) {
    if (abilitySubPhase != AbilitySubPhase.stealChooseAbility) return;

    // Find the original ability in opponent's list by ID
    final opponentAbilities = currentPlayer == 1
        ? p2Abilities[p2Character?.id ?? '']
        : p1Abilities[p1Character?.id ?? ''];

    Ability? originalAbility;
    if (opponentAbilities != null) {
      for (final ability in opponentAbilities) {
        if (ability.id == chosen.id) {
          originalAbility = ability;
          break;
        }
      }
    }

    if (originalAbility != null && originalAbility.remainingUses > 0) {
      originalAbility.use();
    }

    stolenAbility = chosen.copy();
    stolenAbility!.remainingUses = 1;

    stealableAbilities = [];
    abilitySubPhase = AbilitySubPhase.stealExecute;

    // Execute the stolen ability
    _executeStolenAbility(stolenAbility!);

    notifyListeners(); // Add this to ensure UI updates
  }

  void _executeStolenAbility(Ability ability) {
    switch (ability.type) {
      case AbilityType.teleportToColor:
        final currentPos = currentPlayer == 1 ? p1Position : p2Position;
        if (currentPos < 0 || maze[currentPos].isStart) {
          stuckMessage = 'Cannot teleport before moving to a colored tile!';
          _finishSteal();
          return;
        }
        final currentColor = maze[currentPos].color;
        highlightedNodes = maze
            .where((n) =>
                !n.isStart &&
                !n.isFinish &&
                n.color == currentColor &&
                n.id != currentPos)
            .map((n) => n.id)
            .toSet();
        if (highlightedNodes.isEmpty) {
          stuckMessage = 'No other tiles of this color to teleport to!';
          _finishSteal();
          return;
        }
        activeAbility = ability;
        stuckMessage =
            'Stolen: ${ability.name}! Tap a matching colored tile to teleport!';
        notifyListeners();
        return;

      case AbilityType.jumpAnywhere:
        activeAbility = ability;
        highlightedNodes = maze
            .where((n) => !n.isStart && !n.isFinish)
            .map((n) => n.id)
            .toSet();
        stuckMessage =
            'Stolen: ${ability.name}! Tap any non-finish tile to move there!';
        notifyListeners();
        return;

      case AbilityType.rainbowPath:
        activeAbility = ability;
        highlightedNodes = maze
            .where((n) => !n.isStart && !n.isFinish)
            .map((n) => n.id)
            .toSet();
        stuckMessage =
            'Stolen: ${ability.name}! Tap any non-finish tile to move there!';
        notifyListeners();
        return;

      case AbilityType.doubleMove:
        _doubleMoveActive = true;
        stuckMessage = 'Stolen: ${ability.name}! Double move — roll now!';
        _finishSteal();
        return;

      case AbilityType.freezeOpponent:
      case AbilityType.timeFreeze:
        final turns = ability.type == AbilityType.timeFreeze ? 2 : 1;
        if (currentPlayer == 1) {
          p2Frozen = true;
          activeEffects['freeze_2'] = turns;
        } else {
          p1Frozen = true;
          activeEffects['freeze_1'] = turns;
        }
        stuckMessage =
            'Stolen: ${ability.name}! Opponent frozen for $turns turn(s)!';
        _finishSteal();
        return;

      case AbilityType.powerShot:
        final opponentPos = currentPlayer == 1 ? p2Position : p1Position;
        if (opponentPos > 0) {
          final pushedPos = _pushTowardStart(opponentPos, 3);
          if (currentPlayer == 1) {
            p2Position = pushedPos;
          } else {
            p1Position = pushedPos;
          }
          stuckMessage = 'Stolen: ${ability.name}! Opponent pushed back!';
        } else {
          stuckMessage = 'Opponent is already at the start!';
        }
        _finishSteal();
        return;

      case AbilityType.swapPositions:
        if (p1Position >= 0 && p2Position >= 0) {
          final temp = p1Position;
          p1Position = p2Position;
          p2Position = temp;
          stuckMessage = 'Stolen: ${ability.name}! Positions swapped!';
        }
        _finishSteal();
        return;

      case AbilityType.speedBoost:
        if (currentPlayer == 1) {
          activeEffects['speed_1'] = 1;
        } else {
          activeEffects['speed_2'] = 1;
        }
        stuckMessage = 'Stolen: ${ability.name}! Speed boost — roll now!';
        _finishSteal();
        return;

      case AbilityType.forceField:
        if (currentPlayer == 1) {
          p1Shielded = true;
          activeEffects['shield_1'] = 3;
        } else {
          p2Shielded = true;
          activeEffects['shield_2'] = 3;
        }
        stuckMessage =
            'Stolen: ${ability.name}! Force field active for 3 turns!';
        _finishSteal();
        return;

      case AbilityType.shield:
        if (currentPlayer == 1) {
          p1Shielded = true;
          activeEffects['shield_1'] = 2;
        } else {
          p2Shielded = true;
          activeEffects['shield_2'] = 2;
        }
        stuckMessage = 'Stolen: ${ability.name}! Shield active for 2 turns!';
        _finishSteal();
        return;

      case AbilityType.clone:
        final currentPos = currentPlayer == 1 ? p1Position : p2Position;
        final availableNodes = maze
            .where((n) => !n.isStart && !n.isFinish && n.id != currentPos)
            .toList()
          ..shuffle(_rnd);
        final cloneNodes = availableNodes.take(4).map((n) => n.id).toList();
        if (currentPlayer == 1) {
          p1Cloned = true;
          p1CloneLocations = cloneNodes;
        } else {
          p2Cloned = true;
          p2CloneLocations = cloneNodes;
        }
        cloneTurnsRemaining = 2;
        stuckMessage = 'Stolen: ${ability.name}! Clones active for 2 turns!';
        _finishSteal();
        return;

      default:
        stuckMessage = 'Stolen: ${ability.name}! Effect applied!';
        _finishSteal();
        return;
    }
  }
// models/game_state.dart - add this method

  void resetAbilityUsedThisTurn() {
    _abilityUsedThisTurn = false;
    notifyListeners();
  }

  void _finishSteal() {
    abilitySubPhase = AbilitySubPhase.none;
    stolenAbility = null;
    activeAbility = null;
    notifyListeners(); // Ensure UI updates
  }

  /// Called when player taps a color swatch during bicycle-kick phase 1.
  void selectBicycleKickColor(TileColor color) {
    if (abilitySubPhase != AbilitySubPhase.bicycleKickChooseColor) return;

    bicycleKickChosenColor = color;

    // Find tiles of this color within exactly 1–3 hops from current position
    final currentPos = currentPlayer == 1 ? p1Position : p2Position;
    final startId = currentPos < 0 ? 0 : currentPos;
    final distances = _calculateDistancesFrom(startId);

    final reachable = maze
        .where((n) =>
            !n.isStart &&
            !n.isFinish &&
            n.color == color &&
            distances.containsKey(n.id) &&
            distances[n.id]! >= 1 &&
            distances[n.id]! <= 3)
        .map((n) => n.id)
        .toSet();

    if (reachable.isEmpty) {
      stuckMessage =
          '⚽ No ${color.label} tiles within 3 steps! Choose a different color.';
      // Stay in bicycleKickChooseColor so player can pick another color
      abilitySubPhase = AbilitySubPhase.bicycleKickChooseColor;
      bicycleKickChosenColor = null;
      notifyListeners();
      return;
    }

    highlightedNodes = reachable;
    abilitySubPhase = AbilitySubPhase.bicycleKickChooseTile;
    stuckMessage =
        '⚽ Bicycle Kick — tap a ${color.label} tile to land on (within 3 steps)!';
    notifyListeners();
  }

  // ── Main ability dispatcher ───────────────────────────────────────────────

  void useAbility(Ability ability) async {
    if (!canUseAbility(ability)) return;

    abilityBeingAnimated = ability;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 1500));
    abilityBeingAnimated = null;
    notifyListeners();

    // Determine if this is an opponent-affecting ability (attack)
    bool isAttack = ability.type == AbilityType.powerShot ||
        ability.type == AbilityType.freezeOpponent ||
        ability.type == AbilityType.timeFreeze ||
        ability.type == AbilityType.mindControl ||
        ability.type == AbilityType.swapPositions;

    // Check if opponent has shield
    bool isShielded = (currentPlayer == 1 && p2Shielded) ||
        (currentPlayer == 2 && p1Shielded);

    if (isShielded && isAttack) {
      stuckMessage =
          '${currentPlayer == 1 ? p2Character?.name : p1Character?.name}\'s shield blocked your attack!';
      notifyListeners();
      return;
    }

    // Check if opponent is cloned (dodging chance)
    bool isOpponentCloned =
        (currentPlayer == 1 && p2Cloned) || (currentPlayer == 2 && p1Cloned);

    if (isOpponentCloned && isAttack && _rnd.nextBool()) {
      stuckMessage = 'An illusion took the hit! Your attack missed!';
      ability.use();
      _abilityUsedThisTurn = true;
      notifyListeners();
      return;
    }

    _abilityUsedThisTurn = true;

    // ── Special bicycle-kick handling (CR7) ───────────────────────────────
    if (ability.id == 'cr7_bicycle') {
      abilitySubPhase = AbilitySubPhase.bicycleKickChooseColor;
      activeAbility = ability;
      ability.use();
      stuckMessage = 'Bicycle Kick — choose a color to target!';
      notifyListeners();
      return;
    }

    // ── Apply ability effect ──────────────────────────────────────────────
    switch (ability.type) {
      case AbilityType.teleportToColor:
        final currentPos = currentPlayer == 1 ? p1Position : p2Position;
        if (currentPos < 0 || maze[currentPos].isStart) {
          stuckMessage = 'Cannot teleport before moving to a colored tile!';
          _abilityUsedThisTurn = false;
          notifyListeners();
          return;
        }

        final currentColor = maze[currentPos].color;

        highlightedNodes = maze
            .where((n) =>
                !n.isStart &&
                !n.isFinish &&
                n.color == currentColor &&
                n.id != currentPos)
            .map((n) => n.id)
            .toSet();

        if (highlightedNodes.isEmpty) {
          stuckMessage = 'No other tiles of this color to teleport to!';
          _abilityUsedThisTurn = false;
          notifyListeners();
          return;
        }

        activeAbility = ability;
        stuckMessage = 'Tap a matching colored tile to teleport there!';
        ability.use();
        notifyListeners();
        return;

      case AbilityType.clone:
        final currentPos = currentPlayer == 1 ? p1Position : p2Position;
        if (currentPos < 0 || maze[currentPos].isStart) {
          stuckMessage = 'Cannot create clones on the Start tile!';
          _abilityUsedThisTurn = false;
          notifyListeners();
          return;
        }

        final availableNodes = maze
            .where((n) => !n.isStart && !n.isFinish && n.id != currentPos)
            .toList()
          ..shuffle(_rnd);

        final cloneNodes = availableNodes.take(4).map((n) => n.id).toList();

        if (currentPlayer == 1) {
          p1Cloned = true;
          p1CloneLocations = cloneNodes;
        } else {
          p2Cloned = true;
          p2CloneLocations = cloneNodes;
        }
        cloneTurnsRemaining = 2;
        stuckMessage =
            'Clones active! 50% chance to dodge attacks for 2 turns!';
        break;

      case AbilityType.jumpAnywhere:
        activeAbility = ability;
        highlightedNodes = maze
            .where((n) => !n.isStart && !n.isFinish)
            .map((n) => n.id)
            .toSet();
        stuckMessage = 'Tap any non-finish tile to jump there!';
        ability.use();
        notifyListeners();
        return;

      case AbilityType.doubleMove:
        _doubleMoveActive = true;
        stuckMessage = 'Double move! You get TWO rolls this turn — roll now!';
        ability.use();
        notifyListeners();
        return;

      case AbilityType.freezeOpponent:
        if (currentPlayer == 1) {
          p2Frozen = true;
          activeEffects['freeze_2'] = 1;
        } else {
          p1Frozen = true;
          activeEffects['freeze_1'] = 1;
        }
        stuckMessage = 'Opponent is frozen — they will skip their next turn!';
        break;

      case AbilityType.timeFreeze:
        if (currentPlayer == 1) {
          p2Frozen = true;
          activeEffects['freeze_2'] = 2;
        } else {
          p1Frozen = true;
          activeEffects['freeze_1'] = 2;
        }
        stuckMessage = 'Opponent is frozen for 2 turns!';
        break;

      case AbilityType.swapPositions:
        if (p1Position >= 0 && p2Position >= 0) {
          final temp = p1Position;
          p1Position = p2Position;
          p2Position = temp;
          stuckMessage = 'Positions swapped!';
        } else {
          stuckMessage = 'Cannot swap — a player hasn\'t started yet!';
        }
        break;

      case AbilityType.forceField:
        if (currentPlayer == 1) {
          p1Shielded = true;
          activeEffects['shield_1'] = 3;
        } else {
          p2Shielded = true;
          activeEffects['shield_2'] = 3;
        }
        stuckMessage = 'Force field active for 3 turns!';
        break;

      case AbilityType.shield:
        if (currentPlayer == 1) {
          p1Shielded = true;
          activeEffects['shield_1'] = 2;
        } else {
          p2Shielded = true;
          activeEffects['shield_2'] = 2;
        }
        stuckMessage = 'Shield active for 2 turns!';
        break;

      case AbilityType.speedBoost:
        if (currentPlayer == 1) {
          activeEffects['speed_1'] = 1;
        } else {
          activeEffects['speed_2'] = 1;
        }
        stuckMessage =
            'Speed boost! Your next move shows tiles +3 steps further!';
        ability.use();
        notifyListeners();
        return;

      // mindControl = Steal: show opponent's abilities and let player choose one to steal + use
      // Called when using mindControl
      case AbilityType.mindControl:
        final opponentAbilities = currentPlayer == 1
            ? p2Abilities[p2Character?.id ?? ''] ?? []
            : p1Abilities[p1Character?.id ?? ''] ?? [];

        final usable = opponentAbilities
            .where((a) => a.remainingUses > 0)
            .map((a) => a.copy())
            .toList();

        if (usable.isEmpty) {
          stuckMessage = 'Opponent has no ability uses left to steal!';
          _abilityUsedThisTurn = false;
          notifyListeners();
          return;
        }

        // Put these abilities in the middle selection panel
        stealableAbilities = usable;

        // Enter the sub-phase where player must choose one
        abilitySubPhase = AbilitySubPhase.stealChooseAbility;
        activeAbility = ability;
        ability.use();

        stuckMessage = 'STEAL — choose which opponent ability to steal!';
        notifyListeners();
        return;

      case AbilityType.rainbowPath:
        activeAbility = ability;
        highlightedNodes = maze
            .where((n) => !n.isStart && !n.isFinish)
            .map((n) => n.id)
            .toSet();
        stuckMessage =
            'Rainbow path! Tap any non-finish tile to move there ignoring colors!';
        ability.use();
        notifyListeners();
        return;

      case AbilityType.powerShot:
        final opponentPos = currentPlayer == 1 ? p2Position : p1Position;
        if (opponentPos > 0) {
          final pushedPos = _pushTowardStart(opponentPos, 3);
          if (currentPlayer == 1) {
            p2Position = pushedPos;
          } else {
            p1Position = pushedPos;
          }
          stuckMessage = 'Opponent pushed back toward start!';
        } else {
          stuckMessage = 'Opponent is already at the start!';
        }
        break;

      case AbilityType.decoy:
        final availableNodes =
            maze.where((n) => !n.isStart && !n.isFinish).toList();
        if (availableNodes.isNotEmpty) {
          final randomTile =
              availableNodes[_rnd.nextInt(availableNodes.length)].id;
          if (currentPlayer == 1) {
            p1Position = randomTile;
          } else {
            p2Position = randomTile;
          }
          stuckMessage = 'Vanished and reappeared at a random location!';
        } else {
          stuckMessage = 'No valid tiles to teleport to!';
        }
        break;

      default:
        break;
    }

    ability.use();
    notifyListeners();
  }

  void executeAbilityMove(int targetNodeId) {
    if (activeAbility == null) return;

    final ability = activeAbility!;

    // ── Steal sub-phase: resolve the stolen tile-selection ────────────────
    if (abilitySubPhase == AbilitySubPhase.stealExecute) {
      if (stolenAbility != null) {
        // Execute the tile-selection for the stolen ability
        switch (stolenAbility!.type) {
          case AbilityType.teleportToColor:
            final targetNode = maze[targetNodeId];
            if (!targetNode.isStart && !targetNode.isFinish) {
              if (currentPlayer == 1) {
                p1Position = targetNodeId;
              } else {
                p2Position = targetNodeId;
              }
              stuckMessage =
                  'Stolen teleport to ${targetNode.color?.label ?? 'tile'}! Now spin!';
            } else if (targetNode.isFinish) {
              stuckMessage = 'Cannot teleport directly to the finish tile!';
            }
            break;
          case AbilityType.jumpAnywhere:
          case AbilityType.rainbowPath:
            final targetNode = maze[targetNodeId];
            if (!targetNode.isFinish) {
              if (currentPlayer == 1) {
                p1Position = targetNodeId;
              } else {
                p2Position = targetNodeId;
              }
              stuckMessage = 'Stolen jump executed! Now spin!';
            } else {
              stuckMessage = 'Cannot jump directly to the finish tile!';
            }
            break;
          default:
            break;
        }
      }
      abilitySubPhase = AbilitySubPhase.none;
      stolenAbility = null;
      activeAbility = null;
      highlightedNodes = {};
      pendingChoices = [];
      // Keep _abilityUsedThisTurn as true - steal already used
      notifyListeners();
      return;
    }
    // ... rest of the method
  }

  void _jumpToNode(int targetNodeId) {
    if (currentPlayer == 1) {
      p1Position = targetNodeId;
    } else {
      p2Position = targetNodeId;
    }

    if (maze[targetNodeId].isFinish) {
      winner = currentPlayer;
      handleWin(currentPlayer);
    }
  }

  void _advanceTurnAfterAbility() {
    _advanceTurn();
  }

  // ── Preload character images ───────────────────────────────────────────────

  Future<void> preloadCharacterImages() async {
    for (final character in kAllCharacters) {
      if (characterImages.containsKey(character.id)) continue;

      try {
        final ByteData data = await rootBundle.load(character.imagePath);
        final Uint8List bytes = data.buffer.asUint8List();
        final Completer<ui.Image> completer = Completer();

        ui.decodeImageFromList(bytes, (ui.Image img) {
          characterImages[character.id] = img;
          if (!completer.isCompleted) {
            completer.complete(img);
          }
        });

        await completer.future;
        debugPrint('✅ Loaded image for ${character.name}');
      } catch (e) {
        debugPrint('❌ Failed to preload image for ${character.name}: $e');
      }
    }
    notifyListeners();
  }

  // ── Board initialisation ───────────────────────────────────────────────────

  void _initBoard() {
    maze = buildMaze([]);
    p1Position = -1;
    p2Position = -1;
    currentPlayer = 1;
    winner = null;
    lastSpunColor = null;
    isSpinning = false;
    highlightedNodes = {};
    pendingChoices = [];
    stuckMessage = null;
    previewPath = null;
    previewTargetNode = null;
    activeAbility = null;
    _abilityUsedThisTurn = false;
    _doubleMoveActive = false;
    _doubleMovePendingSecondRoll = false;
    p1Frozen = false;
    p2Frozen = false;
    p1Shielded = false;
    p2Shielded = false;
    p1Cloned = false;
    p2Cloned = false;
    p1CloneLocations = [];
    p2CloneLocations = [];
    cloneTurnsRemaining = 0;
    activeEffects = {};
    abilitySubPhase = AbilitySubPhase.none;
    stealableAbilities = [];
    stolenAbility = null;
    bicycleKickChosenColor = null;
    notifyListeners();
  }

  void restartGame() {
    goToCharacterSelect();
  }

  // ── Public getters ─────────────────────────────────────────────────────────

  MazeNode? get p1Node => p1Position >= 0 ? maze[p1Position] : null;
  MazeNode? get p2Node => p2Position >= 0 ? maze[p2Position] : null;
  int get currentPosition => currentPlayer == 1 ? p1Position : p2Position;

  GameCharacter? get currentCharacter =>
      currentPlayer == 1 ? p1Character : p2Character;

  // ── BFS Path Distance Calculation ─────────────────────────────────────────

  Map<int, int> _calculateDistancesFrom(int startId) {
    final distances = <int, int>{};
    final queue = <int>[];

    distances[startId] = 0;
    queue.add(startId);

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      final currentDist = distances[current]!;

      for (final neighborId in maze[current].neighbours) {
        if (!distances.containsKey(neighborId)) {
          distances[neighborId] = currentDist + 1;
          queue.add(neighborId);
        }
      }
    }

    return distances;
  }

  List<int> findShortestPath(int fromId, int toId) {
    if (fromId == toId) return [fromId];

    final visited = <int>{};
    final previous = <int, int>{};
    final queue = <int>[fromId];
    visited.add(fromId);

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);

      for (final neighborId in maze[current].neighbours) {
        if (!visited.contains(neighborId)) {
          visited.add(neighborId);
          previous[neighborId] = current;
          queue.add(neighborId);

          if (neighborId == toId) {
            final path = <int>[];
            var node = toId;
            while (node != fromId) {
              path.insert(0, node);
              node = previous[node]!;
            }
            path.insert(0, fromId);
            return path;
          }
        }
      }
    }

    return [fromId, toId];
  }

  void setPreviewPath(int targetNodeId) {
    final startId = currentPosition < 0 ? 0 : currentPosition;
    final path = findShortestPath(startId, targetNodeId);

    if (path.isNotEmpty) {
      previewPath = path;
      previewTargetNode = targetNodeId;
      notifyListeners();
    }
  }

  void clearPreviewPath() {
    previewPath = null;
    previewTargetNode = null;
    notifyListeners();
  }

  // ── Spin ───────────────────────────────────────────────────────────────────
// In game_state.dart, update spinColor to handle freeze at the start:
  Future<void> spinColor() async {
    // Check freeze BEFORE any other checks
    if ((currentPlayer == 1 && p1Frozen) || (currentPlayer == 2 && p2Frozen)) {
      stuckMessage =
          '❄️ ${currentPlayer == 1 ? p1Character?.name ?? "Player 1" : p2Character?.name ?? "Player 2"} is frozen! Turn skipped.';
      _advanceTurn(); // This will advance turn and handle freeze decrement
      notifyListeners();
      return;
    }

    if (isSpinning ||
        winner != null ||
        pendingChoices.isNotEmpty ||
        activeAbility != null ||
        abilityBeingAnimated != null ||
        abilitySubPhase != AbilitySubPhase.none) return;

    isSpinning = true;
    stuckMessage = null;
    highlightedNodes = {};
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    lastSpunColor = TileColor.values[_rnd.nextInt(TileColor.values.length)];
    isSpinning = false;

    final speedKey = 'speed_$currentPlayer';
    int extraSteps = 0;
    if (activeEffects.containsKey(speedKey)) {
      extraSteps = 3;
      activeEffects.remove(speedKey);
    }

    final options = _findClosestMovesByPath(currentPosition, lastSpunColor!,
        extraSteps: extraSteps);

    if (options.isEmpty) {
      if (_doubleMoveActive && !_doubleMovePendingSecondRoll) {
        _doubleMoveActive = false;
        stuckMessage =
            'No ${lastSpunColor!.label} tile available! ⚡ Double move! Roll again!';
      } else {
        stuckMessage =
            'No ${lastSpunColor!.label} tile available — turn skipped!';
        _advanceTurn();
      }
      notifyListeners();
      return;
    }

    final minSteps = options.map((o) => o.steps).reduce(min);
    final maxAllowedSteps = minSteps + extraSteps;
    final closestOptions =
        options.where((o) => o.steps <= maxAllowedSteps).toList();

    highlightedNodes = closestOptions.map((o) => o.nodeId).toSet();
    pendingChoices = closestOptions;

    if (_doubleMoveActive && !_doubleMovePendingSecondRoll) {
      _doubleMovePendingSecondRoll = true;
    }

    final extraLabel = extraSteps > 0 ? ' (+$extraSteps speed boost)' : '';
    if (closestOptions.length == 1) {
      stuckMessage =
          '✨ ${lastSpunColor!.label} tile — ${minSteps} step${minSteps != 1 ? 's' : ''}$extraLabel — hover to see path ✨';
    } else {
      stuckMessage =
          '✨ ${closestOptions.length} ${lastSpunColor!.label} tiles — up to ${maxAllowedSteps} step${maxAllowedSteps != 1 ? 's' : ''}$extraLabel — choose one ✨';
    }
    notifyListeners();

    await Future.delayed(const Duration(seconds: 4));
    if (stuckMessage != null && stuckMessage!.contains('✨')) {
      stuckMessage = null;
      notifyListeners();
    }
  }

  void chooseMoveOption(int nodeId) {
    if (pendingChoices.isEmpty) return;

    final isValid = pendingChoices.any((opt) => opt.nodeId == nodeId);
    if (!isValid) return;

    pendingChoices = [];
    _applyMove(nodeId);
  }

  // ── Path-based movement logic ─────────────────────────────────────────────

  List<MoveOption> _findClosestMovesByPath(int fromId, TileColor color,
      {int extraSteps = 0}) {
    final List<MoveOption> options = [];

    final startId = fromId < 0 ? 0 : fromId;
    final distances = _calculateDistancesFrom(startId);

    for (int i = 0; i < maze.length; i++) {
      final node = maze[i];

      if (i == startId && fromId >= 0) continue;

      if (node.isFinish) {
        // Only allow reaching finish if you land exactly on a yellow tile that connects to finish
        if (color == TileColor.yellow && distances.containsKey(i)) {
          options.add(
            MoveOption(
              nodeId: i,
              steps: distances[i]!,
              directionHint: '🏆 GOAL! 🏆',
            ),
          );
        }
      } else if (node.color == color) {
        if (distances.containsKey(i)) {
          options.add(
            MoveOption(
              nodeId: i,
              steps: distances[i]!,
              directionHint: _getDirectionHint(maze[startId], node),
            ),
          );
        }
      }
    }

    options.sort((a, b) => a.steps.compareTo(b.steps));

    if (extraSteps > 0 && options.isNotEmpty) {
      final minSteps = options.first.steps;
      return options.where((o) => o.steps <= minSteps + extraSteps).toList();
    }

    return options;
  }

  String _getDirectionHint(MazeNode from, MazeNode to) {
    final dx = to.x - from.x;
    final dy = to.y - from.y;

    if (to.isFinish) return '🏆 GOAL! 🏆';

    if (dy.abs() > dx.abs()) {
      return dy < 0 ? '⬆️ North' : '⬇️ South';
    } else {
      return dx < 0 ? '⬅️ West' : '➡️ East';
    }
  }

  void _applyMove(int nodeId) {
    final node = maze[nodeId];

    if (currentPlayer == 1) {
      p1Position = nodeId;
      if (node.isFinish) {
        winner = 1;
        handleWin(1);
      }
    } else {
      p2Position = nodeId;
      if (node.isFinish) {
        winner = 2;
        handleWin(2);
      }
    }

    highlightedNodes = {};
    pendingChoices = [];
    previewPath = null;

    if (winner != null) {
      stuckMessage = null;
      notifyListeners();
      return;
    }

    if (_doubleMovePendingSecondRoll) {
      _doubleMovePendingSecondRoll = false;
      _doubleMoveActive = false;
      stuckMessage = '⚡ Double move! Roll again!';
      notifyListeners();
      return;
    }

    stuckMessage = null;
    _advanceTurn();
    notifyListeners();
  }

  void handleWin(int winningPlayer) {
    if (winningPlayer == 1) {
      p1Wins++;
      _unlockNextCharacterForPlayer(1);
    } else {
      p2Wins++;
      _unlockNextCharacterForPlayer(2);
    }
  }

  void _unlockNextCharacterForPlayer(int player) {
    final unlockedSet =
        player == 1 ? p1UnlockedCharacters : p2UnlockedCharacters;
    final wins = player == 1 ? p1Wins : p2Wins;

    final lockedInOrder =
        kUnlockOrder.where((id) => !unlockedSet.contains(id)).toList();

    if (lockedInOrder.isNotEmpty && wins > 0) {
      for (int i = 0; i < wins && i < lockedInOrder.length; i++) {
        unlockedSet.add(lockedInOrder[i]);
      }
    }
  }

// In game_state.dart, update _advanceTurn to better handle freeze:
  void _advanceTurn() {
    currentPlayer = currentPlayer == 1 ? 2 : 1;
    _abilityUsedThisTurn = false;
    _doubleMoveActive = false;
    _doubleMovePendingSecondRoll = false;

    // Check freeze for the NEW current player (the one whose turn just started)
    final freezeKey = 'freeze_$currentPlayer';
    if (activeEffects.containsKey(freezeKey)) {
      final remaining = activeEffects[freezeKey]!;
      if (remaining <= 1) {
        activeEffects.remove(freezeKey);
        if (currentPlayer == 1) p1Frozen = false;
        if (currentPlayer == 2) p2Frozen = false;
        stuckMessage =
            '❄️ ${currentPlayer == 1 ? p1Character?.name ?? "Player 1" : p2Character?.name ?? "Player 2"} is thawed!';
      } else {
        activeEffects[freezeKey] = remaining - 1;
        stuckMessage =
            '❄️ ${currentPlayer == 1 ? p1Character?.name ?? "Player 1" : p2Character?.name ?? "Player 2"} is frozen for ${remaining - 1} more turn(s)!';
      }
      notifyListeners();
    }

    // Shield handling
    final shieldKey = 'shield_$currentPlayer';
    if (activeEffects.containsKey(shieldKey)) {
      final remaining = activeEffects[shieldKey]!;
      if (remaining <= 1) {
        activeEffects.remove(shieldKey);
        if (currentPlayer == 1) p1Shielded = false;
        if (currentPlayer == 2) p2Shielded = false;
      } else {
        activeEffects[shieldKey] = remaining - 1;
      }
    }

    // Clone handling
    if (cloneTurnsRemaining > 0) {
      cloneTurnsRemaining--;
      if (cloneTurnsRemaining == 0) {
        if (p1Cloned && currentPlayer == 1) {
          _triggerCloneSelection(1);
        } else if (p2Cloned && currentPlayer == 2) {
          _triggerCloneSelection(2);
        } else {
          p1Cloned = false;
          p2Cloned = false;
        }
      }
    }

    notifyListeners();
  }

  void _triggerCloneSelection(int player) {
    stuckMessage = 'Clone timer expired! Select your true location!';
    final clones = player == 1 ? p1CloneLocations : p2CloneLocations;
    final currentPos = player == 1 ? p1Position : p2Position;

    highlightedNodes = (clones + [currentPos]).toSet();
    activeAbility = Ability(
      id: 'clone_selection',
      name: 'Clone Selection',
      description: '',
      type: AbilityType.clone,
      icon: Icons.people,
    );
  }

  int _pushTowardStart(int fromId, int hops) {
    if (fromId <= 0) return 0;
    final distancesFromStart = _calculateDistancesFrom(0);
    int pos = fromId;
    for (int i = 0; i < hops; i++) {
      final currentDist = distancesFromStart[pos] ?? 0;
      if (currentDist == 0) break;
      int? best;
      int bestDist = currentDist;
      for (final nid in maze[pos].neighbours) {
        final d = distancesFromStart[nid] ?? 999;
        if (d < bestDist) {
          bestDist = d;
          best = nid;
        }
      }
      if (best == null) break;
      pos = best;
    }
    return pos;
  }

  void updatePositionDuringAnimation(int newNodeId) {
    if (currentPlayer == 1) {
      p1Position = newNodeId;
    } else {
      p2Position = newNodeId;
    }
    notifyListeners();
  }

  void completeMoveAnimation(int targetNodeId) {
    final node = maze[targetNodeId];

    if (node.isFinish) {
      if (currentPlayer == 1) {
        winner = 1;
        handleWin(1);
      } else {
        winner = 2;
        handleWin(2);
      }
    }

    highlightedNodes = {};
    pendingChoices = [];
    previewPath = null;

    if (winner != null) {
      stuckMessage = null;
      notifyListeners();
      return;
    }

    if (_doubleMovePendingSecondRoll) {
      _doubleMovePendingSecondRoll = false;
      _doubleMoveActive = false;
      stuckMessage = '⚡ Double move! Roll again!';
      notifyListeners();
      return;
    }

    stuckMessage = null;
    _advanceTurn();
    notifyListeners();
  }
}
