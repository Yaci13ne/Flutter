// maze_node.dart
import 'package:colorpath/models/tile_color.dart';
import 'package:flutter/material.dart';

/// A single node in the maze graph.
class MazeNode {
  final int id;
  final double x; // normalised 0..1 position
  final double y;
  final TileColor? color; // null only for START
  final bool isStart;
  final bool isFinish;

  /// IDs of nodes this node is connected to (bidirectional edges stored here).
  final List<int> neighbours;

  const MazeNode({
    required this.id,
    required this.x,
    required this.y,
    this.color,
    this.isStart = false,
    this.isFinish = false,
    required this.neighbours,
  });
}

/// Builds a complex maze with strategic color placement and single color finish
List<MazeNode> buildMaze(List<TileColor> _ignored) {
  final allColors = TileColor.values;

  // Helper: convert grid col/row to normalised coords
  double gx(int col) => 0.05 + col * 0.075;
  double gy(int row) => 0.05 + row * 0.09;

  return [
    // START node (id 0) - central bottom
    MazeNode(id: 0, x: 0.5, y: 0.92, isStart: true, neighbours: [1, 2, 3]),

    // Row 8 (bottom layer)
    MazeNode(
      id: 1,
      x: gx(2),
      y: gy(8),
      color: TileColor.red,
      neighbours: [0, 4, 5],
    ),
    MazeNode(
      id: 2,
      x: gx(5),
      y: gy(8),
      color: TileColor.blue,
      neighbours: [0, 6, 7],
    ),
    MazeNode(
      id: 3,
      x: gx(8),
      y: gy(8),
      color: TileColor.green,
      neighbours: [0, 8, 9],
    ),

    // Row 7
    MazeNode(
      id: 4,
      x: gx(1),
      y: gy(7),
      color: TileColor.yellow,
      neighbours: [1, 10],
    ),
    MazeNode(
      id: 5,
      x: gx(3),
      y: gy(7),
      color: TileColor.purple,
      neighbours: [1, 11, 12],
    ),
    MazeNode(
      id: 6,
      x: gx(4),
      y: gy(7),
      color: TileColor.orange,
      neighbours: [2, 12, 13],
    ),
    MazeNode(
      id: 7,
      x: gx(6),
      y: gy(7),
      color: TileColor.cyan,
      neighbours: [2, 14, 15],
    ),
    MazeNode(
      id: 8,
      x: gx(7),
      y: gy(7),
      color: TileColor.red,
      neighbours: [3, 15, 16],
    ),
    MazeNode(
      id: 9,
      x: gx(9),
      y: gy(7),
      color: TileColor.blue,
      neighbours: [3, 17],
    ),

    // Row 6 - Complex intersections
    MazeNode(
      id: 10,
      x: gx(0),
      y: gy(6),
      color: TileColor.green,
      neighbours: [4, 18],
    ),
    MazeNode(
      id: 11,
      x: gx(2),
      y: gy(6),
      color: TileColor.yellow,
      neighbours: [5, 18, 19],
    ),
    MazeNode(
      id: 12,
      x: gx(3),
      y: gy(6),
      color: TileColor.purple,
      neighbours: [5, 6, 19, 20],
    ),
    MazeNode(
      id: 13,
      x: gx(5),
      y: gy(6),
      color: TileColor.orange,
      neighbours: [6, 20, 21],
    ),
    MazeNode(
      id: 14,
      x: gx(6),
      y: gy(6),
      color: TileColor.cyan,
      neighbours: [7, 21, 22],
    ),
    MazeNode(
      id: 15,
      x: gx(7),
      y: gy(6),
      color: TileColor.red,
      neighbours: [7, 8, 22, 23],
    ),
    MazeNode(
      id: 16,
      x: gx(8),
      y: gy(6),
      color: TileColor.blue,
      neighbours: [8, 23, 24],
    ),
    MazeNode(
      id: 17,
      x: gx(10),
      y: gy(6),
      color: TileColor.green,
      neighbours: [9, 25],
    ),

    // Row 5 - More complexity
    MazeNode(
      id: 18,
      x: gx(1),
      y: gy(5),
      color: TileColor.yellow,
      neighbours: [10, 11, 26],
    ),
    MazeNode(
      id: 19,
      x: gx(2),
      y: gy(5),
      color: TileColor.purple,
      neighbours: [11, 12, 26, 27],
    ),
    MazeNode(
      id: 20,
      x: gx(4),
      y: gy(5),
      color: TileColor.orange,
      neighbours: [12, 13, 27, 28],
    ),
    MazeNode(
      id: 21,
      x: gx(5),
      y: gy(5),
      color: TileColor.cyan,
      neighbours: [13, 14, 28, 29],
    ),
    MazeNode(
      id: 22,
      x: gx(7),
      y: gy(5),
      color: TileColor.red,
      neighbours: [14, 15, 29, 30],
    ),
    MazeNode(
      id: 23,
      x: gx(8),
      y: gy(5),
      color: TileColor.blue,
      neighbours: [15, 16, 30, 31],
    ),
    MazeNode(
      id: 24,
      x: gx(9),
      y: gy(5),
      color: TileColor.green,
      neighbours: [16, 31, 32],
    ),
    MazeNode(
      id: 25,
      x: gx(10),
      y: gy(5),
      color: TileColor.yellow,
      neighbours: [17, 33],
    ),

    // Row 4 - Strategic chokepoints
    MazeNode(
      id: 26,
      x: gx(1),
      y: gy(4),
      color: TileColor.purple,
      neighbours: [18, 19, 34],
    ),
    MazeNode(
      id: 27,
      x: gx(3),
      y: gy(4),
      color: TileColor.orange,
      neighbours: [19, 20, 35, 36],
    ),
    MazeNode(
      id: 28,
      x: gx(4),
      y: gy(4),
      color: TileColor.cyan,
      neighbours: [20, 21, 36, 37],
    ),
    MazeNode(
      id: 29,
      x: gx(6),
      y: gy(4),
      color: TileColor.red,
      neighbours: [21, 22, 37, 38],
    ),
    MazeNode(
      id: 30,
      x: gx(7),
      y: gy(4),
      color: TileColor.blue,
      neighbours: [22, 23, 38, 39],
    ),
    MazeNode(
      id: 31,
      x: gx(8),
      y: gy(4),
      color: TileColor.green,
      neighbours: [23, 24, 39, 40],
    ),
    MazeNode(
      id: 32,
      x: gx(9),
      y: gy(4),
      color: TileColor.yellow,
      neighbours: [24, 40, 41],
    ),
    MazeNode(
      id: 33,
      x: gx(10),
      y: gy(4),
      color: TileColor.purple,
      neighbours: [25, 42],
    ),

    // Row 3
    MazeNode(
      id: 34,
      x: gx(0),
      y: gy(3),
      color: TileColor.orange,
      neighbours: [26, 43],
    ),
    MazeNode(
      id: 35,
      x: gx(2),
      y: gy(3),
      color: TileColor.cyan,
      neighbours: [27, 43, 44],
    ),
    MazeNode(
      id: 36,
      x: gx(3),
      y: gy(3),
      color: TileColor.red,
      neighbours: [27, 28, 44, 45],
    ),
    MazeNode(
      id: 37,
      x: gx(5),
      y: gy(3),
      color: TileColor.blue,
      neighbours: [28, 29, 45, 46],
    ),
    MazeNode(
      id: 38,
      x: gx(6),
      y: gy(3),
      color: TileColor.green,
      neighbours: [29, 30, 46, 47],
    ),
    MazeNode(
      id: 39,
      x: gx(8),
      y: gy(3),
      color: TileColor.yellow,
      neighbours: [30, 31, 47, 48],
    ),
    MazeNode(
      id: 40,
      x: gx(9),
      y: gy(3),
      color: TileColor.purple,
      neighbours: [31, 32, 48, 49],
    ),
    MazeNode(
      id: 41,
      x: gx(10),
      y: gy(3),
      color: TileColor.orange,
      neighbours: [32, 49, 50],
    ),
    MazeNode(
      id: 42,
      x: gx(11),
      y: gy(3),
      color: TileColor.cyan,
      neighbours: [33, 51],
    ),

    // Row 2
    MazeNode(
      id: 43,
      x: gx(1),
      y: gy(2),
      color: TileColor.red,
      neighbours: [34, 35, 52],
    ),
    MazeNode(
      id: 44,
      x: gx(2),
      y: gy(2),
      color: TileColor.blue,
      neighbours: [35, 36, 52, 53],
    ),
    MazeNode(
      id: 45,
      x: gx(4),
      y: gy(2),
      color: TileColor.green,
      neighbours: [36, 37, 53, 54],
    ),
    MazeNode(
      id: 46,
      x: gx(5),
      y: gy(2),
      color: TileColor.yellow,
      neighbours: [37, 38, 54, 55],
    ),
    MazeNode(
      id: 47,
      x: gx(7),
      y: gy(2),
      color: TileColor.purple,
      neighbours: [38, 39, 55, 56],
    ),
    MazeNode(
      id: 48,
      x: gx(8),
      y: gy(2),
      color: TileColor.orange,
      neighbours: [39, 40, 56, 57],
    ),
    MazeNode(
      id: 49,
      x: gx(9),
      y: gy(2),
      color: TileColor.cyan,
      neighbours: [40, 41, 57, 58],
    ),
    MazeNode(
      id: 50,
      x: gx(10),
      y: gy(2),
      color: TileColor.red,
      neighbours: [41, 58, 59],
    ),
    MazeNode(
      id: 51,
      x: gx(11),
      y: gy(2),
      color: TileColor.blue,
      neighbours: [42, 60],
    ),

    // Row 1 - Paths leading to single finish
    MazeNode(
      id: 52,
      x: gx(1),
      y: gy(1),
      color: TileColor.green,
      neighbours: [43, 44, 61],
    ),
    MazeNode(
      id: 53,
      x: gx(3),
      y: gy(1),
      color: TileColor.yellow,
      neighbours: [44, 45, 61, 62],
    ),
    MazeNode(
      id: 54,
      x: gx(4),
      y: gy(1),
      color: TileColor.purple,
      neighbours: [45, 46, 62, 63],
    ),
    MazeNode(
      id: 55,
      x: gx(6),
      y: gy(1),
      color: TileColor.orange,
      neighbours: [46, 47, 63, 64],
    ),
    MazeNode(
      id: 56,
      x: gx(7),
      y: gy(1),
      color: TileColor.cyan,
      neighbours: [47, 48, 64, 65],
    ),
    MazeNode(
      id: 57,
      x: gx(9),
      y: gy(1),
      color: TileColor.red,
      neighbours: [48, 49, 65, 66],
    ),
    MazeNode(
      id: 58,
      x: gx(10),
      y: gy(1),
      color: TileColor.blue,
      neighbours: [49, 50, 66, 67],
    ),
    MazeNode(
      id: 59,
      x: gx(11),
      y: gy(1),
      color: TileColor.green,
      neighbours: [50, 67, 68],
    ),
    MazeNode(
      id: 60,
      x: gx(12),
      y: gy(1),
      color: TileColor.yellow,
      neighbours: [51, 69],
    ),

    // Row 0 - Converging paths to single finish tile
    MazeNode(
      id: 61,
      x: gx(2),
      y: gy(0),
      color: TileColor.purple,
      neighbours: [52, 53, 70],
    ),
    MazeNode(
      id: 62,
      x: gx(3),
      y: gy(0),
      color: TileColor.orange,
      neighbours: [53, 54, 70],
    ),
    MazeNode(
      id: 63,
      x: gx(5),
      y: gy(0),
      color: TileColor.cyan,
      neighbours: [54, 55, 70],
    ),
    MazeNode(
      id: 64,
      x: gx(6),
      y: gy(0),
      color: TileColor.red,
      neighbours: [55, 56, 70],
    ),
    MazeNode(
      id: 65,
      x: gx(8),
      y: gy(0),
      color: TileColor.blue,
      neighbours: [56, 57, 70],
    ),
    MazeNode(
      id: 66,
      x: gx(9),
      y: gy(0),
      color: TileColor.green,
      neighbours: [57, 58, 70],
    ),
    MazeNode(
      id: 67,
      x: gx(10),
      y: gy(0),
      color: TileColor.yellow,
      neighbours: [58, 59, 70],
    ),
    MazeNode(
      id: 68,
      x: gx(11),
      y: gy(0),
      color: TileColor.purple,
      neighbours: [59, 70],
    ),
    MazeNode(
      id: 69,
      x: gx(12),
      y: gy(0),
      color: TileColor.orange,
      neighbours: [60, 70],
    ),

    // SINGLE FINISH NODE (id 70) - Central top, golden color
    MazeNode(
      id: 70,
      x: 0.5,
      y: 0.03,
      color: TileColor.yellow,
      isFinish: true,
      neighbours: [61, 62, 63, 64, 65, 66, 67, 68, 69],
    ),
  ];
}
