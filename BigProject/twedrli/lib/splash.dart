import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twedrli/Pages/Login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    // Go truly full screen — hide status bar & nav bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Fade-in animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // After 3 seconds, restore UI and navigate to login
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SizedBox.expand(
          child: Image.asset(
            'assets/splash.png',
            fit: BoxFit.cover, // fills every pixel edge-to-edge
          ),
        ),
      ),
    );
  }
}
