import 'package:flutter/material.dart';
import 'package:twedrli/Lists/list.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      key: _scaffoldKey, // 👈 attach key

      drawer: const AppDrawer(), // 👈 attach the sidebar

      body: IndexedStack(
        index: currentIndex,
        children: const [
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
            MaterialPageRoute(builder: (context) => CreatePostScreen(userId: loggedInUserIdNotifier.value ?? 10),
),
          );
        },
        backgroundColor: primaryColor,
        elevation: 3,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      /// BOTTOM NAV BAR
      bottomNavigationBar: BottomAppBar(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        elevation: isDark ? 0 : 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(Icons.home, "Home", 0, primaryColor, isDark),
              _buildNavItem(Icons.search, "Search", 1, primaryColor, isDark),

              const SizedBox(width: 50), // space for FAB

              _buildNavItem(
                Icons.bar_chart,
                "Activity",
                2,
                primaryColor,
                isDark,
              ),
              _buildNavItem(Icons.person, "Profile", 3, primaryColor, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index,
    Color primaryColor,
    bool isDark,
  ) {
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
          Icon(
            icon,
            color: isSelected
                ? primaryColor
                : (isDark ? Colors.grey[500] : Colors.grey),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected
                  ? primaryColor
                  : (isDark ? Colors.grey[500] : Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
