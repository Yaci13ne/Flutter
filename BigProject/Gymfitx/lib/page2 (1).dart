import 'package:flutter/material.dart';
import 'page3.dart';
import 'user_service.dart';

String userName = ""; // Global variable

class nameScreen extends StatefulWidget {
  const nameScreen({super.key});

  @override
  nameScreenState createState() => nameScreenState();
}

class nameScreenState extends State<nameScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height, // Full-screen height
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/1.png"),
            fit: BoxFit.cover, // Full-screen background
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView( // Make sure UI doesn't overflow
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Image.asset(
                          "pictures/GymFitXnutrition-removebg-preview.png",
                          height: 150,
                          width: 200,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 60),
                        Text(
                          "What is Your Name?",
                          style: TextStyle(
                            fontSize: 30,
                            fontFamily: 'bolditalic',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: TextField(
                            controller: _nameController,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.9),
                              hintText: "Enter your name",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // **Bottom Navigation Buttons**
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // **Previous Button**
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        minimumSize: Size(100, 40),
                        backgroundColor: Colors.grey.shade900,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.arrow_back, color: Color(0xFF47DF7C), size: 20),
                          SizedBox(width: 5),
                          Text(
                            "Previous",
                            style: TextStyle(
                              color: Color(0xFF47DF7C),
                              fontSize: 16,
                              fontFamily: 'interregular',
                            ),
                          ),
                        ],
                      ),
                    ),

                    // **Next Button**
                    ElevatedButton(
                      onPressed: () {
                        if (_nameController.text.isEmpty) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Error"),
                                content: Text("Please enter your name."),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("OK"),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          UserService().setUserName(_nameController.text);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => birthScreen()),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        minimumSize: Size(100, 40),
                        backgroundColor: Colors.grey.shade900,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "Next",
                            style: TextStyle(
                              color: Color(0xFF47DF7C),
                              fontSize: 16,
                              fontFamily: 'interregular',
                            ),
                          ),
                          SizedBox(width: 5),
                          Image.asset(
                            "pictures/carbon_nextright.png",
                            width: 25,
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
