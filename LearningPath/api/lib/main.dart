import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

void main() {
  runApp(MaterialApp(home: TryingApi()));
}

class TryingApi extends StatefulWidget {
  const TryingApi({super.key});

  @override
  State<TryingApi> createState() => _TryingApiState();
}

class _TryingApiState extends State<TryingApi> {
  String data = "Loading...";

  void Time() async {
    Response response = await get(
      Uri.parse("https://jsonplaceholder.typicode.com/todos/1"),
    );
    Map timeit = jsonDecode(response.body);
    int str = timeit['userId'];
    print('user id is :${str + 4} ');

    String mot = '7';
    int hi = int.parse(mot);
    print('mot ${int.parse(mot) + 2}');
  }

  @override
  void initState() {
    super.initState();
    Time();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(data)));
  }
}
