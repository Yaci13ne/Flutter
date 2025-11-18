import 'package:flutter/material.dart';
import 'package:meal_planner/components/my_buttons.dart';
import 'package:meal_planner/components/my_textfield.dart';

class Signupscreen extends StatelessWidget {
  const Signupscreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController userController = TextEditingController();
    TextEditingController pwdController = TextEditingController();

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Text("Sign Up Screen"),
              MyTextfield(
                TFHintText: "Username",
                TFIcon: Icon(Icons.person),
                TFController: userController,
                isObscure: false,
              ),
              MyTextfield(
                TFHintText: "Password",
                TFIcon: Icon(Icons.lock),
                TFController: pwdController,
                isObscure: true,
              ),
              MyTextfield(
                TFHintText: "ConfirmPassword",
                TFIcon: Icon(Icons.lock),
                TFController: pwdController,
                isObscure: true,
              ),
              MyElevatedButton(buttonLabel: "SignUp", onPressedFct: () {}),
              Text("Or"),
              MyTextButton(
                buttonLabel: "Sign with Google",
                onPressedFct: () {},
              ),
              Row(
                children: [
                  Text("Already have an account ?", style: TextStyle()),
                  MyTextButton(buttonLabel: "Login", onPressedFct: () {}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
