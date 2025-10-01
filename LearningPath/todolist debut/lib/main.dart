import 'package:flutter/material.dart';
import 'TaskCard.dart';

void main() {
  runApp(MaterialApp(home: TodoList()));
}

class TodoList extends StatefulWidget {
  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  List<String> tasks = [
    'Do Homework',
    "Go for a walk",
    "Read a book",
    'Sleep at 22:00',
  ].toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Todo List')),

      body: Column(
        children: tasks.map(
          (e) => TaskCard(
            task: e,
            delete: () {
              setState(() {
                tasks.remove(e);
              });
            },
          ),
        ).toList(),
      ),
    );
  }
}
