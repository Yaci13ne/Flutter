import 'package:fl/models/meal.dart';
import 'package:flutter/material.dart';

class IngredientsOfaMealScreen extends StatelessWidget {
  const IngredientsOfaMealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentMeal =
        ModalRoute.of(context)?.settings.arguments
            as Meal; 

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (Route<dynamic> route) => false,
              );
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
        title: Center(
          child: Text(
            "Ingredients of the meal ${currentMeal.name}",
            style: TextStyle(),
          ),
        ),
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: currentMeal.listOfIngredient.length, 
        itemBuilder: (context, index) {
          return Card(
            color: Colors.amber,
            child: ListTile(
              title: Text(
                currentMeal.listOfIngredient[index], 
                style: TextStyle(),
              ),
            ),
          );
        },
      ),
    );
  }
}
