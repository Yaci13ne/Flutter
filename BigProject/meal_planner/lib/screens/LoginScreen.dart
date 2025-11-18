import 'package:flutter/material.dart';
import 'package:meal_planner/components/my_buttons.dart';
import 'package:meal_planner/components/my_textfield.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController userController = TextEditingController();
    TextEditingController pwdController = TextEditingController();
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(8),
          child: Column(
            children: [
              Text(
                "Welcome to my App",
                textAlign: TextAlign.center,
                style: TextStyle(),
              ),
              CircleAvatar(backgroundImage: AssetImage(""), radius: 20),
              MyTextfield(
                TFHintText: "Email",
                TFIcon: Icon(Icons.email),
                isObscure: false,
                TFController: userController,
              ),
              MyTextfield(
                TFHintText: "Password",
                TFIcon: Icon(Icons.lock),
                isObscure: true,
                TFController: pwdController,
              ),
              MyElevatedButton(buttonLabel: "Login", onPressedFct: () {}),
              MyTextButton(buttonLabel: "Forgot Password", onPressedFct: () {}),
              Row(
                children: [
                  Text("Don't have an account", style: TextStyle()),
                  MyTextButton(buttonLabel: "Signup", onPressedFct: () {}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
