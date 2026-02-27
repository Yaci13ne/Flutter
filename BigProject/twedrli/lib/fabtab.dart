import 'package:flutter/material.dart';
import 'package:twedrli/Pages/insert.dart';
import 'package:twedrli/app_drawer.dart';
import 'package:twedrli/app_drawer.dart'; // 👈 import the drawer

import 'Pages/home.dart';
import 'Pages/search.dart';
import 'Pages/activity.dart';
import 'Pages/profile.dart';

class FabTabs extends StatefulWidget {
  const FabTabs({super.key});

  @override
  State<FabTabs> createState() => _FabTabsState();
}

class _FabTabsState extends State<FabTabs> {
  int currentIndex = 0;

  // 👇 Key lets us open the drawer programmatically from anywhere
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      

      key: _scaffoldKey, // 👈 attach key

      drawer: const AppDrawer(), // 👈 attach the sidebar



      body: IndexedStack(
        index: currentIndex,
        children: [
          HomeScreen(),
          TwedrliSearchScreen(),
          ActivityScreen(),
          ProfileScreen(),
        ],
      ),

      /// CENTER INSERT BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostScreen()),
          );
        },
        backgroundColor: const Color(0xFF13A4EC),
        elevation: 3,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      /// BOTTOM NAV BAR
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(Icons.home, "Home", 0),
              _buildNavItem(Icons.search, "Search", 1),

              const SizedBox(width: 50), // space for FAB

              _buildNavItem(Icons.bar_chart, "Activity", 2),
              _buildNavItem(Icons.person, "Profile", 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = currentIndex == index;

    return MaterialButton(
      minWidth: 40,
      onPressed: () {
        setState(() {
          currentIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? const Color(0xFF13A4EC) : Colors.grey),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? const Color(0xFF13A4EC) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
