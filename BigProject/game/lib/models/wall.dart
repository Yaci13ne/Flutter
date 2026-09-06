import 'grid_position.dart';

/// A wall placed between two adjacent tiles.
/// Walls are defined by:
/// - [from]: the tile on one side
/// - [to]: the adjacent tile on the other side
/// - The wall blocks movement between these two tiles in both directions
class Wall {
  final GridPosition from;
  final GridPosition to;

  const Wall(this.from, this.to);

  /// Canonical form: always store with smaller position first
  factory Wall.canonical(GridPosition a, GridPosition b) {
    if (a.row < b.row || (a.row == b.row && a.col < b.col)) {
      return Wall(a, b);
    }
    return Wall(b, a);
  }

  bool get isHorizontal => from.row == to.row;
  bool get isVertical => from.col == to.col;

  bool blocksMovement(GridPosition start, GridPosition end) {
    final w = Wall.canonical(start, end);
    return w.from == from && w.to == to;
  }

  @override
  bool operator ==(Object other) =>
      other is Wall && from == other.from && to == other.to;

  @override
  int get hashCode => Object.hash(from, to);

  @override
  String toString() => 'Wall($from <-> $to)';
}
