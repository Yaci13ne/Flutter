import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: Profile()));
}

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 56, 66, 69),
      appBar: AppBar(
        title: Text(
          'The profile',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        titleTextStyle: TextStyle(
          color: const Color.fromARGB(255, 255, 255, 255),
        ),
        centerTitle: true,
        backgroundColor: Colors.black45,


        leading: IconButton(icon: Icon(Icons.menu ,color: Colors.white, ), onPressed: () {  },
        
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage("assets/yacine.jpg"),
            ),
            Divider(
              color: Colors.grey, // لون الخط
              thickness: 4, // سمك الخط
              indent: 20, // مسافة بادئة من اليسار
              endIndent: 20, // مسافة من اليمين
              height: 40, // المسافة العمودية الكلية
            ),

            Row(
              children: [
                Text(
                  'Name:',
                  style: TextStyle(
                    color: const Color.fromARGB(38, 0, 0, 0),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Dalachi Yacine',
                  style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                ),
              ],
            ),

            SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.email),
                SizedBox(width: 5),
                Text(
                  'Address:',
                  style: TextStyle(
                    color: const Color.fromARGB(38, 0, 0, 0),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'dalachiyacinetlm@gmail.com',
                  style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
