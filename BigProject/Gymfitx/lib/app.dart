import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

import 'item.dart';
import 'meal_creator.dart';
import 'theme_notifier.dart'; // Make sure you have this import
import 'sidebar.dart';
import 'user_provider.dart'; // Make sure you have this import

class GymFitXHome extends StatefulWidget {
  final Function(Map<String, dynamic>)? onFoodItemClicked;
  final bool isFromMealCreator;
  final List<Map<String, dynamic>> foodData;
  final Map<String, dynamic> food;

  const GymFitXHome({
    super.key,
    this.isFromMealCreator = false,
    this.foodData = const [],
    this.food = const {},
    this.onFoodItemClicked,
  });

  @override
  GymFitXHomeState createState() => GymFitXHomeState();
}

class GymFitXHomeState extends State<GymFitXHome> {
  
// Keep only one _loadClickedItems method (the more complete one)
// Remove the duplicate _initializeData() method and keep only one:

Future<void> _initializeData() async {
  setState(() {
    _isLoadingFavorites = true;
    _isLoadingMeals = true;
  });
  
  await _loadFavorites();
  await loadClickedItems();
  await _loadSavedMeals();
  
  setState(() {
    _isLoadingFavorites = false;
    _isLoadingMeals = false;
  });
}
  List<Map<String, dynamic>> foodItems = [];

  List<Map<String, dynamic>> savedMeals = [];
  bool _isLoadingFavorites = true;
  bool _isLoadingMeals = true;
  final bool _isLoadingClickedItems = true;
  String searchQuery = "";
  int selectedFilterIndex = 0;
  Set<String> favoriteFoods = {};
  List<Map<String, dynamic>> clickedFoodItems = [];
  final List<String> filters = ["All", "Favorite", "Meals", "Created By Me"];
  String _selectedSortOption = 'A-Z';
  final List<String> _sortOptions = [
    'A-Z',
    'Z-A',
    'Max Calories',
    'Min Calories',
    'Max Protein',
    'Min Protein',
    'Max Carbs',
    'Min Carbs',
    'Max Fats',
    'Min Fats',
  ];
Future<List<Map<String, dynamic>>> _loadCustomFoodItems() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? jsonString = prefs.getString('clickedItems');
return List<Map<String, dynamic>>.from(json.decode(jsonString ?? '[]'));
}

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

// Add this method to GymFitXHome
Future<void> refreshData() async {
  await loadClickedItems();
  if (mounted) setState(() {});
}
Future<void> refreshFoodList() async {
  await loadClickedItems();
  if (mounted) setState(() {});
}
Future<void> loadClickedItems() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? clickedItemsJson = prefs.getString('clickedItems');

  List<Map<String, dynamic>> loadedItems =
      List<Map<String, dynamic>>.from(json.decode(clickedItemsJson ?? '[]'));
  
  setState(() {
    clickedFoodItems = loadedItems;
    
    // Remove all custom items first
    foodItems.removeWhere((item) => item['createdByMe'] == true);
    
    // Add clicked items only if they don't already exist
    for (var food in loadedItems) {
      if (!foodItems.any((item) => item['name'] == food['name'])) {
        foodItems.add({
          'name': food['name'],
          'calories': int.tryParse(food['calories']?.toString() ?? '0') ?? 0,
          'protein': double.tryParse(food['protein']?.toString() ?? '0') ?? 0.0,
          'carbs': double.tryParse(food['carbs']?.toString() ?? '0') ?? 0.0,
          'fats': double.tryParse(food['fats']?.toString() ?? '0') ?? 0.0,
          'image': food['image'] ?? 'assets/default.png',
          'createdByMe': true,
        });
      }
    }
  });
}
// Replace your _navigateToMealCreator with this:
  void _navigateToMealCreator() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MealCreator()),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        savedMeals.add(result);
        saveMealsToPreferences();
      });
    }
  }

// Add this new method:
  Future<void> saveMealsToPreferences() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> mealsJson =
          savedMeals.map((meal) => json.encode(meal)).toList();
      await prefs.setStringList('savedMeals', mealsJson);
    } catch (e) {
      print("Error saving meals: $e");
    }
  }

// Update your _loadSavedMeals method:
  Future<void> _loadSavedMeals() async {
    setState(() => _isLoadingMeals = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? savedMealsJson = prefs.getStringList('savedMeals');

      setState(() {
        savedMeals = savedMealsJson
            ?.map((meal) {
              try {
                return json.decode(meal) as Map<String, dynamic>;
              } catch (e) {
                print("Error decoding meal: $e");
                return <String, dynamic>{};
              }
            })
            .where((meal) => meal.isNotEmpty)
            .toList()?? [];
      });
        } catch (e) {
      print("Error loading meals: $e");
    } finally {
      setState(() => _isLoadingMeals = false);
    }
  }void _handleMealTap(Map<String, dynamic> meal) {
  String mealName = meal['name'] ?? meal['mealName'] ?? 'Unnamed Meal';
  bool isFavorite = favoriteFoods.contains(mealName);

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProductPage(
        isFavorite: isFavorite,
        onFavoriteToggle: (bool newFavoriteState) {
          setState(() {
            if (newFavoriteState) {
              favoriteFoods.add(mealName);
            } else {
              favoriteFoods.remove(mealName);
            }
            _saveFavorites();
          });
        },
        onRemove: () {
          setState(() {
            savedMeals.removeWhere((m) => (m['name'] ?? m['mealName']) == mealName);
            saveMealsToPreferences();
          });
        },
        foodItem: {
          'name': mealName,
          'image': meal['imagePath'] ?? 'assets/default.png',
          'protein': meal['totalProtein'] ?? 0,
          'carbs': meal['totalCarbs'] ?? 0,
          'fats': meal['totalFats'] ?? 0,
          'calories': meal['totalCalories'] ?? 0,
          'isMeal': true,
          'foods': meal['foods'] ?? [], // Ensure this is properly structured
        },
        isFromMealCreator: true, foodFlag: null, onSave: (updatedItem) {  }, // Changed from false to true
      ),
    ),
  );
}
  // Add this method
  Future<void> _refreshSavedMeals() async {
    await _loadSavedMeals();
    if (mounted) {
      setState(() {}); // Trigger a rebuild
    }
  }



  Future<void> _loadFavorites() async {
    setState(() => _isLoadingFavorites = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? savedFavorites = prefs.getStringList('favorites');
      setState(() {
      // Line 234
favoriteFoods = savedFavorites?.toSet() ?? <String>{};
        print('Loaded favorites: ${favoriteFoods.toList()}'); // Debug print
        _isLoadingFavorites = false;
      });
    } catch (e) {
      print("Error loading favorites: $e");
      setState(() => _isLoadingFavorites = false);
    }
  }

// Assure-toi que mealList est défini dans ton State
  List<Map<String, dynamic>> mealList = [];

  Future<void> _saveToPreferences() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> mealsJson =
          mealList.map((meal) => json.encode(meal)).toList();
      await prefs.setStringList('mealList', mealsJson);
      print("Meals saved to preferences");
    } catch (e) {
      print("Error saving meals to preferences: $e");
    }
  }

  Future<void> _saveFavorites() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favorites', favoriteFoods.toList());
      print('Favorites saved: ${favoriteFoods.toList()}'); // Debug print
    } catch (e) {
      print("Error saving favorites: $e");
    }
  }


  Future<void> _printStoredClickedItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? clickedItemsJson = prefs.getString('clickedItems');
    print("Stored clicked items: $clickedItemsJson");
    }

  void _saveClickedFoodItem(Map<String, dynamic> foodItem) async {
    // Ensure required fields exist
    if (foodItem['name'] == null ||
        foodItem['image'] == null ||
        foodItem['calories'] == null ||
        foodItem['carbs'] == null ||
        foodItem['protein'] == null ||
        foodItem['fats'] == null) {
      print("Error: Missing required fields in foodItem");
      return;
    }

    // Create a simplified copy with all nutritional info
    Map<String, dynamic> itemToSave = {
      'name': foodItem['name'],
      'image': foodItem['image'],
      'calories': foodItem['calories'],
      'protein': foodItem['protein'], // Add protein with default 0.0 if null
      'carbs': foodItem['carbs'], // Add carbs with default 0.0 if null
      'fats': foodItem['fats'], // Add fats with default 0.0 if null
    };

    // Check if already exists
    bool alreadyExists =
        clickedFoodItems.any((item) => item['name'] == foodItem['name']);

    if (!alreadyExists) {
      setState(() {
        clickedFoodItems.add(itemToSave);
      });

      // Save to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('clickedItems', json.encode(clickedFoodItems));
      await _printStoredClickedItems();
      print("✅ Saved clicked item: ${foodItem['name']}");
    } else {
      print("⚠️ Item already in clicked list: ${foodItem['name']}");
    }

    // If we're coming from MealCreator, navigate back with the selected item
    if (widget.isFromMealCreator) {
      Navigator.pop(context, itemToSave); // Now includes all nutritional info
      didChangeDependencies;
    }

    // Notify parent widget if needed
    if (widget.onFoodItemClicked != null) {
      widget.onFoodItemClicked!(foodItem);
    }
  }

String getItemName(Map<String, dynamic> item) {
  return item['name'] ?? item['mealName'] ?? '';
}


  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.isDarkMode;

List<Map<String, dynamic>> foodItems = [
  {
    'name': 'Chicken Breast',
    'calories': 165,
    'protein': 31.0,
    'carbs': 0.0,
    'fats': 3.6,
    'image': 'assets/chickenb.png',
  },
  {
    'name': 'Chicken Wings',
    'calories': 250,
    'protein': 27.0,
    'carbs': 0.5,
    'fats': 19.5,
    'image': 'assets/chickenwings.png',
  },
  {
    'name': 'Rice',
    'calories': 130,
    'protein': 2.7,
    'carbs': 28.0,
    'fats': 0.3,
    'image': 'assets/rice.png',
  },
  {
    'name': 'Oats',
    'calories': 389,
    'protein': 11.0,
    'carbs': 66.0,
    'fats': 6.9,
    'image': 'assets/oats.png',
  },
  
  {
    'name': 'Olive Oil',
    'calories': 884,
    'protein': 0.0,
    'carbs': 0.0,
    'fats': 100.0,
    'image': 'assets/oil.png',
  },
  {
    'name': 'Dates',
    'calories': 277,
    'protein': 1.8,
    'carbs': 75.0,
    'fats': 0.2,
    'image': 'assets/dates.png',
  },
  {
    'name': 'Chickpeas',
    'calories': 164,
    'protein': 9.0,
    'carbs': 27.0,
    'fats': 2.6,
    'image': 'assets/chickpeas.png',
  },
  {
    'name': 'Couscous',
    'calories': 112,
    'protein': 3.8,
    'carbs': 23.0,
    'fats': 0.2,
    'image': 'assets/couscous.png',
  },
  {
    'name': 'Potatoes',
    'calories': 77,
    'protein': 2.0,
    'carbs': 17.0,
    'fats': 0.1,
    'image': 'assets/potatoes.png',
  },
  {
    'name': 'Tomatoes',
    'calories': 18,
    'protein': 0.9,
    'carbs': 3.9,
    'fats': 0.2,
    'image': 'assets/tomatoes.png',
  },
  {
    'name': 'Onions',
    'calories': 40,
    'protein': 1.1,
    'carbs': 9.3,
    'fats': 0.1,
    'image': 'assets/onions.png',
  },

  {
    'name': 'Carrots',
    'calories': 41,
    'protein': 0.9,
    'carbs': 10.0,
    'fats': 0.2,
    'image': 'assets/carrots.png',
  },
  {
    'name': 'Zucchini',
    'calories': 17,
    'protein': 1.2,
    'carbs': 3.1,
    'fats': 0.3,
    'image': 'assets/zucchini.png',
  },
  {
    'name': 'Eggs',
    'calories': 143,
    'protein': 13.0,
    'carbs': 1.1,
    'fats': 9.5,
    'image': 'assets/Egg.png',
  },
  {
    'name': 'Yogurt',
    'calories': 59,
    'protein': 10.0,
    'carbs': 3.6,
    'fats': 0.4,
    'image': 'assets/yugort.png',
  },
  {
    'name': 'Beef',
    'calories': 250,
    'protein': 26.0,
    'carbs': 0.0,
    'fats': 17.0,
    'image': 'assets/beef.png',
  },
  {
    'name': 'Mint Leaves',
    'calories': 44,
    'protein': 3.3,
    'carbs': 8.4,
    'fats': 0.7,
    'image': 'assets/mintleaves.png',
  },
  {
    'name': 'Green Peas',
    'calories': 81,
    'protein': 5.0,
    'carbs': 14.5,
    'fats': 0.4,
    'image': 'assets/greenpeas.png',
  },


];

setState(() {
  // Only add items that don't already exist in foodItems
  foodItems.addAll(
    clickedFoodItems.where((clickedFood) => 
      !foodItems.any((existingFood) => existingFood['name'] == clickedFood['name'])
    ).map((food) => {
      'name': food['name'],
      'calories': int.tryParse(food['calories']?.toString() ?? '0') ?? 0,
      'protein': double.tryParse(food['protein']?.toString() ?? '0') ?? 0.0,
      'carbs': double.tryParse(food['carbs']?.toString() ?? '0') ?? 0.0,
      'fats': double.tryParse(food['fats']?.toString() ?? '0') ?? 0.0,
      'image': food['image'] ?? 'assets/default.png',
      'createdByMe': true,
    })
  );
});

    if (widget.food.isNotEmpty &&
        !foodItems.any((item) => item['name'] == widget.food['name'])) {
      foodItems.add({
        'name': widget.food['name'] ?? 'Unknown',
        'calories': int.tryParse(widget.food['calories'] ?? '0') ?? 0,
        'protein': double.tryParse(widget.food['protein'] ?? '0') ?? 0,
        'carbs': double.tryParse(widget.food['carbs'] ?? '0') ?? 0,
        'fats': double.tryParse(widget.food['fats'] ?? '0') ?? 0,
        'image': widget.food['image'] ?? 'assets/default.png',
        'createdByMe': true,
      });
    }
    List<Map<String, dynamic>> filteredFoodItems = [];

// Combine all possible items (foodItems + savedMeals) without duplicates
    List<Map<String, dynamic>> allItems = [...foodItems];
    for (var meal in savedMeals) {
      final mealName = meal['name'] ?? meal['mealName'];
      if (!allItems.any((item) => item['name'] == mealName)) {
        allItems.add({
          'name': mealName,
          'calories': meal['totalCalories'] ?? 0,
          'protein': meal['totalProtein'] ?? 0,
          'carbs': meal['totalCarbs'] ?? 0,
          'fats': meal['totalFats'] ?? 0,
          'image': meal['imagePath'] ?? 'assets/default.png',
          'isMeal': true,
        });
      }
    }
print("Currently selected filter: $selectedFilterIndex");
print("Favorites saved: $favoriteFoods");

// Apply filters
  // In your build method, modify the filtering logic:

filteredFoodItems = allItems.where((item) {
  final itemName = getItemName(item);
  final isFav = favoriteFoods.contains(itemName);
  
  if (searchQuery.isNotEmpty) {
    return itemName.toLowerCase().contains(searchQuery.toLowerCase());
  }
  
  if (selectedFilterIndex == 0) return true; // All items
  if (selectedFilterIndex == 1) return isFav; // Favorites
  if (selectedFilterIndex == 2) return item['isMeal'] == true; // Meals
  if (selectedFilterIndex == 3) return item['createdByMe'] == true; // Created By Me
  
  return true;
}).toList();

// Apply sorting
    filteredFoodItems.sort((a, b) {
      switch (_selectedSortOption) {
        case 'A-Z':
          return (a['name'] as String).compareTo(b['name'] as String);
        case 'Z-A':
          return (b['name'] as String).compareTo(a['name'] as String);
        case 'Max Calories':
          return (b['calories'] as num).compareTo(a['calories'] as num);
        case 'Min Calories':
          return (a['calories'] as num).compareTo(b['calories'] as num);
        case 'Max Protein':
          return (b['protein'] as num).compareTo(a['protein'] as num);
        case 'Min Protein':
          return (a['protein'] as num).compareTo(b['protein'] as num);
        case 'Max Carbs':
          return (b['carbs'] as num).compareTo(a['carbs'] as num);
        case 'Min Carbs':
          return (a['carbs'] as num).compareTo(b['carbs'] as num);
        case 'Max Fats':
          return (b['fats'] as num).compareTo(a['fats'] as num);
        case 'Min Fats':
          return (a['fats'] as num).compareTo(b['fats'] as num);
        default:
          return 0;
      }
    });
// For meals filter, we'll show saved meals in the grid
    if (selectedFilterIndex == 2) {
      filteredFoodItems = [];
    }
       return PopScope(
    canPop: false, // Blocks the back button
    child: Scaffold(
      drawer: Sidebar(
        toggleDarkMode: () => themeNotifier.toggleTheme(),
        isDarkMode: isDarkMode,
      ),
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(context, isDarkMode),
          _buildSearchBar(isDarkMode),
          _buildFilterChips(isDarkMode),
          _buildFoodGrid(filteredFoodItems, isDarkMode),
        ],
      ),
    ),
  );
}

// In _buildHeader method of GymFitXHome
Widget _buildHeader(BuildContext context, bool isDarkMode) {
  final userProvider = Provider.of<UserProvider>(context);

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(
              isDarkMode ? 'assets/logo2.png' : 'assets/logo.png',
              height: 50,
            ),
            Spacer(),
            CircleAvatar(
              radius: 25,
              backgroundImage: userProvider.user.profileImage != null
                  ? FileImage(userProvider.user.profileImage!)
                  : NetworkImage(
                      "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=1000&auto=format&fit=crop",
                    ) as ImageProvider,
              backgroundColor: Colors.grey[300],
              ),
            ],
          ),
          Text(
            'Fuel your day with smart nutrition',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Lobster',
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey),
                prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.grey[400] : Colors.grey),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(50),
            ),
            child: PopupMenuButton<String>(
              icon: Icon(Icons.filter_list, color: Colors.green),
              onSelected: (String value) {
                setState(() {
                  _selectedSortOption = value;
                });
              },
              itemBuilder: (BuildContext context) {
                return _sortOptions.map((String option) {
                  return PopupMenuItem<String>(
                    value: option,
                    child: Text(
                      option,
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildFilterChips(bool isDarkMode) {
    return Column(
      children: [
        SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              filters.length,
              (index) => GestureDetector(
                onTap: () => setState(() => selectedFilterIndex = index),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: selectedFilterIndex == index
                        ? Colors.green
                        : isDarkMode ? Colors.grey[800] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    filters[index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: selectedFilterIndex == index
                          ? Colors.white
                          : isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFoodGrid(List<Map<String, dynamic>> filteredFoodItems, bool isDarkMode) {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: _refreshSavedMeals,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              if (selectedFilterIndex != 2) ...[
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.all(15),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: filteredFoodItems.length,
                  itemBuilder: (context, index) =>
                      _buildFoodCard(filteredFoodItems[index], isDarkMode),
                ),
              ],
              if (selectedFilterIndex == 0 || selectedFilterIndex == 2) ...[
                if (savedMeals.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      selectedFilterIndex == 2 ? 'Your Meals' : 'Your Saved Meals',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(15),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: savedMeals.length,
                    itemBuilder: (context, index) =>
                        _buildMealCard(savedMeals[index], isDarkMode),
                  ),
                ] else if (!_isLoadingMeals) ...[
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      "No saved meals yet. Create your first meal!",
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
Widget _buildFoodCard(Map<String, dynamic> item, bool isDarkMode) {
  bool isFavorite = favoriteFoods.contains(item['name']);
  final food = item;

  return Container(
    decoration: BoxDecoration(
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: isDarkMode ? Colors.black : Colors.grey.shade400,
          blurRadius: 4,
          spreadRadius: 2,
        ),
      ],
    ),
    child: Stack(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            if (!widget.isFromMealCreator) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductPage(
                    isFavorite: isFavorite,
                    onFavoriteToggle: (bool newFavoriteState) {
                      setState(() {
                        if (newFavoriteState) {
                          favoriteFoods.add(food['name']);
                        } else {
                          favoriteFoods.remove(food['name']);
                        }
                        _saveFavorites();
                      });
                    },
                    onRemove: () {},
                    foodItem: {
                      'name': food['name'],
                      'image': food['image'],
                      'protein': food['protein'],
                      'carbs': food['carbs'],
                      'fats': food['fats'],
                      'calories': food['calories'],
                    },
                    isFromMealCreator: widget.isFromMealCreator, foodFlag: null, onSave: (updatedItem) {  },
                  ),
                ),
              );
            }
          },
          child: Column(
            children: [
              SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                child: Container(
                  height: 100,
                  width: double.infinity,
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                  child: _buildFoodImage(food['image']),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      food['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${food['calories']} calories',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!widget.isFromMealCreator)
          Positioned(
            bottom: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                setState(() {
                String foodName = getItemName(food);
if (isFavorite) {
  favoriteFoods.remove(foodName);
} else {
  favoriteFoods.add(foodName);
}

                });
                _saveFavorites();
              },
              child: Icon(
                Icons.star,
                color: isFavorite ? Colors.green : Colors.grey,
                size: 28,
              ),
            ),
          ),
        if (widget.isFromMealCreator)
          Positioned(
            bottom: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _saveClickedFoodItem(food),
              child: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode ? Colors.black26 : Colors.grey,
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Icon(Icons.add, color: Colors.white, size: 24),
              ),
            ),
          ),
      ],
    ),
  );
}

  Widget _buildMealCard(Map<String, dynamic> meal, bool isDarkMode) {
    String mealName = meal['name'] ?? meal['mealName'] ?? 'Unnamed Meal';
    bool isFavorite = favoriteFoods.contains(mealName);

    return GestureDetector(
      onTap: () => _handleMealTap(meal),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.black : Colors.grey.shade400,
              blurRadius: 4,
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                    child: meal['imagePath'] != null
                        ? Image.file(File(meal['imagePath']), fit: BoxFit.cover)
                        : Icon(Icons.food_bank, size: 50, color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mealName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${meal['totalCalories']?.toString() ?? '0'} kcal',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: GestureDetector(
                onTap: () async {
                  setState(() {
                  String name = getItemName(meal);
if (isFavorite) {
  favoriteFoods.remove(name);
} else {
  favoriteFoods.add(name);
}

                  });
                  await _saveFavorites();
                },
                child: Icon(
                  Icons.star,
                  color: isFavorite ? Colors.green : Colors.grey,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
// Add this helper method to handle all image types
Widget _buildFoodImage(String? imagePath) {
  if (imagePath == null) {
    return Icon(Icons.food_bank, size: 50, color: Colors.grey);
  }
  
  if (imagePath.startsWith('http')) {
    return CachedNetworkImage(
      imageUrl: imagePath,
      fit: BoxFit.cover,
      errorWidget: (context, url, error) => 
          Icon(Icons.food_bank, size: 50, color: Colors.grey),
    );
  } else if (imagePath.startsWith('/') || imagePath.contains('data/')) {
    return Image.file(
      File(imagePath),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => 
          Icon(Icons.food_bank, size: 50, color: Colors.grey),
    );
  } else {
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => 
          Icon(Icons.food_bank, size: 50, color: Colors.grey),
    );
  }
}

  Widget _buildSavedMealsBox() {
    if (savedMeals.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Text(
            'Your Saved Meals',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 15),
            itemCount: savedMeals.length,
            itemBuilder: (context, index) {
              final meal = savedMeals[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductPage(
                        isFavorite: false,
                        onFavoriteToggle: (bool newFavoriteState) {
                          // Handle favorite toggle
                        },
                        onRemove: () {
                          // Handle removal logic
                        },
                        foodItem: {
                          'name': meal['mealName'] ??
                              meal['name'] ??
                              'Unnamed Meal',
                          'image': meal['imagePath'] ?? 'assets/default.png',
                          'protein': meal['totalProtein'] ?? 0,
                          'carbs': meal['totalCarbs'] ?? 0,
                          'fats': meal['totalFats'] ?? 0,
                          'calories': meal['totalCalories'] ?? 0,
                          'isMeal': true,
                          'foods': meal['foods'] ??
                              [], // Make sure this contains all ingredients
                        },
                        isFromMealCreator:
                            true, foodFlag: null, onSave: (updatedItem) {  }, // Explicitly set to false for saved meals
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 150,
                  margin: EdgeInsets.only(right: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade400,
                        blurRadius: 4,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(30)),
                        child: meal['imagePath'] != null
                            ? Image.file(
                                File(meal['imagePath']),
                                height: 100,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                height: 100,
                                color: Colors.grey[200],
                                child:
                                    Center(child: Icon(Icons.photo, size: 40)),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meal['mealName'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${meal['totalCalories']} kcal',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload saved meals when returning to this screen
    _loadSavedMeals();
  }
}