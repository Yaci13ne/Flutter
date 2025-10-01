import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter_application_1/theme_notifier.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import 'basket_manager.dart';
import 'fabtab.dart';
import 'signupscreen.dart'; // Make sure this exists

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String selectedCountryCode = '+1';
  bool useEmail = true;
  bool passwordVisible = false;
  bool rememberMe = false;

  Future<UserCredential> signInWithFacebook(BuildContext context) async {
    try {
      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login();

      if (loginResult.status == LoginStatus.failed) {
        throw Exception('Facebook login failed: ${loginResult.message}');
      }

      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential =
FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);
      // Sign in to Firebase with the Facebook credential
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(facebookAuthCredential);

      print("Logged in with Facebook: ${userCredential.user?.email}");

      // Navigate to the next screen after successful login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (context) => BasketManager()),
              ChangeNotifierProvider(create: (context) => ThemeNotifier()),
              Provider.value(value: 0),
              Provider.value(value: 0),
            ],
            child: FabTabs(),
          ),
        ),
        (Route<dynamic> route) => false, // Removes all previous routes
      );

      return userCredential; // Optionally return the userCredential
    } catch (e) {
      print("Error during Facebook sign-in: $e");
      _showErrorDialog(context, "Facebook Sign-in failed.");
      rethrow; // Rethrow the error if needed
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      // Trigger the Google Sign-in flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return;
      }

      // Obtain the Google authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential for Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      print("Logged in with Google: ${userCredential.user?.email}");

      // Navigate to the next screen after successful login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (context) => BasketManager()),
              ChangeNotifierProvider(create: (context) => ThemeNotifier()),
              Provider.value(value: 0),
              Provider.value(value: 0),
            ],
            child: FabTabs(),
          ),
        ),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print("Error during Google sign-in: $e");
      _showErrorDialog(context, "Google Sign-in failed.");
    }
  }

  void _validateAndLogin(BuildContext context) async {
    if (useEmail && !emailController.text.contains('@')) {
      _showErrorDialog(context, "Please enter a valid email.");
    } else if (!useEmail && phoneController.text.isEmpty) {
      _showErrorDialog(context, "Please enter your phone number.");
    } else if (passwordController.text.isEmpty) {
      _showErrorDialog(context, "Please enter your password.");
    } else {
      try {
        if (useEmail) {
          // Email login
          UserCredential userCredential =
              await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );
          print("Logged in with Email: ${emailController.text}");
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => MultiProvider(
                providers: [
                  // Provide both nutritionGoals and details
                  Provider.value(value: 0),
                  Provider.value(value: 0),
                ],
                child: FabTabs(

                    // If FabTabs needs details too, add it here
                    // details: details,
                    ),
              ),
            ),
            (Route<dynamic> route) => false,
          );
        } else {
          // Phone login (you can implement Firebase phone authentication if needed)
          // For now, you can show an alert or add further logic for phone authentication.
          _showErrorDialog(context, "Phone login is not yet implemented.");
        }
      } on FirebaseAuthException catch (e) {
        _showErrorDialog(
            context, e.message ?? "An error occurred during login.");
      }
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            bottom: 600,
            child: Image.asset(
              'pictures/Rectangle1.png',
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Image.asset(
                  'pictures/GymFitXnutrition-removebg-preview.png',
                  width: 300,
                  height: 300,
                ),

                // Google Sign-in
                ElevatedButton(
                  onPressed: () => _signInWithGoogle(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.white,
                    elevation: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sign in using Google',
                        style: TextStyle(
                          fontFamily: 'RethinkSanssemibold',
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Image.asset(
                        'pictures/flat-color-icons_google.png',
                        width: 24,
                        height: 24,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Facebook Sign-in
                ElevatedButton(
                  onPressed: () => signInWithFacebook(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.white,
                    elevation: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sign in using Facebook',
                        style: TextStyle(
                          fontFamily: 'RethinkSanssemibold',
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Image.asset(
                        'pictures/logos_facebook.png',
                        width: 24,
                        height: 24,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 17),

                // OR Divider
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const Divider(thickness: 1),
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: const Text(
                        "or",
                        style: TextStyle(
                          fontFamily: 'hanuman',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Toggle Email/Phone
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => setState(() => useEmail = true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: useEmail
                              ? const Color.fromARGB(255, 25, 134, 11)
                              : const Color.fromARGB(255, 223, 241, 212),
                        ),
                        child: const Text('Email'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => setState(() => useEmail = false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !useEmail
                              ? const Color.fromARGB(255, 25, 134, 11)
                              : const Color.fromARGB(255, 223, 241, 212),
                        ),
                        child: const Text('Phone'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Email or Phone Input
                if (useEmail)
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Image.asset(
                          'pictures/ic_outline-email.png',
                          width: 24,
                          height: 24,
                        ),
                      ),
                      labelText: 'Email',
                      filled: true,
                      fillColor: Colors.grey[300],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      CountryCodePicker(
                        onChanged: (code) {
                          selectedCountryCode = code.dialCode ?? '+1';
                        },
                        initialSelection: 'US',
                        favorite: ['US', 'IN', 'GB'],
                        showFlag: true,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            filled: true,
                            fillColor: Colors.grey[300],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 15),

                // Password Field
                TextField(
                  controller: passwordController,
                  obscureText: !passwordVisible,
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Image.asset(
                        'pictures/carbon_password.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () =>
                          setState(() => passwordVisible = !passwordVisible),
                    ),
                    labelText: 'Password',
                    filled: true,
                    fillColor: Colors.grey[300],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Remember Me
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (val) {
                        setState(() => rememberMe = val ?? false);
                      },
                    ),
                    const Text('Remember me'),
                  ],
                ),

                const SizedBox(height: 15),

                // Login Button
                ElevatedButton(
                  onPressed: () => _validateAndLogin(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(180, 60),
                    backgroundColor: Colors.blue,
                    elevation: 10,
                  ),
                  child: const Text(
                    'Log in',
                    style: TextStyle(
                      fontFamily: 'RethinkSansbold',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Sign Up Redirect
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignUpScreenV2()),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(
                            fontFamily: 'RethinkSanssemibold',
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: "Sign up!",
                          style: TextStyle(
                            fontFamily: 'RethinkSanssemibold',
                            fontSize: 15,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
