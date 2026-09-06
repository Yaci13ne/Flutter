import 'grid_position.dart';

enum SpecialTileType { none, teleport, trap, booster, colorSwitch }

class SpecialTile {
  final GridPosition position;
  final SpecialTileType type;
  final GridPosition? teleportTarget;
  bool isActive;

  SpecialTile({
    required this.position,
    required this.type,
    this.teleportTarget,
    this.isActive = true,
  });

  String get label {
    switch (type) {
      case SpecialTileType.teleport:
        return '⚡';
      case SpecialTileType.trap:
        return '💀';
      case SpecialTileType.booster:
        return '🚀';
      case SpecialTileType.colorSwitch:
        return '🔄';
      case SpecialTileType.none:
        return '';
    }
  }

  String get description {
    switch (type) {
      case SpecialTileType.teleport:
        return 'Teleports you to a random tile';
      case SpecialTileType.trap:
        return 'Skip your next turn';
      case SpecialTileType.booster:
        return 'Move again this turn';
      case SpecialTileType.colorSwitch:
        return 'Changes this tile\'s color';
      case SpecialTileType.none:
        return '';
    }
  }
}
