
import 'package:flutter/material.dart';
import 'package:meal_planner/components/my_buttons.dart';
import 'package:meal_planner/components/my_textfield.dart';

class AddNewMealScreen extends StatefulWidget {
  const AddNewMealScreen({super.key});

  @override
  State<AddNewMealScreen> createState() => _AddNewMealScreenState();
}

class _AddNewMealScreenState extends State<AddNewMealScreen> {

  TextEditingController TF = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adding a New Meal'),
      ),
      body: SingleChildScrollView(
        child:Container(
          child: Column(
            children: [
MyTextfield(TFHintText: "Enter meals name:", TFIcon: Icon(Icons.restaurant), TFController: TF)       ,
MyTextfield(TFHintText: "Enter image path:", TFIcon: Icon(Icons.image), TFController: TF)
,
Card(child:Column(children: [Row(children: [Expanded(child: Text("List of ingredients"))
,IconButton(onPressed: (){}, icon: Icon(Icons.add)),
IconButton(onPressed: (){}, icon: Icon(Icons.delete))



],)],))  ,
MyElevatedButton(buttonLabel: "Add the meal", onPressedFct: (){}),

ListView.builder(shrinkWrap: true,
itemCount: listOfMyTextFields.length,
itemBuilder: (context, index) {
  return listOfMyTextFields[index];
  })


)



],
          
          
          
          
          ),

        )
      ),
    );
  }
}