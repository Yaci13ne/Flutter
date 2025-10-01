import 'package:flutter/material.dart';
import 'page8.dart';
import 'page6.dart';

class ActivityRate extends StatefulWidget {
  final String gender;
  final int weight;
  final int height;
  final int age;  // Add this

  const ActivityRate({
    super.key,
    required this.gender,
    required this.weight,
    required this.height,
    required this.age,  // Add this
  });

  @override
  ActivityRateState createState() => ActivityRateState();
}

class ActivityRateState extends State<ActivityRate> {
  String _selectedActivity = "Choose How Often Are You Active"; // Default value
  bool _isDropdownOpen = false; // Track dropdown state

  List<Map<String, String>> activityLevels = [
    {
      "title": "Not Very Active",
      "subtitle": "I Sit A Lot During The Day (i don't train at all)",
    },
    {
      "title": "Lightly Active",
      "subtitle": "I walk or move occasionally(i train 1-2 times a week)",
    },
    {
      "title": "Moderately Active",
      "subtitle": "I have a balanced routine(i train 2-4 a week)",
    },
    {
      "title": "Highly Active",
      "subtitle": "Fitness is my lifestyle(i train 4-6 a week)",
    },
  ];

  @override
  Widget build(BuildContext context) {
    print('[ActivityRate] Received age: ${widget.age}, weight: ${widget.weight}, height: ${widget.height}');
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/6.png"),
            fit: BoxFit.cover,
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
                    SizedBox(height: 90),

                    // **Title**
                    Text(
                      "What is Your Activity Rate?",
                      style: TextStyle(
                        fontSize: 29,
                        fontFamily: 'bolditalic',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),

                    // **Rounded Dropdown Button**
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isDropdownOpen = !_isDropdownOpen;
                        });
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(25), // More rounded corners
                          border: Border.all(color: Colors.green, width: 2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedActivity,
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            ),
                            Icon(_isDropdownOpen
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),

                    // **Dropdown Items**
                    if (_isDropdownOpen)
                      Container(
                        margin: EdgeInsets.only(top: 5),
                        padding: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(20), // More rounded corners
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: Column(
                          children: activityLevels.map((level) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedActivity = level["title"]!;
                                  _isDropdownOpen = false;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      level["title"]!,
                                      style: TextStyle(
                                          fontFamily: 'rethinksansextrabold',
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      level["subtitle"]!,
                                      style: TextStyle(
                                          fontFamily: 'rethinksansregular',
                                          fontSize: 14,
                                          color: Colors.grey[700]),
                                    ),
                                    Divider(
                                      thickness: 1,
                                      color: Colors.grey[300],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),

              Spacer(),

              // **Bottom Navigation Buttons**
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BMIScreen(
                              gender: widget.gender,  // Pass the current gender
                              weight: widget.weight,  // Pass the current weight
                              height: widget.height, // Pass the current height
                              age: widget.age,       // Pass the current age
                            ),
                          ),
                        );
                      },
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
                    ElevatedButton(
                      onPressed: () {
                        if (_selectedActivity ==
                            "Choose How Often Are You Active") {
                          // Show error message if no activity is selected
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Error"),
                                content: Text("Please select your activity level."),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => goal(
                                gender: widget.gender,
                                weight: widget.weight,
                                height: widget.height,
                                activityLevel: _selectedActivity,
                                age: widget.age,  // Pass the age forward
                              ),
                            ),
                          );
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
