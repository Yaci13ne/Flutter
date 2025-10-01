import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_application_1/sidebar.dart';
import 'package:provider/provider.dart';
import 'basket_manager.dart';
import 'theme_notifier.dart';
import 'user_provider.dart'; // Import ThemeNotifier

class BasketScreen extends StatefulWidget {
  final bool fromAddToBasket;

  const BasketScreen({super.key, this.fromAddToBasket = false});

  @override
  _BasketScreenState createState() => _BasketScreenState();
}

class _BasketScreenState extends State<BasketScreen> {
  BasketManager get basketManager => Provider.of<BasketManager>(context, listen: false);
  String searchQuery = '';
  int _currentIndex = 0;
   Timer? _expiryTimer;

  @override
  void dispose() {
    _expiryTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Access the manager through context when needed
    _expiryTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      Provider.of<BasketManager>(context, listen: false).removeExpiredItems();
    });
  }
  int getTotalCalories() {
    final basketManager = Provider.of<BasketManager>(context, listen: false);
    return basketManager.confirmedItems.fold(0, (sum, item) {
      final calories = item['calories'];
      if (calories is int) return sum + calories;
      if (calories is double) return sum + calories.round();
      if (calories is String) return sum + (int.tryParse(calories) ?? 0);
      return sum;
    });
  }

  double getTotalProtein() {
    final basketManager = Provider.of<BasketManager>(context, listen: false);
    return basketManager.confirmedItems.fold(0.0, (sum, item) {
      return sum + ((item['protein'] as num?)?.toDouble() ?? 0.0);
    });
  }

  double getTotalCarbs() {
    final basketManager = Provider.of<BasketManager>(context, listen: false);
    return basketManager.confirmedItems.fold(0.0, (sum, item) {
      return sum + ((item['carbs'] as num?)?.toDouble() ?? 0.0);
    });
  }

  double getTotalFats() {
    final basketManager = Provider.of<BasketManager>(context, listen: false);
    return basketManager.confirmedItems.fold(0.0, (sum, item) {
      return sum + ((item['fats'] as num?)?.toDouble() ?? 0.0);
    });
  }

  List<Map<String, dynamic>> get filteredItems => basketManager.foodItems
      .where((item) => item['name'].toString().toLowerCase().contains(searchQuery.toLowerCase()))
      .toList();

  void updateSearch(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  void removeItem(String name) {
    setState(() {
      basketManager.removeItem(name);
    });
  }

  void confirmItem2(String name) {
    Provider.of<BasketManager>(context, listen: false).confirmItem(name);
  }

  void removeItem2(String name) {
    Provider.of<BasketManager>(context, listen: false).removeItem(name);
  }

  void confirmItem(String name) {
    setState(() {
      basketManager.confirmItem(name);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final userProvider = Provider.of<UserProvider>(context); // Add this line
    final isDarkMode = themeNotifier.isDarkMode;

    return Scaffold(
      drawer: Sidebar(
        toggleDarkMode: () => themeNotifier.toggleTheme(),
        isDarkMode: isDarkMode,
      ),
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: widget.fromAddToBasket
          ? AppBar(
              backgroundColor: isDarkMode ? Colors.grey[800] : null,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/logo.png', 
                      height: 50,
                      color: isDarkMode ? Colors.white : null,
                    ),
                    Spacer(),
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: userProvider.user.profileImage != null
                          ? FileImage(userProvider.user.profileImage!)
                          : NetworkImage(
                              "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=1000&auto=format&fit=crop",
                            ) as ImageProvider,
                      backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    ),
                  ],
                ),
                Text(
                  'Fuel your day with smart nutrition',
                  style: TextStyle(
                    fontSize: 12, 
                    fontFamily: 'Lobster',
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],    ),
                ),
                SizedBox(height: 10),
                TextField(
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Search food...',
                    hintStyle: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                    prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: updateSearch,
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                return FoodItemCard(
                  name: filteredItems[index]['name']!,
                  imagePath: filteredItems[index]['image']!,
                  protein: (filteredItems[index]['protein'] as num?)?.toDouble() ?? 0.0,
                  carbs: (filteredItems[index]['carbs'] as num?)?.toDouble() ?? 0.0,
                  fats: (filteredItems[index]['fats'] as num?)?.toDouble() ?? 0.0,
                  calories: (filteredItems[index]['calories'] as num?)?.toInt() ?? 0,
                  onRemove: () => showRemoveDialog(filteredItems[index]['name']!),
                  onConfirm: () => showConfirmDialog(filteredItems[index]['name']!),
                  isDarkMode: isDarkMode,
                );
              },
            ),
          ),
          Consumer<BasketManager>(
            builder: (context, basketManager, child) {
              if (basketManager.confirmedItems.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Finished eating!',
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      CarouselSlider.builder(
                        itemCount: basketManager.confirmedItems.length,
                        itemBuilder: (context, index, realIndex) {
                          bool isCentered = index == _currentIndex;
                          return AnimatedOpacity(
                            duration: Duration(milliseconds: 300),
                            opacity: isCentered ? 1.0 : 0.2,
                            child: Transform.scale(
                              scale: isCentered ? 1.0 : 0.9,
                              child: Card(
                                color: isDarkMode ? Colors.grey[800] : Colors.white,
                                elevation: isCentered ? 8 : 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildFoodImageInBasket(
                                      basketManager.confirmedItems[index]['image']!,
                                      isDarkMode: isDarkMode,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      basketManager.confirmedItems[index]['name']!,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isCentered
                                            ? (isDarkMode ? Colors.white : Colors.black)
                                            : Colors.grey.withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        options: CarouselOptions(
                          height: 180,
                          enlargeCenterPage: true,
                          autoPlay: false,
                          aspectRatio: 16 / 9,
                          viewportFraction: 0.4,
                          enableInfiniteScroll: false,
                          enlargeStrategy: CenterPageEnlargeStrategy.height,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }
              return SizedBox.shrink();
            },
          ),
          Consumer<BasketManager>(
            builder: (context, basketManager, child) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_fire_department, color: Colors.red, size: 28),
                    SizedBox(width: 8),
                    TweenAnimationBuilder<int>(
                      tween: IntTween(begin: 0, end: getTotalCalories().toInt()),
                      duration: Duration(milliseconds: 500),
                      builder: (context, value, child) {
                        return Text(
                          '$value kcal',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.green[300] : Colors.green[800],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      floatingActionButton: widget.fromAddToBasket
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pop(context);
              },
              backgroundColor: isDarkMode ? Colors.green[700] : Colors.green,
              child: Icon(Icons.check, color: Colors.white),
            )
          : null,

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: widget.fromAddToBasket
          ? BottomAppBar(
              color: isDarkMode ? Colors.grey[800] : Colors.white,
              shape: CircularNotchedRectangle(),
              notchMargin: 6.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(Icons.home, color: isDarkMode ? Colors.white : Colors.black),
                    onPressed: () {},
                  ),
                  SizedBox(width: 40),
                  IconButton(
                    icon: Icon(Icons.settings, color: isDarkMode ? Colors.white : Colors.black),
                    onPressed: () {},
                  ),
                ],
              ),
            )
          : null,
    );
  }

  void showConfirmDialog(String foodName) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    final isDarkMode = themeNotifier.isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
        title: Text(
          "Did you finish eating this food?",
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
          actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "No",
            style: TextStyle(color: Color.fromARGB(204, 255, 0, 0)), // Red color
          ),
        ),
        TextButton(
  onPressed: () {
    Navigator.pop(context); // Close dialog
    confirmItem(foodName); // Confirm the food item

    // Navigate to Dashboard with updated values
  

  },
  child: Text(
    "Yes",
    style: TextStyle(color: Color.fromARGB(204, 23, 98, 0)), // Green color
  ),
),

      ],
    ),
  );
}

  void showRemoveDialog(String foodName) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    final isDarkMode = themeNotifier.isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        title: Text(
          "Do you really need to remove this food?",
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "No",
            style: TextStyle(color: Color.fromARGB(204, 255, 0, 0)), // Red color
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            removeItem(foodName);
          },
          child: Text(
            "Yes",
            style: TextStyle(color: Color.fromARGB(204, 55, 92, 44)), // Green color
          ),
        ),
      ],
    ),
  );
}


  Widget _buildFoodImageInBasket(String imagePath, {required bool isDarkMode}) {
    if (imagePath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imagePath,
        width: 90,
        height: 90,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => 
            Icon(Icons.food_bank, size: 90, color: isDarkMode ? Colors.grey[400] : Colors.grey),
      );
    } else if (imagePath.startsWith('/') || imagePath.contains('data/')) {
      return Image.file(
        File(imagePath),
        width: 90,
        height: 90,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => 
            Icon(Icons.food_bank, size: 90, color: isDarkMode ? Colors.grey[400] : Colors.grey),
      );
    } else {
      return Image.asset(
        imagePath,
        width: 90,
        height: 90,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => 
            Icon(Icons.food_bank, size: 90, color: isDarkMode ? Colors.grey[400] : Colors.grey),
      );
    }
  }
}

class FoodItemCard extends StatelessWidget {
  final String name;
  final String imagePath;
  final double protein;
  final double carbs;
  final double fats;
  final int calories;
  final VoidCallback onRemove;
  final VoidCallback onConfirm;
  final bool isDarkMode;

  const FoodItemCard({
    super.key, 
    required this.name,
    required this.imagePath,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.calories,
    required this.onRemove,
    required this.onConfirm,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        textColor: isDarkMode ? Colors.white : Colors.black,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: _buildFoodImageInBasket(imagePath, isDarkMode: isDarkMode),
        ),
        title: Text(
          name,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Calories: $calories kcal", style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[700])),
            Text("Protein: $protein g", style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[700])),
            Text("Carbs: $carbs g", style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[700])),
            Text("Fats: $fats g", style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[700])),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.check_circle, color: Colors.green),
              onPressed: onConfirm,
            ),
            IconButton(
              icon: Icon(Icons.remove_circle, color: Colors.red),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodImageInBasket(String imagePath, {required bool isDarkMode}) {
    if (imagePath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imagePath,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => 
            Icon(Icons.food_bank, size: 50, color: isDarkMode ? Colors.grey[400] : Colors.grey),
      );
    } else if (imagePath.startsWith('/') || imagePath.contains('data/')) {
      return Image.file(
        File(imagePath),
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => 
            Icon(Icons.food_bank, size: 50, color: isDarkMode ? Colors.grey[400] : Colors.grey),
      );
    } else {
      return Image.asset(
        imagePath,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => 
            Icon(Icons.food_bank, size: 50, color: isDarkMode ? Colors.grey[400] : Colors.grey),
      );
    }
  }
}