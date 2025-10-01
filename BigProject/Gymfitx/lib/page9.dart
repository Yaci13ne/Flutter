import 'package:flutter/material.dart';


import 'package:flutter/foundation.dart';



import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Me.dart';
import 'basket_manager.dart';
import 'fabtab.dart';
import 'home.dart';
import 'theme_notifier.dart';
import 'user_service.dart';


class WelcomeScreen extends StatelessWidget {
  final String userName;
  final int dailyCalories;
  final int proteinGoal;
  final int fatGoal;
  final int carbsGoal;
  final int age;  // Add this
final int weight;
final int height;

  const WelcomeScreen({
    super.key,
    required this.userName,
    required this.dailyCalories,
    required this.proteinGoal,
    required this.fatGoal,
    required this.carbsGoal,
        required this.age,  // Add this
        required this.weight,  // Add this
        required this.height,  // Add this

  });
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("pictures/firstpage.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 60.0),
            child: Text(
              "Welcome, ${UserService().userName}!",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                fontFamily: 'bolditalic',
              ),
            ),
          ),
          const SizedBox(height: 60),
          Image.asset(
            "pictures/every.png",
            height: 330,
            fit: BoxFit.contain,
          ),
          ElevatedButton(
            onPressed: () async {
              if (kDebugMode) {
                await clearSharedPreferences();
              }
              
              // Create the objects first
              final nutritionGoals = NutritionGoals(
                age: age,
                height: height,
                weight: weight,
                dailyCalories: dailyCalories,
                proteinGoal: proteinGoal,
                fatGoal: fatGoal,
                carbsGoal: carbsGoal,
              );
              
              final details = Details(
                age: age,
                height: height,
                weight: weight,
                // add any other parameters needed for Details
              );
              
              print('Received goals: $dailyCalories, $proteinGoal, $fatGoal, $carbsGoal');
              print('Age received: $age');
              
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => MultiProvider(
                    providers: [
                      ChangeNotifierProvider(create: (context) => BasketManager()),
                      ChangeNotifierProvider(create: (context) => ThemeNotifier()),
                      // Provide both nutritionGoals and details
                      Provider.value(value: nutritionGoals),
                      Provider.value(value: details),
                    ],
                    child: FabTabs(
                      nutritionGoals: nutritionGoals,
                      // If FabTabs needs details too, add it here
                      // details: details,
                    ),
                  ),
                ),
                (Route<dynamic> route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              backgroundColor: const Color.fromARGB(255, 71, 223, 124),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 5,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Get Started !",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'bolditalic',
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: 10),
                ImageIcon(
                  AssetImage('pictures/next.png'),
                  size: 20,
                  color: Colors.black,
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    ),
  );
}
}


// Reuse MyApp from main.dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: FabTabs(),
    );
  }
}

// Helper function to clear SharedPreferences
Future<void> clearSharedPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  debugPrint('SharedPreferences cleared for debugging');
}