// models/ability.dart
import 'package:flutter/material.dart';

enum AbilityType {
  teleportToColor,
  clone,
  jumpAnywhere,
  doubleMove,
  forceField,
  freezeOpponent,
  swapPositions,
  shield,
  speedBoost,
  decoy,
  mindControl,
  timeFreeze,
  rainbowPath,
  powerShot,
  shadowStep,
}

class Ability {
  final String id;
  final String name;
  final String description;
  final AbilityType type;
  final IconData icon;
  final int maxUses; // Max uses per match (default 2)
  int remainingUses;

  Ability({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.icon,
    this.maxUses = 2,
    this.remainingUses = 2,
  });

  void use() {
    if (remainingUses > 0) {
      remainingUses--;
    }
  }

  void reset() {
    remainingUses = maxUses;
  }

  Ability copy() {
    return Ability(
      id: id,
      name: name,
      description: description,
      type: type,
      icon: icon,
      maxUses: maxUses,
      remainingUses: remainingUses,
    );
  }
}
