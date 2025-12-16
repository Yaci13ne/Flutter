import 'package:fl/models/meal.dart';
import 'package:flutter/material.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback? onDeleteMeal; 
  
  const MealCard({
    super.key, 
    required this.meal,
    this.onDeleteMeal, required Future<void> Function() deleteMealFct,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 200,
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Image.asset(
                meal.imgPath,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Text(
                  meal.name, 
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.visibility), 
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/ingredientsOfAMeal',
                        arguments: meal,
                      );
                    }
                  ),
                  IconButton(
                    onPressed: onDeleteMeal,
                    icon: Icon(Icons.delete),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}