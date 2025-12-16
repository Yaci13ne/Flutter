import 'meal.dart';
import 'package:hive/hive.dart';
part 'meals_of_a_day_meals.g.dart';

@HiveType(typeId: 1)
class MealsOfADay {
  @HiveField(0)
  final String day;
  @HiveField(1)
  List<Meal> listOfMealsForADay;
  @HiveField(2)

  MealsOfADay({
    required this.day,
    required this.listOfMealsForADay,
  });
}