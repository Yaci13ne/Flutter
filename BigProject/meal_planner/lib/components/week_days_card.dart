import 'package:fl/models/meal.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:fl/models/meals_of_a_day_meals.dart';

class WeekDaysCard extends StatelessWidget {
  final MealsOfADay dayAndItsMeals;
  
  const WeekDaysCard({super.key, required this.dayAndItsMeals});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: 150,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        color: Colors.amber,
        borderRadius: BorderRadius.all(Radius.circular(10))
      ),
      child: Column(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text(
                  dayAndItsMeals.day,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () async {
                    final dayMealsBox = await Hive.openBox<MealsOfADay>('MealsBDD');
                    MealsOfADay? dayData = dayMealsBox.get(dayAndItsMeals.day);
                    if (dayData != null) {
                      Navigator.pushNamed(
                        context,
                        '/mealsOfADay',
                        arguments: dayData,
                      );
                    }
                  },
                  icon: Icon(Icons.visibility),
                  color: Colors.orange,
                ),
                SizedBox(width: 20),
                IconButton(
                  onPressed: () async {
                    final dayMealsBox = await Hive.openBox<MealsOfADay>('MealsBDD');
                var   newMeal =await 
                    Navigator.pushNamed(
                      context,
                      '/addNewMeal',
                      arguments: dayAndItsMeals,
                    ) as Meal;

                    dayAndItsMeals.listOfMealsForADay.add(newMeal);
                    dayMealsBox.put(dayAndItsMeals.day, dayAndItsMeals);             },
                  icon: Icon(Icons.add),
                  color: Colors.black,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}