import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: Telegram()));
}

class Telegram extends StatefulWidget {
  const Telegram({super.key});

  @override
  State<Telegram> createState() => _TelegramState();
}

class _TelegramState extends State<Telegram> {
  int increase = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Telegram'),
        leading: Icon(Icons.menu),
        backgroundColor: Color(0xFF0088CC), // #0088CC
        foregroundColor: Colors.white, // All text/icons white

        actions: [IconButton(icon: Icon(Icons.search), onPressed: () {})],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            increase++;
          });
        },
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(height: 10),
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://plus.unsplash.com/premium_photo-1689568126014-06fea9d5d341?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8cHJvZmlsZXxlbnwwfHwwfHx8MA%3D%3D',
                  ),
                  radius: 35,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // align to the left

                  children: [
                    Text(
                      'ali',
                      style: TextStyle(
                        fontSize: 22,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Login code 45588. do not give it to anyone...'),
                  ],
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('14:45'),
                    CircleAvatar(
                      radius: 15, // size of the circle
                      backgroundColor: Colors.green, // circle color
                      child: Text(
                        '$increase',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
