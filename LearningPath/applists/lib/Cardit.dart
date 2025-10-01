import 'package:flutter/material.dart';

class Cardit extends StatelessWidget {
  String quote;
  String author;
 final VoidCallback delete;

  Cardit({required this.quote, required this.author,required this.delete});
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(15, 15, 15, 0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              author,
              style: TextStyle(
                color: const Color.fromARGB(255, 0, 0, 0),
                backgroundColor: Colors.amberAccent,
                letterSpacing: 3,
              ),
            ),
            SizedBox(height: 10),
            Text(
              quote,
              style: TextStyle(color: const Color.fromARGB(255, 80, 60, 60)),
            ),

            TextButton.icon(
              onPressed: delete,

              icon: Icon(Icons.delete, color: Colors.red),
              label: Text('delete it'),
            ),
          ],
        ),
      ),
    );
  }
}
