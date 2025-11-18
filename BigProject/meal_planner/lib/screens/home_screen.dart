import 'package:flutter/material.dart';
import 'package:meal_planner/components/week_days_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});




  @override
  Widget build(BuildContext context) {
    List<String> days = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ];





    return Scaffold(
appBar: AppBar(centerTitle: true,actions: [IconButton(onPressed: (){}, icon: Icon(Icons.exit_to_app))],title: Center(child: Text("Home Page ",style: TextStyle(),),),
) ,
body: ListView.builder(
  scrollDirection: Axis.vertical,
  shrinkWrap: true,
  itemCount: days.length,
  itemBuilder: (context, index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: WeekDaysCard(day: days[index]),
    );
  }
  
),



    );
  }
}