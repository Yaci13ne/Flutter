import 'package:fl/components/my_buttons.dart';
import 'package:fl/components/my_textfield.dart';
import 'package:fl/models/meal.dart';
import 'package:fl/models/meals_of_a_day_meals.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';

class AddNewMealScreen extends StatefulWidget {
  const AddNewMealScreen({super.key});

  @override
  State<AddNewMealScreen> createState() => _AddNewMealScreenState();
}

class _AddNewMealScreenState extends State<AddNewMealScreen> {
  GlobalKey<FormState> keyFormState = GlobalKey<FormState>();
  
  TextEditingController nameController = TextEditingController();
  TextEditingController imgPathController = TextEditingController();
  List<TextEditingController> ingredientControllers = [TextEditingController()];
  List<Widget> listOfMyTextFields = [];

  @override
  void initState() {
    super.initState();
    listOfMyTextFields = [
      MyTextfield(
        TFHintText: "Enter an ingredient",
        TFIcon: Icon(Icons.food_bank),
        TFController: ingredientControllers[0],
        TFValidator: (val) => val!.isEmpty ? "Can't be empty" : null,
      )
    ];
  }

  void addIngredientField() {
    setState(() {
      TextEditingController newController = TextEditingController();
      ingredientControllers.add(newController);
      listOfMyTextFields.add(
        MyTextfield(
          TFHintText: "Enter an ingredient",
          TFIcon: Icon(Icons.food_bank),
          TFController: newController,
          TFValidator: (val) => val!.isEmpty ? "Can't be empty" : null,
        )
      );
    });
  }

  void removeIngredientField(int index) {
    if (ingredientControllers.length > 1) {
      setState(() {
        ingredientControllers.removeAt(index);
        listOfMyTextFields.removeAt(index);
      });
    }
  }

  void displayAToast() {
    Fluttertoast.showToast(
      msg: "Your entries are not valid",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayAndItsMeals = ModalRoute.of(context)?.settings.arguments as MealsOfADay;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adding a New Meal'),
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
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(8),
          child: Form(
            key: keyFormState,
            child: Column(
              children: [
                MyTextfield(
                  TFHintText: "Enter meal's name:",
                  TFIcon: Icon(Icons.restaurant),
                  TFController: nameController,
                  TFValidator: (val) => val!.isEmpty ? "Can't be empty" : null,
                ),
                SizedBox(height: 10),
                MyTextfield(
                  TFHintText: "Enter image path:",
                  TFIcon: Icon(Icons.image),
                  TFController: imgPathController,
                  TFValidator: (val) => val!.isEmpty ? "Can't be empty" : null,
                ),
                SizedBox(height: 10),
                Card(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("List of ingredients", style: TextStyle(fontWeight: FontWeight.bold)),
                            )
                          ),
                          IconButton(
                            onPressed: addIngredientField, 
                            icon: Icon(Icons.add)
                          ),
                        ],
                      ),
                      ...listOfMyTextFields.asMap().entries.map((entry) {
                        int index = entry.key;
                        return Row(
                          children: [
                            Expanded(child: entry.value),
                            if (ingredientControllers.length > 1)
                              IconButton(
                                onPressed: () => removeIngredientField(index), 
                                icon: Icon(Icons.delete),
                                color: Colors.red,
                              ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
                SizedBox(height: 20),
MyElevatedButton(
  buttonLabel: "Add the meal", 
  onPressedFct: () async {
    if (keyFormState.currentState!.validate()) {
      List<String> ingredients = ingredientControllers
          .map((controller) => controller.text)
          .toList();
      
      Meal newMeal = Meal(
        name: nameController.text,
        imgPath: imgPathController.text,
        listOfIngredient: ingredients,
      );
      

      
      Navigator.pop(context,newMeal);
    } else {
      displayAToast();
    }
  }
)
              ],
            ),
          ),
        ),
      ),
    );
  }
}