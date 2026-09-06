// widgets/ability_panel.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/ability.dart';
import '../models/game_state.dart';
import '../models/tile_color.dart';

class AbilityPanel extends StatelessWidget {
  final bool isActive;

  const AbilityPanel({super.key, this.isActive = true});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    if (!isActive || gameState.winner != null) {
      return const SizedBox.shrink();
    }

    // ── Sub-phase: steal — let player pick which opponent ability to steal ──
    if (gameState.abilitySubPhase == AbilitySubPhase.stealChooseAbility &&
        gameState.stealableAbilities.isNotEmpty) {
      return _StealPickerPanel(abilities: gameState.stealableAbilities);
    }

    // ── Sub-phase: bicycle kick — let player pick a color ──────────────────
    if (gameState.abilitySubPhase == AbilitySubPhase.bicycleKickChooseColor) {
      return const _BicycleKickColorPicker();
    }

    // ── Normal ability buttons ─────────────────────────────────────────────
    final abilities = gameState.getCurrentPlayerAbilities();

    if (abilities.isEmpty ||
        (gameState.activeAbility != null &&
            gameState.abilitySubPhase == AbilitySubPhase.none) ||
        gameState.doubleMovePendingSecondRoll ||
        gameState.abilitySubPhase != AbilitySubPhase.none) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var ability in abilities)
            _AbilityButton(
              ability: ability,
              onTap: () => gameState.useAbility(ability),
              canUse: gameState.canUseAbility(ability),
            ),
        ],
      ),
    );
  }
}

// ── Steal picker ──────────────────────────────────────────────────────────────

class _StealPickerPanel extends StatelessWidget {
  final List<Ability> abilities;

  const _StealPickerPanel({required this.abilities});

  @override
  Widget build(BuildContext context) {
    final gameState = context.read<GameState>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFCC44FF), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '🎭 STEAL — Pick one to use',
            style: GoogleFonts.orbitron(
              fontSize: 10,
              color: const Color(0xFFCC44FF),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final ability in abilities)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Tooltip(
                    message:
                        '${ability.name}\n${ability.description}\nUses left: ${ability.remainingUses}',
                    child: InkWell(
                      onTap: () => gameState.selectStealAbility(ability),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCC44FF).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFFCC44FF).withOpacity(0.6)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(ability.icon, color: Colors.white, size: 20),
                            const SizedBox(height: 2),
                            Text(
                              ability.name,
                              style: GoogleFonts.rubik(
                                fontSize: 9,
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
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

// ── Bicycle-kick color picker ─────────────────────────────────────────────────

class _BicycleKickColorPicker extends StatelessWidget {
  const _BicycleKickColorPicker();

  @override
  Widget build(BuildContext context) {
    final gameState = context.read<GameState>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD700), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '⚽ BICYCLE KICK — Choose color',
            style: GoogleFonts.orbitron(
              fontSize: 10,
              color: const Color(0xFFFFD700),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final color in TileColor.values)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: GestureDetector(
                    onTap: () => gameState.selectBicycleKickColor(color),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color.color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: color.color.withOpacity(0.5),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
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

// ── Normal ability button ─────────────────────────────────────────────────────

class _AbilityButton extends StatelessWidget {
  final Ability ability;
  final VoidCallback onTap;
  final bool canUse;

  const _AbilityButton({
    required this.ability,
    required this.onTap,
    required this.canUse,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Tooltip(
        message:
            '${ability.name}\n${ability.description}\n${ability.remainingUses}/${ability.maxUses} uses left',
        child: InkWell(
          onTap: canUse ? onTap : null,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: canUse
                  ? Colors.white.withOpacity(0.15)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: canUse
                    ? Colors.white.withOpacity(0.3)
                    : Colors.white.withOpacity(0.1),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  ability.icon,
                  color: canUse ? Colors.white : Colors.white38,
                  size: 20,
                ),
                const SizedBox(height: 2),
                Text(
                  '${ability.remainingUses}',
                  style: GoogleFonts.rubik(
                    fontSize: 10,
                    color: canUse ? Colors.white70 : Colors.white38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
