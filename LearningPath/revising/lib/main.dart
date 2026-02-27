import 'package:flutter/material.dart';
import 'package:revising/box.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Box> quotes = [
    Box(number: 1, name: 'Tomatoes'),
    Box(number: 2, name: 'strawberry'),
    Box(number: 3, name: 'potatoes'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: quotes
              .map(
                (e) => CardClass(
                  quotes: e,
                  delete: (){
                    setState(() {
                      quotes.remove(e);
                    });

                  },
    
                
          
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class CardClass extends StatelessWidget {
  final dynamic quotes;
final VoidCallback delete;

  CardClass({required this.quotes, required this.delete});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(quotes.name),

          SizedBox(height: 10),

          Image.asset(
            'assets/picture${quotes.number}.jpg',
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
          FloatingActionButton(
            onPressed: delete,
            child: Icon(Icons.delete, size: 34),
          ),
        ],
      ),
    );
  }
}
