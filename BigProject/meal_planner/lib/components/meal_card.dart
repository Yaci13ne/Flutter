import 'package:flutter/material.dart';

class MealCard extends StatelessWidget {
  const MealCard({super.key});

  @override
  Widget build(BuildContext context) {
    final Meal meal;
    return  Card(
      child: Container(
        child: Column(
          children: [
            Image.asset(imgpath : meal.imagePath),
            Expanded(child: Text(meal.name,style: TextStyle(),))
            ,
            Expanded(child: Row(
children: [
                  IconButton(icon: Icon(Icons.visibility), onPressed: () {}),
                Expanded(child: IconButton(onPressed: (){}, icon: Icon(Icons.delete))),],

            ))
          ],
        ),
      ),



    );
  }
}
