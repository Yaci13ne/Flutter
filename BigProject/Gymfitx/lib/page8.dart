import 'package:flutter/material.dart';
import 'UserData.dart';
import 'page9.dart';
import 'page7.dart';


class goal extends StatefulWidget {
  final String gender;
  final int weight;
  final int height;
  final String activityLevel;
  final int age;  // Add this
  
  const goal({
    super.key,
    required this.gender,
    required this.weight,
    required this.height,
    required this.activityLevel,
    required this.age,  // Add this
  });
  @override
  goalState createState() => goalState();
}

class goalState extends State<goal> {
  String _selectedGoal = ""; // Stores the selected goal

  @override
  Widget build(BuildContext context) {
     print('[goal] Received age: ${widget.age}, activityLevel: ${widget.activityLevel}');
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/7.png"),
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
                      "What is Your Goal?",
                      style: TextStyle(
                        fontSize: 30,
                        fontFamily: 'bolditalic',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),

                    // **Goal Options**
                    GoalButton(
                      title: "Maintain your physique",
                      isSelected: _selectedGoal == "Maintain your physique",
                      onTap: () {
                        setState(() {
                          _selectedGoal = "Maintain your physique";
                        });
                      },
                    ),
                    GoalButton(
                      title: "Gain weight",
                      isSelected: _selectedGoal == "Gain weight",
                      onTap: () {
                        setState(() {
                          _selectedGoal = "Gain weight";
                        });
                      },
                    ),
                    GoalButton(
                      title: "Lose weight",
                      isSelected: _selectedGoal == "Lose weight",
                      onTap: () {
                        setState(() {
                          _selectedGoal = "Lose weight";
                        });
                      },
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
                            builder: (context) => ActivityRate( gender: widget.gender,       // Pass back the gender
          weight: widget.weight,       // Pass back the weight
          height: widget.height,    
                  age: widget.age,  // Pass the age forward
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
                        if (_selectedGoal.isEmpty) {
                          // Show error message if no name is entered
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Error"),
                                content: Text("Please enter your GOAL."),
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
    // Create user data with all collected information
    final userData = UserData(
  age: widget.age,  // Use the passed age
         gender: widget.gender,
      weight: widget.weight,
      height: widget.height,
      activityLevel: widget.activityLevel,
      goal: _selectedGoal,
    );
      final macros = userData.calculateMacros();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WelcomeScreen(

                  age: userData.age,  // Pass the age here

            userName: "User", // You might want to collect this earlier
            dailyCalories: macros['calories']!.round(),
            proteinGoal: macros['protein']!.round(),
            fatGoal: macros['fat']!.round(),
            carbsGoal: macros['carbs']!.round(), weight: userData.weight,height: userData.height,
          ),
        ),
      );
print('Calculated macros: $macros'); // Check if values are correct

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

// **Reusable Goal Button Widget with Selection State**
class GoalButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const GoalButton({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSelected ? Color(0xFF47DF7C) : Colors.grey.shade900,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.symmetric(vertical: 15),
          minimumSize: Size(double.infinity, 50),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'interregular',
            color: isSelected ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}
