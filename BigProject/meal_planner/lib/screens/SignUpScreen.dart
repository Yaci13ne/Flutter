import 'package:fl/components/my_buttons.dart';
import 'package:fl/components/my_textfield.dart';
import 'package:fl/helpers/validators.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';


class Signupscreen extends StatelessWidget {
  const Signupscreen({super.key});

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> keyFormState = GlobalKey<FormState>();

    TextEditingController userController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController pwdController = TextEditingController();
    TextEditingController confirmPwdController = TextEditingController();

    String? pwdConfirmValidationFct(String? value, String originalPwd) {
      if (value!.isEmpty) {
        return "Confirm Password Can't be empty";
      } else if (value != originalPwd) {
        return 'Confirm Password should be the same as password';
      }
      return null;
    }

    void displayAToast() {
      Fluttertoast.showToast(
        msg: "Your entries are not valid",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        
        child: Container(
          margin: EdgeInsets.all(8),
          child: Form(
            key: keyFormState,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                                SizedBox(height: 60),

                Text(
                  "Sign Up Screen",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                MyTextfield(
                  TFHintText: "Username",
                  TFIcon: Icon(Icons.person),
                  TFController: userController,
                  isObscure: false,
                  TFValidator: (val) =>
                      val!.isEmpty ? "Username Can't be empty" : null,
                ),
                SizedBox(height: 10),
                MyTextfield(
                  TFHintText: "Email",
                  TFIcon: Icon(Icons.email),
                  TFController: emailController,
                  isObscure: false,
                  TFValidator: (val) => emailValidatorFct(val),
                ),
                SizedBox(height: 10),
                MyTextfield(
                  TFHintText: "Password",
                  TFIcon: Icon(Icons.lock),
                  TFController: pwdController,
                  isObscure: true,
                  TFValidator: (val) => pwdValidationFct(val),
                ),
                SizedBox(height: 10),
                MyTextfield(
                  TFHintText: "Confirm Password",
                  TFIcon: Icon(Icons.lock),
                  TFController: confirmPwdController,
                  isObscure: true,
                  TFValidator: (value) =>
                      pwdConfirmValidationFct(value, pwdController.text),
                ),
                SizedBox(height: 120),
                MyElevatedButton(
                  buttonLabel: "SignUp",
                onPressedFct: () async {
                    if (keyFormState.currentState!.validate()) {
                      try {
                        // Create user with email and password
                        UserCredential userCredential = await FirebaseAuth
                            .instance
                            .createUserWithEmailAndPassword(
                              email: emailController.text,
                              password: pwdController.text,
                            );

                        // Send verification email
                        await userCredential.user!.sendEmailVerification();

                        Fluttertoast.showToast(
                          msg: "Account created! Please verify your email.",
                          backgroundColor: Colors.green,
                        );

                        // Navigate to login screen
                        Navigator.pushReplacementNamed(context, '/login');
                      } on FirebaseAuthException catch (e) {
                        Fluttertoast.showToast(
                          msg: "Signup failed: ${e.message}",
                          backgroundColor: Colors.red,
                        );
                      } catch (e) {
                        Fluttertoast.showToast(msg: "Error: ${e.toString()}");
                      }
                    } else {
                      displayAToast();
                    }
                  },
                ),
                SizedBox(height: 10),
                Text("Or"),
                SizedBox(height: 10),
                MyTextButton(
                  buttonLabel: "Sign with Google",
                  onPressedFct: () {},
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account ?", style: TextStyle()),
                    MyTextButton(
                      buttonLabel: "Login",
                      onPressedFct: () {
                        Navigator.pushReplacementNamed(context, '/login');
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
