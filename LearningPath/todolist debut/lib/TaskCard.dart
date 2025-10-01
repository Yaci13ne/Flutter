import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  String task;
  VoidCallback delete;
  TaskCard({required this.task, required this.delete});

  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(task),
            TextButton.icon(
              onPressed: delete,
              label: Text('delete'),
              icon: Icon(Icons.delete),
            ),

            TextButton.icon(
              onPressed: () {
                delete(); 
                print('task finish');
              },
              label: Text('Finished'),
              icon: Icon(Icons.check),
            ),
          ],
        ),
      ),
    );
  }
}
