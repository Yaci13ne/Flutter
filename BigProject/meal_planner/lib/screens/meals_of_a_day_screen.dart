import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:fl/components/meal_card.dart';
import 'package:fl/models/meals_of_a_day_meals.dart';
import 'package:fl/models/meal.dart';

class MealsOfADayScreen extends StatefulWidget {
  const MealsOfADayScreen({super.key});

  @override
  State<MealsOfADayScreen> createState() => _MealsOfADayScreenState();
}

class _MealsOfADayScreenState extends State<MealsOfADayScreen> {
  late MealsOfADay dayAndItsListOfMeals;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dayAndItsListOfMeals = ModalRoute.of(context)?.settings.arguments as MealsOfADay;
  }

  Future<void> deleteAMeal(Meal mealToRemove, MealsOfADay dayData) async {
    setState(() {
      dayData.listOfMealsForADay.remove(mealToRemove);
    });
    
    final dayMealsBox = await Hive.openBox<MealsOfADay>('MealsBDD');
    await dayMealsBox.put(dayData.day, dayData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context, 
                '/login',
                (Route<dynamic> route) => false
              );
            }, 
            icon: Icon(Icons.exit_to_app)
          )
        ],
        title: Center(
          child: Text("Details page for ${dayAndItsListOfMeals.day}"),
        ),
      ),
      body: GridView.builder(
        itemCount: dayAndItsListOfMeals.listOfMealsForADay.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, i) {
          return MealCard(
            meal: dayAndItsListOfMeals.listOfMealsForADay[i],
            deleteMealFct: () => deleteAMeal(
              dayAndItsListOfMeals.listOfMealsForADay[i],
              dayAndItsListOfMeals
            ),
          );
        },
      ),
    );
  }
}