import 'package:flutter/material.dart';
import 'package:xorussian/doll.dart';
import 'package:xorussian/main.dart';
import 'package:xorussian/result.dart';

class GamePage extends StatefulWidget {
  final String blueName;
  final String redName;
  final int blueWins;
  final int redWins;
  const GamePage({
    super.key,
    required this.blueName,
    required this.redName,
    this.blueWins = 0,
    this.redWins = 0,
  });
  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final List<List<Doll>> board = List.generate(9, (_) => []);
  bool blueTurn = true;
  String winner = '';

  int blueWins = 0;
  int redWins = 0;

  // Track remaining pieces for each player
  late List<Doll> bluePieces;
  late List<Doll> redPieces;
  ScrollController blueScrollController = ScrollController();
  ScrollController redScrollController = ScrollController();

  void initState() {
    super.initState();
    resetPieces();
    blueWins = widget.blueWins;
    redWins = widget.redWins;
  }

  void resetPieces() {
    // 9 dolls per player with repeated sizes
    final sizes = [
      DollSize.xs,
      DollSize.s,
      DollSize.m,
      DollSize.l,
      DollSize.xl,
      DollSize.xs,
      DollSize.s,
      DollSize.m,
      DollSize.l,
    ];

    bluePieces = sizes.map((s) => Doll('X', s)).toList();
    redPieces = sizes.map((s) => Doll('O', s)).toList();
  }

  bool canPlace(int index, Doll doll) {
    if (board[index].isEmpty) return true;
    return doll.size.index > board[index].last.size.index;
  }

  void place(int index, Doll doll) {
    if (winner.isNotEmpty || !canPlace(index, doll)) return;

    setState(() {
      board[index].add(doll);

      // Remove only one doll of that size
      if (doll.owner == 'X') {
        final i = bluePieces.indexWhere((d) => d.size == doll.size);
        if (i != -1) bluePieces.removeAt(i);
      } else {
        final i = redPieces.indexWhere((d) => d.size == doll.size);
        if (i != -1) redPieces.removeAt(i);
      }

      blueTurn = !blueTurn;
      winner = checkWinner();
    });
    if (winner.isNotEmpty) {
      if (winner == 'X') blueWins++;
      if (winner == 'O') redWins++;

      String resultText;
      if (winner == 'Draw') {
        resultText = 'Draw!';
      } else if (winner == 'X') {
        resultText = 'Winner: ${widget.blueName}';
      } else {
        resultText = 'Winner: ${widget.redName}';
      }

      Future.delayed(const Duration(milliseconds: 300), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultPage(
              result: resultText,
              blueName: widget.blueName,
              redName: widget.redName,
              blueWins: blueWins,
              redWins: redWins,
              winnerColor: winner == 'X' ? Colors.blue : Colors.red,
            ),
          ),
        );
      });
    }
  }

  String checkWinner() {
    final top = board.map((c) => c.isEmpty ? '' : c.last.owner).toList();

    const wins = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var w in wins) {
      if (top[w[0]] != '' && top[w[0]] == top[w[1]] && top[w[1]] == top[w[2]]) {
        return top[w[0]]; // X or O wins
      }
    }

    // Draw check: all pieces are used and no winner
    if (bluePieces.isEmpty && redPieces.isEmpty) {
      return 'Draw';
    }

    return ''; // Game still in progress
  }

  double sizeToPixels(DollSize size) {
    switch (size) {
      case DollSize.xs:
        return 32;
      case DollSize.s:
        return 42;
      case DollSize.m:
        return 52;
      case DollSize.l:
        return 62;
      case DollSize.xl:
        return 72;
    }
  }

  Widget buildDoll(Doll doll) {
    return Image.asset(
      doll.owner == 'X' ? 'assets/blue.png' : 'assets/red.png',
      width: sizeToPixels(doll.size),
      height: sizeToPixels(doll.size),
      fit: BoxFit.contain,
    );
  }

  Widget draggableDoll(Doll doll) {
    return Draggable<Doll>(
      data: doll,
      feedback: buildDoll(doll),
      childWhenDragging: Opacity(opacity: 0.3, child: buildDoll(doll)),
      child: buildDoll(doll),
    );
  }

  void reset() {
    setState(() {
      for (var c in board) c.clear();
      blueTurn = true;
      winner = '';
      resetPieces();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentOwner = blueTurn ? 'X' : 'O';
    final status = winner.isEmpty
        ? 'Turn: ${blueTurn ? widget.blueName : widget.redName}'
        : winner == 'Draw'
        ? 'Draw!'
        : 'Winner: ${winner == 'X' ? widget.blueName : widget.redName}';

    return Scaffold(
      appBar: AppBar(title: const Text('Matryoshka Tic Tac Toe')),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Text(
            status,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          // 🔴 RED TOP
          if (!blueTurn)
            Container(
              padding: const EdgeInsets.all(5),
              color: Colors.red.shade50,
              height: 100,
              child: Row(
                children: [
                  // Left button
                  IconButton(
                    icon: const Icon(Icons.arrow_left),
                    onPressed: () {
                      redScrollController.animateTo(
                        redScrollController.offset - 60,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                  // Scrollable dolls
                  Expanded(
                    child: SingleChildScrollView(
                      controller: redScrollController,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: redPieces
                            .map(
                              (doll) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: draggableDoll(doll),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  // Right button
                  IconButton(
                    icon: const Icon(Icons.arrow_right),
                    onPressed: () {
                      redScrollController.animateTo(
                        redScrollController.offset + 60,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 9,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemBuilder: (context, index) {
                return DragTarget<Doll>(
                  onWillAccept: (doll) =>
                      doll != null &&
                      doll.owner == currentOwner &&
                      canPlace(index, doll),
                  onAccept: (doll) => place(index, doll),
                  builder: (context, _, __) {
                    return Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        border: Border.all(width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: board[index].isEmpty
                            ? null
                            : buildDoll(board[index].last),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // 🔵 BLUE BOTTOM
          if (blueTurn)
            Container(
              padding: const EdgeInsets.all(5),
              color: Colors.blue.shade50,
              height: 100,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_left),
                    onPressed: () {
                      blueScrollController.animateTo(
                        blueScrollController.offset - 60,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: blueScrollController,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: bluePieces
                            .map(
                              (doll) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: draggableDoll(doll),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_right),
                    onPressed: () {
                      blueScrollController.animateTo(
                        blueScrollController.offset + 60,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ],
              ),
            ),

          const SizedBox(height: 10),
          ElevatedButton(onPressed: reset, child: const Text('Restart')),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
