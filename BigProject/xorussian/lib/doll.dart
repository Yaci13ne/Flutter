import 'package:xorussian/main.dart';

class Doll {
  final String owner; // 'X' or 'O'
  final DollSize size;

  Doll(this.owner, this.size);

  Map<String, dynamic> toJson() => {
        'owner': owner,
        'size': size.index,
      };

  factory Doll.fromJson(Map json) => Doll(
        json['owner']?.toString() ?? 'X',
        DollSize.values[(json['size'] as num?)?.toInt() ?? 0],
      );
}
