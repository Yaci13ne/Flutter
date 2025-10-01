import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'cardit.dart';

void main() {
  runApp(
    MaterialApp(
      home: Home(),
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 93, 38, 220),
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: 24, color: Colors.blue),
          bodyLarge: TextStyle(fontFamily: 'Lemonada',
            fontSize: 40,
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
          bodySmall: TextStyle(
            fontSize: 18,
            color: Colors.blue,
          ),
        ),
        cardColor: const Color.fromARGB(255, 93, 89, 89),
        scaffoldBackgroundColor: Colors.blue
      ),
    ),
  );
}


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            color: Theme.of(context).scaffoldBackgroundColor,
            fontFamily: 'RethinkSans',
            fontWeight: FontWeight.bold,
            fontSize: 45,
          ),
        ),
        centerTitle: true,
        backgroundColor:Theme.of(context).primaryColor,
      ),

      body: Padding(
        padding: const EdgeInsets.all(44.0),
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 40),
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(
                  'https://images.unsplash.com/photo-1758550445758-165aeab5b26e?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                ),
              ),
              SizedBox(height: 10),

              Textfill(),
              Text(
                'مبرمج مبدتئ',
                style: TextStyle(
                  color: const Color.fromARGB(255, 180, 174, 174),
                  fontFamily: 'Lemonada',
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 20),
              cardit(icon: 'Google', text: 'dalachiyacinetlm@gmail.com'),
              cardit(icon: 'smartphone', text: '0540485958'),

              SizedBox(height: 15),
    
            ],
          ),
        ),
      ),
    );
  }
}

class Textfill extends StatelessWidget {
  const Textfill({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      'ياسين دلاشي',
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}


