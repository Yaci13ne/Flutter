import 'package:flutter/material.dart';
import 'page5.dart';
import 'page3.dart';

class GenderSelectionScreen extends StatefulWidget {
  final int age;

  const GenderSelectionScreen({
    super.key,
    required this.age,
  });

  @override
  _GenderSelectionScreenState createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String? _selectedGender;

  @override
  Widget build(BuildContext context) {
    print('[GenderSelectionScreen] Received age: ${widget.age}'); // Debugging received age

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height, // Full-screen height
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/3.png"),
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

                    // **Gender Selection**
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildGenderCard(
                          "Male",
                          "pictures/famicons_male-sharp.png",
                          Colors.blue,
                        ),
                        SizedBox(width: 60),
                        _buildGenderCard(
                          "Female",
                          "pictures/mingcute_female-line.png",
                          Colors.pink,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Spacer(), // Pushes buttons to the bottom

              // **Bottom Navigation Buttons**
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // **Previous Button**
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => birthScreen()), // Navigate to BirthScreen
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        fixedSize: Size(110, 40),
                        backgroundColor: Colors.grey.shade900,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Image.asset("pictures/carbon_nextleft.png", width: 20, height: 20),
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
                        if (_selectedGender != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WeightHeightScreen(
                                      gender: _selectedGender!,
                                      age: widget.age,
                                    )),
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Error"),
                                content: Text("Please select your gender."),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("OK"),
                                  ),
                                ],
                              );
                            },
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
                          Image.asset("pictures/carbon_nextright.png", width: 25, height: 20),
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

  Widget _buildGenderCard(String gender, String iconPath, Color iconColor) {
    bool isSelected = _selectedGender == gender;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: 150, // Adjusted width
        height: 180, // Adjusted height
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: isSelected ? Border.all(color: Colors.green, width: 3) : null, // Highlight border
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(2, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 110,
              height: 110,
              color: iconColor,
            ),
            SizedBox(height: 5),
            Text(
              gender,
              style: TextStyle(
                fontSize: 30, // Increased font size
                fontWeight: FontWeight.w600, // Medium-bold text
                letterSpacing: 1.2, // Slight spacing
                fontFamily: 'rethinksansextrabold',
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
