import 'package:flutter/material.dart' ;
import 'package:meal_planner/screens/home_screen.dart';
void main () { runApp (MyApp() ); }
class MyApp extends StatelessWidget {
@override
Widget build (BuildContext context) {



return MaterialApp (debugShowCheckedModeBanner: false,
title: 'My Meal Planner ',
theme: ThemeData (appBarTheme: const AppBarTheme (
backgroundColor: Colors.black,
titleTextStyle: TextStyle (color: Colors.orange,
fontSize: 17, fontWeight: FontWeight.bold,),
iconTheme: IconThemeData (color: Colors.orange),),
),
home: HomeScreen (    
  
  

    
    
    ),
);} }

