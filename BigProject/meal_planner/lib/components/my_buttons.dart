import 'package:flutter/material.dart';

class MyTextButton extends StatelessWidget {
  final String buttonLabel;
  final Function() onPressedFct;
  
  const MyTextButton({super.key, required this.buttonLabel, required this.onPressedFct});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressedFct,
      child: Text(
        buttonLabel,
        style: TextStyle(color: Colors.orange),
      )
    );
  }
}

class MyElevatedButton extends StatelessWidget {
  final String buttonLabel;
  final Function() onPressedFct;

  const MyElevatedButton({super.key, required this.buttonLabel, required this.onPressedFct});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50, // Fixed height
      width: double.infinity, // Take full width
      child: ElevatedButton(
        onPressed: onPressedFct,
        child: Text(buttonLabel),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.all(12),
        ),
      ),
    );
  }
}