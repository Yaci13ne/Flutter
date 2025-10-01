import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'Insert_food.dart';
import 'Me.dart';
import 'app.dart';
import 'basket.dart';
import 'home.dart';
import 'meal_creator.dart';
import 'my_flutter_app_icons (1).dart';
import 'theme_notifier.dart';
class FabTabs extends StatefulWidget {
  final NutritionGoals? nutritionGoals;

  const FabTabs({super.key, this.nutritionGoals});
  @override
  State<FabTabs> createState() => _FabTabsState();
}


class _FabTabsState extends State<FabTabs> {
  int currentIndex = 0;
  bool isFabExpanded = false;
  List<Map<String, String>> foodData = [];
  final GlobalKey<GymFitXHomeState> gymFitXHomeKey = GlobalKey();

void _navigateToMealCreator() async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => MealCreator()),
  );

  print('Received meal data: $result'); // Debug print

  if (result != null && result is Map<String, dynamic>) {
    setState(() => isFabExpanded = false);
    gymFitXHomeKey.currentState?.setState(() {
      gymFitXHomeKey.currentState?.savedMeals.add(result);
      gymFitXHomeKey.currentState?.saveMealsToPreferences();
    });
  }
}

  Widget _buildMiniFab(String text, IconData icon, VoidCallback onTap) {final themeNotifier = Provider.of<ThemeNotifier>(context);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:themeNotifier.isDarkMode ?   Color.fromARGB(255, 0, 0, 0) : const Color.fromARGB(255, 76, 175, 80),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: text == "Create Meal" ? _navigateToMealCreator : onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 5),
          Text(text, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
void _navigateToInsertFood() async {
  final newFoodItem = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => InsertFoodScreen()),
  );

  if (newFoodItem != null) {
    setState(() {
      isFabExpanded = false;
    });
    // Trigger refresh in GymFitXHome
    gymFitXHomeKey.currentState?.setState(() {
      gymFitXHomeKey.currentState?.loadClickedItems();
      gymFitXHomeKey.currentState?.refreshFoodList();
    });

  }
}

  void _openBasketScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BasketScreen(fromAddToBasket: true),
      ),
    );
  }

  /// **Floating Action Button UI**
  Widget _buildFloatingActionButton() {final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Visibility(
      visible: currentIndex == 1, // FAB only visible on Food page
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          if (isFabExpanded)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isFabExpanded = false;
                  });
                },
                child: Container(),
              ),
            ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isFabExpanded)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMiniFab("Insert Food", Icons.restaurant_rounded, _navigateToInsertFood),
                    _buildMiniFab("Create Meal", MyFlutterApp.food, () {
                      setState(() {
                        isFabExpanded = false;
                      });
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => MealCreator()),
                      );
                    }),
                  ],
                ),
              FloatingActionButton(
        backgroundColor:themeNotifier.isDarkMode ?   Color.fromARGB(255, 0, 0, 0) : const Color.fromARGB(255, 76, 175, 80),
                shape: const CircleBorder(),
                elevation: 0,
                clipBehavior: Clip.antiAlias,
                onPressed: () {
                  setState(() {
                    isFabExpanded = !isFabExpanded;
                  });
                },
                child: Icon(isFabExpanded ? Icons.close : Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }

    @override
  Widget build(BuildContext context) {    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          Home(goals: widget.nutritionGoals),
          GymFitXHome(
            key: gymFitXHomeKey, // Pass the key here
            foodData: foodData,
          ),
          Bask(),
          Me(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(//--
color:  themeNotifier.isDarkMode ?   Color.fromARGB(255, 0, 0, 0) : const Color.fromARGB(255, 76, 175, 80),
        shape: currentIndex == 1 ? const CircularNotchedRectangle() : null, // Remove notch on other pages
        notchMargin: currentIndex == 1 ? 10 : 0, // Ensure no gap
        child: SizedBox(
          height: 60,
          child: Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    _buildNavItem(Icon(Icons.home, color: Colors.white), "Home", 0),
    _buildNavItem(Image.asset("assets/canvap.png", width: 24, height: 24), "Food", 1),
currentIndex == 1 ? SizedBox(width: 70) : SizedBox(width:2),
    _buildNavItem(Icon(Icons.shopping_basket, color: Colors.white), "Basket", 2),
    _buildNavItem(Icon(Icons.person, color: Colors.white), "Me", 3),
  ],
)

        ),
      ),
    );
  }

  /// **Mini Floating Action Buttons**


  /// **Navigation Bar Items**
  Widget _buildNavItem(Widget icon, String label, int index) {
    return MaterialButton(
      minWidth: 7,
      onPressed: () {
        setState(() {
          currentIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          Text(
            label,
            style: TextStyle(
              color: currentIndex == index ? const Color.fromARGB(255, 255, 255, 255) : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class Home extends StatelessWidget {
  final NutritionGoals? goals;  // Add this line
  
  const Home({super.key, this.goals});  
  @override
  Widget build(BuildContext context) {
    return Dashboard(goals: goals);
  }
}

class Bask extends StatelessWidget {
  const Bask({super.key});

  @override
  Widget build(BuildContext context) {
    return BasketScreen(fromAddToBasket: false);
  }
}

class Me extends StatelessWidget {
  const Me({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileScreen();
  }
}
 