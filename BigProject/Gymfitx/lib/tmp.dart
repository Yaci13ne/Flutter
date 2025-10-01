import 'package:flutter/material.dart';
//import 'package:project/page2.dart';

void main() {
  runApp(GymFitXApp());
}

class GymFitXApp extends StatelessWidget {
  const GymFitXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GenderSelectionScreen(),
    );
  }
}

class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({super.key});

  @override
  _GenderSelectionScreenState createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String? _selectedGender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height, // Full-screen height
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("pictures/bmipage.png"),
            fit: BoxFit.cover, // Full-screen background
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
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

                    // **Title**
                    Text(
                      "What is Your Gender?",
                      style: TextStyle(
                        fontSize: 30,
                        fontFamily: 'bolditalic',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),

              Spacer(), // Pushes buttons to the bottom

              // **Bottom Navigation Buttons**
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // **Previous Button**
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        fixedSize: Size(110, 40),
                        backgroundColor: Colors.grey.shade900,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Image.asset("pictures/carbon_nextleft.png",
                              width: 20, height: 20),
                          SizedBox(width: 5),
                          Text("Previous",
                              style: TextStyle(
                                color: Color(0xFF47DF7C),
                                fontSize: 16,
                                fontFamily: 'interregular',
                              )),
                        ],
                      ),
                    ),

                    // **Next Button**
                    ElevatedButton(
                      onPressed: () {
                        if (_selectedGender != null) {
                          print("Selected Gender: $_selectedGender");
                        } else {
                          print("Please select your gender.");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        minimumSize: Size(100, 40),
                        backgroundColor: Colors.grey.shade900,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text("Next",
                              style: TextStyle(
                                color: Color(0xFF47DF7C),
                                fontSize: 16,
                                fontFamily: 'interregular',
                              )),
                          SizedBox(width: 5),
                          Image.asset("pictures/carbon_nextright.png",
                              width: 25, height: 20),
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
