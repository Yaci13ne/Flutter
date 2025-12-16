import 'package:fl/components/my_buttons.dart';
import 'package:fl/components/my_textfield.dart';
import 'package:fl/helpers/validators.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> keyFormState = GlobalKey<FormState>();

    final TextEditingController userController = TextEditingController();
    final TextEditingController pwdController = TextEditingController();

    void displayAToast() {
      Fluttertoast.showToast(
        msg: "Your entries are not valid",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Form(
            key: keyFormState,
            child: Column(
              children: [
                const SizedBox(height: 60),

                const Text(
                  "Welcome to my App",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                const CircleAvatar(
                  backgroundImage: AssetImage("assets/logo.png"),
                  radius: 40,
                ),

                const SizedBox(height: 20),

                MyTextfield(
                  TFHintText: "Email",
                  TFIcon: const Icon(Icons.email),
                  isObscure: false,
                  TFController: userController,
                  TFValidator: (val) => emailValidatorFct(val),
                ),

                const SizedBox(height: 10),

                MyTextfield(
                  TFHintText: "Password",
                  TFIcon: const Icon(Icons.lock),
                  isObscure: true,
                  TFController: pwdController,
                  TFValidator: (val) => pwdValidationFct(val),
                ),

                const SizedBox(height: 120),

                /// LOGIN BUTTON
                MyElevatedButton(
                  buttonLabel: "Login",
                  onPressedFct: () async {
                    if (!keyFormState.currentState!.validate()) {
                      displayAToast();
                      return;
                    }

                    try {
                      UserCredential userCredential = await FirebaseAuth
                          .instance
                          .signInWithEmailAndPassword(
                            email: userController.text.trim(),
                            password: pwdController.text.trim(),
                          );

                      if (userCredential.user!.emailVerified) {
                        Navigator.pushReplacementNamed(context, '/home');
                      } else {
                        Fluttertoast.showToast(
                          msg: "Please verify your email first",
                          backgroundColor: Colors.orange,
                        );
                      }
                    } on FirebaseAuthException catch (e) {
                      Fluttertoast.showToast(
                        msg: e.message ?? "Login failed",
                        backgroundColor: Colors.red,
                      );
                    }
                  },
                ),

                MyTextButton(
                  buttonLabel: "Forgot Password",
                  onPressedFct: () async {
                    if (userController.text.isEmpty) {
                      Fluttertoast.showToast(msg: "Please enter your email");
                      return;
                    }

                    String? error = emailValidatorFct(
                      userController.text.trim(),
                    );
                    if (error != null) {
                      Fluttertoast.showToast(msg: error);
                      return;
                    }

                    try {
                      await FirebaseAuth.instance.sendPasswordResetEmail(
                        email: userController.text.trim(),
                      );

                      Fluttertoast.showToast(
                        msg: "Password reset link sent",
                        backgroundColor: Colors.green,
                      );
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'user-not-found') {
                        Fluttertoast.showToast(
                          msg: "No account found with this email",
                        );
                      } else {
                        Fluttertoast.showToast(
                          msg: e.message ?? "Error occurred",
                        );
                      }
                    }
                  },
                ),

                /// SIGN UP
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    MyTextButton(
                      buttonLabel: "Signup",
                      onPressedFct: () {
                        Navigator.pushReplacementNamed(context, '/signup');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
