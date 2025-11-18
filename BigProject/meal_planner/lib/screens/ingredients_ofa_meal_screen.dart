import 'package:flutter/material.dart';

class IngredientsOfaMealScreen extends StatelessWidget {
  const IngredientsOfaMealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [IconButton(onPressed: (){}, icon: Icon(Icons.exit_to_app))],
      
      title: Center(child: Text("Ingredients of the meal ${currentMeal.name}",style: TextStyle(),),
      
      ),
    
        
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: currentMeal.listOfIngredients.length,
        itemBuilder: (context, index) {
          return Card(
            color:Colors.amber,
            child: ListTile(
              title: Text(currentMeal.listOfIngredients[index],style: TextStyle(),),
            ),
          );
        },
      ),







    );
  }
}