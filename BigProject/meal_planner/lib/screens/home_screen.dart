import 'package:fl/components/week_days_card.dart';
import 'package:fl/models/meals_of_a_day_meals.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<MealsOfADay> dayMealsBox; 
  List<String> weekDays = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
  ];

  @override
  void initState() {
    super.initState();
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    dayMealsBox = await Hive.openBox<MealsOfADay>('MealsBDD');

    if (dayMealsBox.isEmpty) {
      for (String day in weekDays) {
        await dayMealsBox.put(
          day,
          MealsOfADay(day: day, listOfMealsForADay: []),
        );
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    dayMealsBox.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
        title: Center(child: Text("Home Page")),
      ),
      body: ValueListenableBuilder<Box<MealsOfADay>>(
        valueListenable: dayMealsBox.listenable(),
        builder: (context, box, _) {
          return ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: weekDays.length,
            itemBuilder: (context, index) {
              String day = weekDays[index];
              MealsOfADay? dayMeals = box.get(day);

              if (dayMeals == null) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("No data for $day"),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: WeekDaysCard(dayAndItsMeals: dayMeals),
              );
            },
          );
        },
      ),
    );
  }
}
