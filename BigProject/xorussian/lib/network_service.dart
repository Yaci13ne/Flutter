import 'dart:convert';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:xorussian/doll.dart';
import 'package:xorussian/main.dart';

class RoomState {
  final String status; // 'waiting', 'playing', 'finished'
  final String joinCode;
  final String hostName;
  final String guestName;
  final List<List<Doll>> board;
  final bool blueTurn; // host is blue, guest is red
  final String winner;
  final List<Doll> bluePieces;
  final List<Doll> redPieces;
  final bool hostRematch;
  final bool guestRematch;

  RoomState({
    required this.status,
    required this.joinCode,
    required this.hostName,
    required this.guestName,
    required this.board,
    required this.blueTurn,
    required this.winner,
    required this.bluePieces,
    required this.redPieces,
    required this.hostRematch,
    required this.guestRematch,
  });

  static List<Doll> _parsePieces(dynamic rawData) {
    if (rawData == null) return [];
    if (rawData is Iterable) {
      return rawData
          .where((d) => d != null)
          .map((d) => Doll.fromJson(d as Map))
          .toList();
    } else if (rawData is Map) {
      // Firebase returns JSON arrays as Maps with integer string keys ("0", "1", ...).
      // Sort by key so the piece order is always stable and matches what was written.
      final entries = rawData.entries.toList()
        ..sort((a, b) {
          final ai = int.tryParse(a.key.toString()) ?? 0;
          final bi = int.tryParse(b.key.toString()) ?? 0;
          return ai.compareTo(bi);
        });
      return entries
          .where((e) => e.value != null)
          .map((e) => Doll.fromJson(e.value as Map))
          .toList();
    }
    return [];
  }

  factory RoomState.fromJson(Map json) {
    List<List<Doll>> parsedBoard = List.generate(9, (_) => []);

    try {
      if (json['board'] != null) {
        var rawBoard = json['board'];

        // Handle the new bulletproof JSON String format
        if (rawBoard is String) {
          List<dynamic> decodedList = jsonDecode(rawBoard);
          for (int i = 0; i < decodedList.length && i < 9; i++) {
            parsedBoard[i] = _parsePieces(decodedList[i]);
          }
        }
        // Backward compatibility for old Iterable format
        else if (rawBoard is Iterable) {
          int i = 0;
          for (var col in rawBoard) {
            if (i < 9 && col != null) {
              parsedBoard[i] = _parsePieces(col);
            }
            i++;
          }
        }
        // Backward compatibility for old Map format
        else if (rawBoard is Map) {
          rawBoard.forEach((key, col) {
            String keyStr = key.toString();
            if (keyStr.startsWith('c')) keyStr = keyStr.substring(1);
            int index = int.tryParse(keyStr) ?? -1;
            if (index >= 0 && index < 9 && col != null) {
              parsedBoard[index] = _parsePieces(col);
            }
          });
        }
      }
    } catch (e) {
      print('Board Parse Error: $e');
    }

    return RoomState(
      status: json['status']?.toString() ?? 'waiting',
      joinCode: json['joinCode']?.toString() ?? '',
      hostName: json['hostName']?.toString() ?? '',
      guestName: json['guestName']?.toString() ?? '',
      blueTurn: json['blueTurn'] == true,
      winner: json['winner']?.toString() ?? '',
      board: parsedBoard,
      bluePieces: _parsePieces(json['bluePieces']),
      redPieces: _parsePieces(json['redPieces']),
      hostRematch: json['hostRematch'] == true,
      guestRematch: json['guestRematch'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    List<List<Map<String, dynamic>>> encodedBoard = [];
    for (int i = 0; i < 9; i++) {
      encodedBoard.add(board[i].map((d) => d.toJson()).toList());
    }
    String ultimateSafeBoardString = jsonEncode(encodedBoard);

    return {
      'status': status,
      'joinCode': joinCode,
      'hostName': hostName,
      'guestName': guestName,
      'blueTurn': blueTurn,
      'winner': winner,
      'board': ultimateSafeBoardString,
      'bluePieces': bluePieces.map((d) => d.toJson()).toList(),
      'redPieces': redPieces.map((d) => d.toJson()).toList(),
      'hostRematch': hostRematch,
      'guestRematch': guestRematch,
    };
  }
}

class NetworkService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  String generateRoomCode() {
    return (100000 + Random().nextInt(900000)).toString();
  }

  Future<String> createRoom(
    String hostName,
    List<Doll> initialBlue,
    List<Doll> initialRed,
  ) async {
    final code = generateRoomCode();
    final ref = _db.ref('rooms/$code');
    await ref.set({
      'status': 'waiting',
      'joinCode': code,
      'hostName': hostName,
      'guestName': '',
      'blueTurn': true,
      'winner': '',
      // Initial board is empty, so we omit it completely to avoid Firebase SDK native validation exceptions
      'bluePieces': initialBlue.map((d) => d.toJson()).toList(),
      'redPieces': initialRed.map((d) => d.toJson()).toList(),
      'hostRematch': false,
      'guestRematch': false,
    });
    return code;
  }

  Future<bool> joinRoom(String code, String guestName) async {
    final ref = _db.ref('rooms/$code');
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map;
      if (data['status'] == 'waiting') {
        await ref.update({'status': 'playing', 'guestName': guestName});
        return true;
      }
    }
    return false;
  }

  Stream<RoomState?> streamRoom(String code) {
    return _db.ref('rooms/$code').onValue.map((event) {
      if (event.snapshot.value == null) return null;
      return RoomState.fromJson(event.snapshot.value as Map);
    });
  }

  Future<void> updateGameState(String code, RoomState state) async {
    await _db.ref('rooms/$code').set(state.toJson());
  }

  Future<void> removeRoom(String code) async {
    await _db.ref('rooms/$code').remove();
  }

  Future<void> requestRematch(String code, bool isHost) async {
    await _db.ref('rooms/$code').update({
      isHost ? 'hostRematch' : 'guestRematch': true,
    });
  }

  Future<void> restartRoom(String code) async {
    final initialBlue = List.generate(
      9,
      (i) => Doll('X', DollSize.values[i % 5]),
    );
    final initialRed = List.generate(
      9,
      (i) => Doll('O', DollSize.values[i % 5]),
    );

    await _db.ref('rooms/$code').update({
      'status': 'playing',
      'board':
          null, // Explicitly pass null to the Firebase DB to cleanly wipe the existing node!
      'bluePieces': initialBlue.map((d) => d.toJson()).toList(),
      'redPieces': initialRed.map((d) => d.toJson()).toList(),
      'blueTurn': true,
      'winner': '',
      'hostRematch': false,
      'guestRematch': false,
    });
  }
}
