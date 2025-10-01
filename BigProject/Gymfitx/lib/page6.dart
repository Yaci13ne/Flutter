import 'package:flutter/material.dart';
import 'dart:math';
import 'page5.dart';
import 'page7.dart';

class BMIScreen extends StatelessWidget {
  final int weight;
  final int height;
  final String gender;  
  final int age;    

  const BMIScreen({
    super.key, 
    required this.weight,
    required this.height,
    required this.gender,  
    required this.age,     
  });

  double _calculateBMI() {
    if (height <= 0) return 0; 
    double heightInMeters = height / 100; 
    return weight / (heightInMeters * heightInMeters);
  }

  TextSpan _getBMICategory(double bmi) {
    final TextStyle baseStyle = TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      fontFamily: 'YourCustomFont', 
    );

    if (bmi < 18.5) {
      return TextSpan(
        text: "Underweight",
        style: baseStyle.copyWith(
          fontFamily: 'bolditalic',
          color: Colors.blue,
          fontStyle: FontStyle.italic,
        ),
      );
    } else if (bmi < 24.9) {
      return TextSpan(
        text: "Normal",
        style: baseStyle.copyWith(
          fontFamily: 'bolditalic',
          color: Colors.green,
        ),
      );
    } else if (bmi < 29.9) {
      return TextSpan(
        text: "Overweight",
        style: baseStyle.copyWith(
          fontFamily: 'bolditalic',
          color: const Color.fromARGB(255, 255, 230, 0),
          fontWeight: FontWeight.w800,
        ),
      );
    } else if (bmi < 34.9) {
      return TextSpan(
        text: "Obese",
        style: baseStyle.copyWith(
          fontFamily: 'bolditalic',
          color: const Color.fromARGB(255, 255, 145, 0),
          decoration: TextDecoration.underline,
        ),
      );
    } else {
      return TextSpan(
        text: "Severely Obese",
        style: baseStyle.copyWith(
          fontFamily: 'bolditalic',
          color: Colors.red[800],
          decoration: TextDecoration.underline,
          fontSize: 28,
        ),
      );
    }
  }

  double _getIndicatorAngle(double bmi) {
    double minBMI = 15.0;
    double maxBMI = 40.0;
    double minAngle = -pi / 3;
    double maxAngle = pi / 3;

    bmi = bmi.clamp(minBMI, maxBMI);
    return minAngle +
        ((bmi - minBMI) / (maxBMI - minBMI)) * (maxAngle - minAngle);
  }

  @override
  Widget build(BuildContext context) {
    double bmi = _calculateBMI();
    TextSpan bmiCategory = _getBMICategory(bmi); 
    double needleAngle = _getIndicatorAngle(bmi);

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/5.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 40),
              Image.asset("assets/logo.png", height: 50),
              SizedBox(height: 20),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "You are ",
                      style: TextStyle(
                        fontSize: 26,
                        fontFamily: 'bolditalic',
                      ),
                    ),
                    bmiCategory, 
                  ],
                ),
              ),
              SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset("assets/bmipict.png", width: 800),
                  Transform.translate(
                    offset: Offset(0, 128),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(0, 80),
                    child: Transform.rotate(
                      angle: needleAngle,
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 90,
                        width: 6,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.black],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 5,
                              spreadRadius: 1,
                              offset: Offset(0, 2),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Spacer(),
              SafeArea(
                child: Padding(
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
                              builder: (context) => WeightHeightScreen(gender: gender, age: age),
                            ),
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
                            Icon(Icons.arrow_back, color: Color(0xFF47DF7C)),
                            SizedBox(width: 4),
                            Text("Previous",
                                style: TextStyle(
                                  color: Color(0xFF47DF7C),
                                  fontSize: 16,
                                )),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ActivityRate(
                                gender: gender,
                                weight: weight,
                                height: height,
                                age: age,
                              ),
                            ),
                          );
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
                            Text("Next",
                                style: TextStyle(
                                  color: Color(0xFF47DF7C),
                                  fontSize: 16,
                                )),
                            SizedBox(width: 5),
                            Icon(Icons.arrow_forward, color: Color(0xFF47DF7C)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
