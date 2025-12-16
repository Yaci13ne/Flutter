import 'package:fl/models/meal.dart';
import 'package:fl/models/meals_of_a_day_meals.dart';
import 'package:fl/screens/LoginScreen.dart';
import 'package:fl/screens/SignUpScreen.dart';
import 'package:flutter/material.dart';

import 'package:fl/screens/home_screen.dart';
import 'package:fl/screens/meals_of_a_day_screen.dart';
import 'package:fl/screens/add_new_meal_screen.dart';
import 'package:fl/screens/ingredients_ofa_meal_screen.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async{
 

  WidgetsFlutterBinding.ensureInitialized(); 
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
await Hive.initFlutter(); 
Hive.registerAdapter(MealAdapter()); 
Hive.registerAdapter(MealsOfADayAdapter()); 
    runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  



  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    
    return MaterialApp(
      
      title: 'Meal Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const LoginScreen(), // LoginScreen is the first page
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const Signupscreen(),
        '/home': (context) => const HomeScreen(),
        '/mealsOfADay': (context) => const MealsOfADayScreen(),
        '/addNewMeal': (context) => const AddNewMealScreen(),
        '/ingredientsOfAMeal': (context) => const IngredientsOfaMealScreen(),
      },
    );
 
  }
}