import 'package:flutter/material.dart';
import 'page2 (1).dart';
import 'page4.dart';

void main() {
  runApp(GymFitXApp());
}

class GymFitXApp extends StatelessWidget {
  const GymFitXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: birthScreen(),
    );
  }
}

class birthScreen extends StatefulWidget {
  const birthScreen({super.key});

  @override
  birthScreenState createState() => birthScreenState();
}

class birthScreenState extends State<birthScreen> {
  DateTime? _selectedDate; // Variable to store selected date

  // Function to open Date Picker
  Future<void> _pickDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    DateTime firstDate = DateTime(currentDate.year - 100); // Oldest year limit
    DateTime lastDate = DateTime(currentDate.year - 10); // Youngest year limit

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: lastDate, // Default to 10 years old
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            primaryColor: Colors.green,
            colorScheme: ColorScheme.dark(primary: Colors.green),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height, // Full-screen height
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/2.png"),
            fit: BoxFit.cover, // Full-screen background
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
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
                          "What is Your Date of Birth?",
                          style: TextStyle(
                            fontSize: 30,
                            fontFamily: 'bolditalic',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: GestureDetector(
                            onTap: () => _pickDate(context),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                _selectedDate == null
                                    ? "Select your date of birth"
                                    : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                                style: TextStyle(
                                  color: _selectedDate == null ? Colors.grey : Colors.black,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Bottom Navigation Buttons
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
                              builder: (context) => nameScreen()), // Navigate to NameScreen
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
                        if (_selectedDate == null) {
                          // Show error message if no date is picked
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Error"),
                                content: Text("Please select your date of birth."),
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
                          final age = _calculateAge(_selectedDate!);
                          print('[birthScreen] Calculated age: $age'); // Add this

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GenderSelectionScreen(age: age), // Pass the calculated age to the next screen
                            ),
                          );

                          print("Date of Birth: ${_selectedDate!.toIso8601String()}");
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

  // Helper method to calculate age from birth date
  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
