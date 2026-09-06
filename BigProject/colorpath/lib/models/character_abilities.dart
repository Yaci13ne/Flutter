// models/character_abilities.dart
import 'package:flutter/material.dart';
import 'ability.dart';
import 'character.dart';

class CharacterAbilities {
  final String characterId;
  final List<Ability> abilities;

  CharacterAbilities({
    required this.characterId,
    required this.abilities,
  });

  static CharacterAbilities? forCharacter(GameCharacter character) {
    return _abilitiesMap[character.id];
  }

  static final Map<String, CharacterAbilities> _abilitiesMap = {
    // ── Goku ──────────────────────────────────────────────────────────────────
    'goku': CharacterAbilities(
      characterId: 'goku',
      abilities: [
        Ability(
          id: 'goku_kaio_ken',
          name: 'Kaiō-ken',
          description: 'Double your movement speed — move twice this turn!',
          type: AbilityType.doubleMove,
          icon: Icons.flash_on,
        ),
        Ability(
          id: 'goku_instant_transmission',
          name: 'Instant Transmission',
          description:
              'Teleport to any tile that shares your current tile\'s color!',
          type: AbilityType.teleportToColor,
          icon: Icons.bolt,
        ),
        Ability(
          id: 'goku_spirit_bomb',
          name: 'Spirit Bomb',
          description: 'Force opponent to skip their next turn!',
          type: AbilityType.doubleMove,
          icon: Icons.whatshot,
        ),
      ],
    ),

    // ── Vegeta ────────────────────────────────────────────────────────────────
    'vegeta': CharacterAbilities(
      characterId: 'vegeta',
      abilities: [
        Ability(
          id: 'vegeta_gallick_gun',
          name: 'Gallick Gun',
          description: 'Blast opponent back 3 tiles toward start!',
          type: AbilityType.powerShot,
          icon: Icons.rocket_launch,
        ),
        Ability(
          id: 'vegeta_final_flash',
          name: 'Final Flash',
          description:
              'Create a force field — immune to opponent attacks for 3 turns!',
          type: AbilityType.forceField,
          icon: Icons.shield,
        ),
        Ability(
          id: 'vegeta_pride',
          name: 'Saiyan Pride',
          description:
              'STEAL — choose one of your opponent\'s abilities and use it yourself!',
          type: AbilityType.mindControl,
          icon: Icons.auto_awesome,
        ),
      ],
    ),

    // ── Naruto ────────────────────────────────────────────────────────────────
    'naruto': CharacterAbilities(
      characterId: 'naruto',
      abilities: [
        Ability(
          id: 'naruto_shadow_clone',
          name: 'Shadow Clone Jutsu',
          description:
              'Spawn clones — 50% chance to dodge opponent attacks for 2 turns!',
          type: AbilityType.clone,
          icon: Icons.people,
        ),
        Ability(
          id: 'naruto_rasengan',
          name: 'Rasengan',
          description: 'Push opponent back 3 tiles toward start!',
          type: AbilityType.powerShot,
          icon: Icons.touch_app,
        ),
        Ability(
          id: 'naruto_nine_tails',
          name: 'Nine-Tails Chakra',
          description: 'Channel the Nine-Tails and take two consecutive turns!',
          type: AbilityType.doubleMove,
          icon: Icons.speed,
        ),
      ],
    ),

    // ── Luffy ─────────────────────────────────────────────────────────────────
    'luffy': CharacterAbilities(
      characterId: 'luffy',
      abilities: [
        Ability(
          id: 'luffy_gomu_gomu',
          name: 'Gomu Gomu no Rocket',
          description:
              'Stretch and launch to any tile sharing your current tile\'s color!',
          type: AbilityType.teleportToColor,
          icon: Icons.straighten,
        ),
        Ability(
          id: 'luffy_gear_second',
          name: 'Gear Second',
          description: 'Activate Gear Second — gain +3 extra steps next roll!',
          type: AbilityType.speedBoost,
          icon: Icons.timer,
        ),
        Ability(
          id: 'luffy_king_kong_gun',
          name: 'King Kong Gun',
          description: 'Massive punch — push opponent back 3 tiles!',
          type: AbilityType.powerShot,
          icon: Icons.gavel,
        ),
      ],
    ),

    // ── Ichigo ────────────────────────────────────────────────────────────────
    'ichigo': CharacterAbilities(
      characterId: 'ichigo',
      abilities: [
        Ability(
          id: 'ichigo_flash_step',
          name: 'Flash Step',
          description:
              'Flash-step to any tile that shares your current tile\'s color!',
          type: AbilityType.teleportToColor,
          icon: Icons.flash_on,
          maxUses: 1,
          remainingUses: 1,
        ),
        Ability(
          id: 'ichigo_bankai',
          name: 'Bankai',
          description: 'Unleash Bankai and take two consecutive turns!',
          type: AbilityType.doubleMove,
          icon: Icons.auto_awesome,
          maxUses: 1,
          remainingUses: 1,
        ),
        Ability(
          id: 'ichigo_getsuga',
          name: 'Getsuga Tenshō',
          description:
              'Slash a rainbow path — move to any non-finish tile on the board!',
          type: AbilityType.rainbowPath,
          icon: Icons.cut,
          maxUses: 1,
          remainingUses: 1,
        ),
      ],
    ),

    // ── Jin ───────────────────────────────────────────────────────────────────
    'jin': CharacterAbilities(
      characterId: 'jin',
      abilities: [
        Ability(
          id: 'jin_ewgf',
          name: 'Electric Wind God Fist',
          description: 'Stun opponent — they skip their next turn!',
          type: AbilityType.freezeOpponent,
          icon: Icons.gesture,
        ),
        Ability(
          id: 'jin_devil',
          name: 'Devil Form',
          description:
              'Transform and fly to any tile sharing your current tile\'s color!',
          type: AbilityType.teleportToColor,
          icon: Icons.flight,
        ),
        Ability(
          id: 'jin_parry',
          name: 'Perfect Parry',
          description:
              'Perfect Parry — become immune to opponent attacks for 2 turns!',
          type: AbilityType.shield,
          icon: Icons.shield,
        ),
      ],
    ),

    // ── Kazuya ────────────────────────────────────────────────────────────────
    'kazuya': CharacterAbilities(
      characterId: 'kazuya',
      abilities: [
        Ability(
          id: 'kazuya_laser',
          name: 'Devil Laser',
          description:
              'Blast opponent with Devil Laser — push them back 3 tiles!',
          type: AbilityType.powerShot,
          icon: Icons.remove_circle,
        ),
        Ability(
          id: 'kazuya_heavenly',
          name: 'Heavenly Fist',
          description: 'Swap positions with your opponent!',
          type: AbilityType.swapPositions,
          icon: Icons.swap_horiz,
        ),
        Ability(
          id: 'kazuya_rage',
          name: 'Rage Drive',
          description: 'Gain +3 extra steps on your next roll!',
          type: AbilityType.speedBoost,
          icon: Icons.bolt,
        ),
      ],
    ),

    // ── Ryu ───────────────────────────────────────────────────────────────────
    'ryu': CharacterAbilities(
      characterId: 'ryu',
      abilities: [
        Ability(
          id: 'ryu_hadouken',
          name: 'Hadouken',
          description:
              'Blast opponent with a fireball — push them back 3 tiles!',
          type: AbilityType.powerShot,
          icon: Icons.circle,
        ),
        Ability(
          id: 'ryu_shoryuken',
          name: 'Shoryuken',
          description:
              'Dragon Punch — teleport to any tile sharing your current tile\'s color!',
          type: AbilityType.teleportToColor,
          icon: Icons.arrow_upward,
        ),
        Ability(
          id: 'ryu_focus',
          name: 'Focus Attack',
          description: 'Focus — become immune to opponent attacks for 2 turns!',
          type: AbilityType.shield,
          icon: Icons.center_focus_strong,
        ),
      ],
    ),

    // ── Saitama ───────────────────────────────────────────────────────────────
    'saitama': CharacterAbilities(
      characterId: 'saitama',
      abilities: [
        Ability(
          id: 'saitama_one_punch',
          name: 'One Punch',
          description: 'A normal punch... pushes opponent back 3 tiles!',
          type: AbilityType.powerShot,
          icon: Icons.sports_mma,
        ),
        Ability(
          id: 'saitama_serious',
          name: 'Serious Series',
          description: 'Jump directly to any non-finish tile on the board!',
          type: AbilityType.teleportToColor,
          icon: Icons.fast_forward,
        ),
        Ability(
          id: 'saitama_bargain',
          name: 'Bargain Hunt',
          description: 'Distracted by a sale — get two rolls in one turn!',
          type: AbilityType.doubleMove,
          icon: Icons.shopping_cart,
        ),
      ],
    ),

    // ── Zoro ──────────────────────────────────────────────────────────────────
    'zoro': CharacterAbilities(
      characterId: 'zoro',
      abilities: [
        Ability(
          id: 'zoro_onigiri',
          name: 'Onigiri',
          description:
              'Cut through the board — slash to any non-finish tile instantly!',
          type: AbilityType.rainbowPath,
          icon: Icons.cut,
        ),
        Ability(
          id: 'zoro_asura',
          name: 'Asura',
          description:
              'Three-headed illusion — 50% chance to dodge attacks for 2 turns!',
          type: AbilityType.clone,
          icon: Icons.multiple_stop,
        ),
        Ability(
          id: 'zoro_santoryu',
          name: 'Santoryu Ogi',
          description:
              'STEAL — choose one of your opponent\'s abilities and use it yourself!',
          type: AbilityType.mindControl,
          icon: Icons.sports_kabaddi,
        ),
      ],
    ),

    // ── Superman ──────────────────────────────────────────────────────────────
    'superman': CharacterAbilities(
      characterId: 'superman',
      abilities: [
        Ability(
          id: 'superman_flight',
          name: 'Flight',
          description: 'Fly to any non-finish tile on the board!',
          type: AbilityType.jumpAnywhere,
          icon: Icons.flight,
        ),
        Ability(
          id: 'superman_heat_vision',
          name: 'Heat Vision',
          description:
              'Burn a rainbow path — move to any non-finish tile on the board!',
          type: AbilityType.rainbowPath,
          icon: Icons.visibility,
        ),
        Ability(
          id: 'superman_invincible',
          name: 'Invincible',
          description: 'Become immune to all attacks for 3 turns!',
          type: AbilityType.forceField,
          icon: Icons.shield,
        ),
      ],
    ),

    // ── Cristiano Ronaldo ─────────────────────────────────────────────────────
    'cristiano': CharacterAbilities(
      characterId: 'cristiano',
      abilities: [
        Ability(
          id: 'cr7_siu',
          name: 'SIUUU!',
          description:
              'Celebration leap — teleport to any tile sharing your current tile\'s color!',
          type: AbilityType.teleportToColor,
          icon: Icons.sports_soccer,
        ),
        Ability(
          id: 'cr7_bicycle',
          name: 'Bicycle Kick',
          description:
              'Choose a color, then move up to 3 steps to any tile of that color!',
          type: AbilityType.speedBoost, // custom handled — sub-phase overrides
          icon: Icons.sports_soccer,
        ),
        Ability(
          id: 'cr7_jump',
          name: 'Vertical Leap',
          description: 'Jump over your opponent and swap positions!',
          type: AbilityType.swapPositions,
          icon: Icons.vertical_align_top,
        ),
      ],
    ),

    // ── Messi ─────────────────────────────────────────────────────────────────
    'messi': CharacterAbilities(
      characterId: 'messi',
      abilities: [
        Ability(
          id: 'messi_dribble',
          name: 'La Pulga Dribble',
          description:
              'Dribble past everyone — slash to any non-finish tile on the board!',
          type: AbilityType.rainbowPath,
          icon: Icons.sports_soccer,
        ),
        Ability(
          id: 'messi_magia',
          name: 'Magia',
          description: 'Pure magic — jump to any non-finish tile on the board!',
          type: AbilityType.jumpAnywhere,
          icon: Icons.auto_awesome,
        ),
        Ability(
          id: 'messi_pase',
          name: 'Through Ball',
          description:
              'Perfect through-ball — teleport to any tile sharing your current tile\'s color!',
          type: AbilityType.teleportToColor,
          icon: Icons.arrow_forward,
        ),
      ],
    ),

    // ── Batman ────────────────────────────────────────────────────────────────
    'batman': CharacterAbilities(
      characterId: 'batman',
      abilities: [
        Ability(
          id: 'batman_grapple',
          name: 'Grapple Gun',
          description:
              'Fire the grapple gun — zip to any non-finish tile on the board!',
          type: AbilityType.jumpAnywhere,
          icon: Icons.link,
        ),
        Ability(
          id: 'batman_smoke',
          name: 'Smoke Bomb',
          description: 'Disappear in smoke and reappear at a random tile!',
          type: AbilityType.decoy,
          icon: Icons.smoke_free,
        ),
        Ability(
          id: 'batman_detective',
          name: 'Detective Mode',
          description:
              'Anticipate attacks — immune to opponent abilities for 2 turns!',
          type: AbilityType.shield,
          icon: Icons.search,
        ),
      ],
    ),

    // ── Thanos ────────────────────────────────────────────────────────────────
    'thanos': CharacterAbilities(
      characterId: 'thanos',
      abilities: [
        Ability(
          id: 'thanos_gauntlet',
          name: 'Infinity Gauntlet',
          description: 'Power Stone — blast opponent back 3 tiles!',
          type: AbilityType.powerShot,
          icon: Icons.whatshot,
        ),
        Ability(
          id: 'thanos_reality',
          name: 'Reality Stone',
          description:
              'Rewrite reality — teleport to any tile sharing your current tile\'s color!',
          type: AbilityType.teleportToColor,
          icon: Icons.color_lens,
        ),
        Ability(
          id: 'thanos_time',
          name: 'Time Stone',
          description: 'Stop time — freeze opponent for 2 turns!',
          type: AbilityType.timeFreeze,
          icon: Icons.timer,
        ),
      ],
    ),
  };
}
