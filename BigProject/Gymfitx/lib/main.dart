import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'basket_manager.dart';
import 'firstpage.dart';
import 'theme_notifier.dart';
import 'user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCz8nYFdPZTOUXYYyosBh3YDGxtRCrm-zU",
        appId: "1:685128012393:android:3fb1d0064bb9baa00d08f8",
        messagingSenderId: "685128012393",
        projectId: "gymfitx-f4335",
        authDomain: "gymfitx-f4335.firebaseapp.com",
        storageBucket: "gymfitx-f4335.appspot.com",
      ),
    );
    debugPrint("Firebase initialized successfully");
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
  }

  // Create the BasketManager instance outside the widget tree
  final basketManager = BasketManager();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: basketManager),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    
    return MaterialApp(
      title: 'GymFitX App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const firstpage(),
    );
  }
}