import 'package:flutter/foundation.dart';

@immutable
class GridPosition {
  final int row;
  final int col;

  const GridPosition(this.row, this.col);

  GridPosition operator +(GridPosition other) =>
      GridPosition(row + other.row, col + other.col);

  bool operator ==(Object other) =>
      other is GridPosition && row == other.row && col == other.col;

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() => 'GridPosition($row, $col)';

  GridPosition copyWith({int? row, int? col}) =>
      GridPosition(row ?? this.row, col ?? this.col);
}

enum Direction { up, down, left, right }

extension DirectionExtension on Direction {
  GridPosition get delta {
    switch (this) {
      case Direction.up:
        return const GridPosition(-1, 0);
      case Direction.down:
        return const GridPosition(1, 0);
      case Direction.left:
        return const GridPosition(0, -1);
      case Direction.right:
        return const GridPosition(0, 1);
    }
  }

  String get label {
    switch (this) {
      case Direction.up:
        return '↑';
      case Direction.down:
        return '↓';
      case Direction.left:
        return '←';
      case Direction.right:
        return '→';
    }
  }
}
