import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter_application_1/fabtab.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'loginscreen.dart';
import 'page2 (1).dart';
import 'user_provider.dart';

class SignUpScreenV2 extends StatefulWidget {
  const SignUpScreenV2({super.key});

  @override
  State<SignUpScreenV2> createState() => _SignUpScreenV2State();
}

class _SignUpScreenV2State extends State<SignUpScreenV2> {
  bool rememberMe = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String selectedCountryCode = '+1'; // Default country code
  String selectedCountryName = 'United States'; // Default country name
  bool useEmail = true; // Toggle between email and phone

  // Google Sign-In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn();




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
  }Future<void> _googleSignUp() async {
  try {
    // Use Firebase's built-in Google sign-in flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase
    await FirebaseAuth.instance.signInWithCredential(credential);

    // Update user data
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.updateName(googleUser.displayName ?? 'No Name');
    userProvider.updateEmail(googleUser.email);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => nameScreen()),
    );
  } catch (e) {
    print("Google Sign-In Error: $e");
    _showErrorDialog(context, "Failed to sign in with Google. Please try again.");
  }
}

  void _validateAndSubmit(BuildContext context) {
    if (nameController.text.isEmpty) {
      _showErrorDialog(context, "Please enter your name.");
    } else if (useEmail && !emailController.text.contains('@')) {
      _showErrorDialog(context, "Please enter a valid email.");
    } else if (!useEmail && phoneController.text.isEmpty) {
      _showErrorDialog(context, "Please enter your phone number.");
    } else if (passwordController.text.isEmpty) {
      _showErrorDialog(context, "Please enter a password.");
    } else {
      // Get UserProvider and update user data
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.updateName(nameController.text);

      if (useEmail) {
        userProvider.updateEmail(emailController.text);
      } else {
        print("Phone: $selectedCountryCode${phoneController.text}");
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => nameScreen()),
      );
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            bottom: 600,
            child: Image.asset(
              'pictures/Rectangle1.png',
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Image.asset(
                    'pictures/GymFitXnutrition-removebg-preview.png',
                    width: 290,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(Icons.person, 'Name',
                      controller: nameController),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => setState(() => useEmail = true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: useEmail ? const Color.fromARGB(255, 25, 134, 11) : const Color.fromARGB(255, 223, 241, 212),
                          ),
                          child: const Text('Email'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => setState(() => useEmail = false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: !useEmail ? const Color.fromARGB(255, 25, 134, 11) : const Color.fromARGB(255, 223, 241, 212),
                          ),
                          child: const Text('Phone'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (useEmail)
                    _buildTextField(Icons.email, 'Email',
                        controller: emailController)
                  else
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: CountryCodePicker(
                            onChanged: (CountryCode countryCode) {
                              setState(() {
                                selectedCountryCode = countryCode.dialCode!;
                                selectedCountryName = countryCode.name!;
                              });
                            },
                            initialSelection: 'US',
                            favorite: ['+1', 'US'],
                            showCountryOnly: false,
                            showOnlyCountryWhenClosed: false,
                            alignLeft: false,
                            showFlag: true,
                            showFlagDialog: true,
                            comparator: (a, b) => b.name!.compareTo(a.name!),
                            onInit: (code) {
                              selectedCountryCode = code?.dialCode ?? '+1';
                              selectedCountryName = code?.name ?? 'United States';
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              border: UnderlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  _buildTextField(Icons.lock, 'Password',
                      isPassword: true, controller: passwordController),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        onChanged: (bool? value) {
                          setState(() {
                            rememberMe = value ?? false;
                          });
                        },
                      ),
                      const Text('Remember me'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(child: Divider(thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'or',
                          style: TextStyle(
                            fontFamily: 'hanuman',
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Sign in using',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(
                          'pictures/logos_facebook.png', Colors.blue),
                      const SizedBox(width: 20),
                      _buildSocialButton(
                          'pictures/flat-color-icons_google.png', Colors.red),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _validateAndSubmit(context),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(180, 60),
                      backgroundColor: Colors.blue,
                      elevation: 10,
                      shadowColor: Colors.black,
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'You already have an account? ',
                            style: TextStyle(
                              fontFamily: 'RethinkSanssemibold',
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: 'Log In',
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(IconData icon, String label,
      {bool isPassword = false, TextEditingController? controller}) {
    bool obscurePassword = true;

    return TextField(
      controller: controller,
      obscureText: isPassword ? obscurePassword : false,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        border: const UnderlineInputBorder(),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
              )
            : null,
      ),
    );
  }

  // Modify the _buildSocialButton method
  Widget _buildSocialButton(String imagePath, Color borderColor) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: () {
          if (imagePath.contains('google')) {
            _googleSignUp();
          } else if (imagePath.contains('facebook')) {
            signInWithFacebook(context);
          }
        },
        icon: Image.asset(imagePath),
        iconSize: 40,
      ),
    );
  }
}
