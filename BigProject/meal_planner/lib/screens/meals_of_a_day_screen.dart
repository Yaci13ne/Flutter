import 'package:flutter/material.dart';
import 'package:meal_planner/components/meal_card.dart';

class MealsOfADayScreen extends StatefulWidget {
  const MealsOfADayScreen({super.key});

  @override
  State<MealsOfADayScreen> createState() => _MealsOfADayScreenState();
}

class _MealsOfADayScreenState extends State<MealsOfADayScreen> {
  @override
  Widget build(BuildContext context) {
final MealsOfADay dayAndItsListOfMeals;



    return Scaffold(
      appBar: AppBar(actions: [IconButton(onPressed: (){}, icon: Icon(Icons.exit_to_app
      ,
      title: Center(child: Text("Details page for ${dayAndItsListOfMeals.day}",style: TextStyle(),),
      GridView.builder(itemCount: dayAndItsListOfMeals.listOfMealsForAday.legnth,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3), itemBuilder: (context, i) {
        return MealCard(meal:dayAndItsListOfMeals.listOfMealsForAday[i] );
      }

      )
      )],),
    
    
    
    
    );
  }
}
