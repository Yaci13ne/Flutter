// models/character.dart
import 'package:flutter/material.dart';

class GameCharacter {
  final String id;
  final String name;
  final String subtitle;
  final bool startsUnlocked;
  final String imagePath; // Path to character image

  const GameCharacter({
    required this.id,
    required this.name,
    required this.subtitle,
    this.startsUnlocked = true,
    required this.imagePath,
  });
}

/// All 15 playable characters with images.
/// First 10 are available from the start.
/// Last 5 are locked and unlocked by winning.
const List<GameCharacter> kAllCharacters = [
  // ── Unlocked from start ──────────────────────────────────────────────────
  GameCharacter(
    id: 'goku',
    name: 'Goku',
    subtitle: 'Saiyan Warrior',
    imagePath: 'assets/characters/guko.png',
  ),
  GameCharacter(
    id: 'vegeta',
    name: 'Vegeta',
    subtitle: 'Prince of Saiyans',
    imagePath: 'assets/characters/vegeta.png',
  ),
  GameCharacter(
    id: 'naruto',
    name: 'Naruto',
    subtitle: 'Hidden Leaf Ninja',
    imagePath: 'assets/characters/naruto.png',
  ),
  GameCharacter(
    id: 'luffy',
    name: 'Luffy',
    subtitle: 'Pirate King',
    imagePath: 'assets/characters/luffy.png',
  ),
  GameCharacter(
    id: 'ichigo',
    name: 'Ichigo',
  
    subtitle: 'Soul Reaper',
    imagePath: 'assets/characters/ichigo.png',
  ),
  GameCharacter(
    id: 'jin',
    name: 'Jin',
  
    subtitle: 'Mishima Blood',
    imagePath: 'assets/characters/jin.png',
  ),
  GameCharacter(
    id: 'kazuya',
    name: 'Kazuya',
  
    subtitle: 'Devil Gene',
    imagePath: 'assets/characters/kazuya.png',
  ),
  GameCharacter(
    id: 'ryu',
    name: 'Ryu',
    subtitle: 'Wandering Fighter',
    imagePath: 'assets/characters/ryu.png',
  ),
  GameCharacter(
    id: 'saitama',
    name: 'Saitama',
    subtitle: 'One Punch Man',
    imagePath: 'assets/characters/saitama.png',
  ),
  GameCharacter(
    id: 'zoro',
    name: 'Zoro',
    subtitle: 'Three Sword Style',
    imagePath: 'assets/characters/zoro.png',
  ),

  // ── Locked — unlock by winning ───────────────────────────────────────────
  GameCharacter(
    id: 'superman',
    name: 'Superman',
    subtitle: 'Man of Steel',
    startsUnlocked: false,
    imagePath: 'assets/characters/superman.png',
  ),
  GameCharacter(
    id: 'cristiano',
    name: 'Cristiano',
    subtitle: 'CR7',
    startsUnlocked: false,
    imagePath: 'assets/characters/ronaldo.png',
  ),
  GameCharacter(
    id: 'messi',
    name: 'Messi',
    subtitle: 'La Pulga',
    startsUnlocked: false,
    imagePath: 'assets/characters/messi.png',
  ),
  GameCharacter(
    id: 'batman',
    name: 'Batman',
    subtitle: 'Dark Knight',
    startsUnlocked: false,
    imagePath: 'assets/characters/batman.png',
  ),
  GameCharacter(
    id: 'thanos',
    name: 'Thanos',
    subtitle: 'Mad Titan',
    startsUnlocked: false,
    imagePath: 'assets/characters/thanos.png',
  ),
];

/// IDs of characters locked at start, in unlock order.
const List<String> kUnlockOrder = [
  'superman',
  'cristiano',
  'messi',
  'batman',
  'thanos',
];
