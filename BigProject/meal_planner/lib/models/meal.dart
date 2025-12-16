import 'package:hive/hive.dart';
part 'meal.g.dart';

@HiveType(typeId: 0)

class Meal {
  @HiveField(0)

  final String name;
  @HiveField(1)
  final String imgPath;
  @HiveField(2)
  final List<String> listOfIngredient;
  @HiveField(3)
  final String? identifier;

  Meal({
    required this.name,
    required this.imgPath,
    required this.listOfIngredient,
    this.identifier,
  });
}