import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'app.dart'; // Import GymFitXHome
import 'theme_notifier.dart'; // Import ThemeNotifier

class MealCreator extends StatefulWidget {
  final FoodItem? initialFoodItem;

  const MealCreator({super.key, this.initialFoodItem});

  @override
  _MealCreatorState createState() => _MealCreatorState();
}

class _MealCreatorState extends State<MealCreator> {
  List<Map<String, dynamic>> mealList = []; // Liste des repas
  List<Map<String, String>> selectedFoods = []; // Liste des aliments choisis
  List<Map<String, String>> foodList = []; // Stores food items
 
  final TextEditingController nameController = TextEditingController();
  final TextEditingController caloriesController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  
  List<FoodItem> foodItems = [];
  List<Map<String, dynamic>> savedFoodItems = [];
  final uuid = Uuid();
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
@override
void initState() {
  super.initState();
  _loadSavedMeals();
  _loadSavedItems(); // ✅ Load clicked items
}

  Future<void> _saveToPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedMeals = mealList.map((meal) => 
      "${meal['name']},${meal['description']},${meal['foods'].join('|')}"
    ).toList();
    
    await prefs.setStringList('meal_list', savedMeals);
  }

  Future<void> _loadSavedMeals() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedMeals = prefs.getStringList('meal_list');

    setState(() {
      mealList = savedMeals?.map((meal) {
        List<String> fields = meal.split(',');
        return {
          'name': fields[0],
          'description': fields[1],
          'foods': fields.sublist(2), // Stocker les aliments dans le repas
        };
      }).toList()?? [];
    });
    }

  Future<void> _loadSavedItems() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? savedItemsJson = prefs.getString('clickedItems');
final loadedItems = List<Map<String, dynamic>>.from(json.decode(savedItemsJson ?? '[]'));
  setState(() {
    savedFoodItems = loadedItems;
    for (var item in savedFoodItems) {
      foodItems.add(FoodItem(
        id: uuid.v4(),
        name: item['name'],
        description: "${item['calories']} calories",
        image: item['image'],
        protein: item['protein']?.toDouble() ?? 0.0,
        carbs: item['carbs']?.toDouble() ?? 0.0,
        fats: item['fats']?.toDouble() ?? 0.0,
      ));
    }
  });
}


  int getTotalCalories() {
    return foodItems.fold(0, (sum, item) {
      int calories = int.tryParse(item.description.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return sum + calories;
    });
  }

  double getTotalProtein() {
    return foodItems.fold(0, (sum, item) => sum + item.protein);
  }

  double getTotalCarbs() {
    return foodItems.fold(0, (sum, item) => sum + item.carbs);
  }

  double getTotalFats() {
    return foodItems.fold(0, (sum, item) => sum + item.fats);
  }

  Future<void> pickImage2() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  void addFoodItem() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => GymFitXHome(isFromMealCreator: true),
      ),
    );

    if (result != null) {
      setState(() {
        foodItems.add(FoodItem(
          id: uuid.v4(),
          name: result['name'] ?? 'Unknown',
          description: "${result['calories'] ?? '0'} calories",
          image: result['image'],
          protein: result['protein']?.toDouble() ?? 133,
          carbs: result['carbs']?.toDouble() ?? 333,
          fats: result['fats']?.toDouble() ?? 69,
        ));
      });
    }
  }

  void _showSavedItemsDialog() {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    final isDarkMode = themeNotifier.isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        title: Text(
          "Saved Food Items",
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: savedFoodItems.isEmpty
              ? Center(
                  child: Text(
                    "No saved items yet",
                    style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: savedFoodItems.length,
                  itemBuilder: (context, index) {
                    final item = savedFoodItems[index];
                    return Card(
                      color: isDarkMode ? Colors.grey[800] : Colors.white,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        textColor: isDarkMode ? Colors.white : Colors.black,
                        leading: _buildFoodImage(foodItems[index].image),
                        title: Text(foodItems[index].name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              foodItems[index].description,
                              style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[700]),
                            ),
                            Text(
                              "P: ${foodItems[index].protein}g C: ${foodItems[index].carbs}g F: ${foodItems[index].fats}g",
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => removeFoodItem(foodItems[index].id),
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Close",
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  void removeFoodItem(String id) {
    setState(() {
      foodItems.removeWhere((item) => item.id == id);
    });
  }

  void saveMeal() {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a meal name')),
      );
      return;
    }

    Map<String, dynamic> meal = {
      'name': nameController.text,
      'description': descriptionController.text,
      'foods': foodItems.map((food) => {
        'name': food.name,
        'calories': int.tryParse(food.description.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
        'protein': food.protein,
        'carbs': food.carbs,
        'fats': food.fats,
        'image': food.image,
      }).toList(),
      'totalCalories': getTotalCalories(),
      'totalProtein': getTotalProtein(),
      'totalCarbs': getTotalCarbs(),
      'totalFats': getTotalFats(),
      'imagePath': _selectedImage?.path,
      'createdAt': DateTime.now().toIso8601String(),
    };

    Navigator.pop(context, meal);
  }

  @override
Widget build(BuildContext context) {
  final themeNotifier = Provider.of<ThemeNotifier>(context);
  final isDarkMode = themeNotifier.isDarkMode;

  return Scaffold(
    backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Empty container to balance the row
                Container(width: 40),
                // Centered title
                Text(
                  'Create a Meal',
                  style: TextStyle(
                    fontSize: 22, 
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                // Close button on the right
                IconButton(
                  icon: Icon(Icons.close, size: 28, color: isDarkMode ? Colors.white : Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            // Rest of your existing code...
            SizedBox(height: 10),
            Center(
              child: GestureDetector(
                onTap: pickImage2,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: isDarkMode ? Colors.green[800] : Colors.green,
                  backgroundImage:
                      _selectedImage != null ? FileImage(File(_selectedImage!.path)) : null,
                  child: _selectedImage == null
                      ? Icon(Icons.camera_alt, size: 40, color: Colors.white)
                      : null,
                ),
              ),
            ),
              SizedBox(height: 10),
              TextField(
                controller: nameController,
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: 'Meal Name',
                  hintStyle: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Description',
                  hintStyle: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[900] : Colors.grey[300],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Food Items',
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.add_circle, 
                          color: isDarkMode ? Colors.green[300] : Colors.green, 
                          size: 28,
                        ),
                        onPressed: addFoodItem,
                      ),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: foodItems.isEmpty
                    ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            SizedBox(height: 10),
                            DottedBorder(
                              strokeWidth: 2,
                              dashPattern: [6, 3],
                              borderType: BorderType.RRect,
                              radius: Radius.circular(12),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 40),
                                alignment: Alignment.center,
                                child: Text(
                                  'No food items yet',
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.grey[400] : Colors.black54, 
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: foodItems.length,
                        itemBuilder: (context, index) {
                          return Card(
                            color: isDarkMode ? Colors.grey[800] : Colors.white,
                            margin: EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              textColor: isDarkMode ? Colors.white : Colors.black,
                              leading: _buildFoodImage(foodItems[index].image),
                              title: Text(foodItems[index].name),
                              subtitle: Text(
                                foodItems[index].description,
                                style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[700]),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => removeFoodItem(foodItems[index].id),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_fire_department, color: Colors.red, size: 28),
                        SizedBox(width: 8),
                        TweenAnimationBuilder<int>(
                          tween: IntTween(begin: 0, end: getTotalCalories()),
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
                    SizedBox(height: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNutritionInfo('Protein', '${getTotalProtein().toStringAsFixed(1)}g', Colors.blue),
                        _buildNutritionInfo('Carbs', '${getTotalCarbs().toStringAsFixed(1)}g', Colors.orange),
                        _buildNutritionInfo('Fats', '${getTotalFats().toStringAsFixed(1)}g', Colors.red),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saveMeal,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: isDarkMode ? Colors.green[700] : Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Save Meal', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionInfo(String label, String value, Color color) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    final isDarkMode = themeNotifier.isDarkMode;

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void saveFood() {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a food name')),
      );
      return;
    }

    Map<String, String> food = {
      'name': nameController.text,
      'description': descriptionController.text,
      'calories': caloriesController.text,
      'image': _selectedImage?.path ?? '',
    };

    foodList.add(food);
    _saveToPreferences();
    Navigator.pop(context, food);
  }

  Widget _buildFoodImage(String? imagePath) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    final isDarkMode = themeNotifier.isDarkMode;

    if (imagePath == null || imagePath.isEmpty) {
      return Icon(
        Icons.fastfood, 
        size: 40,
        color: isDarkMode ? Colors.white : Colors.black,
      );
    }

    if (imagePath.contains('assets/')) {
      final cleanPath = imagePath.replaceFirst('file://', '');
      return Image.asset(
        cleanPath,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.fastfood, 
          size: 40,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      );
    }
    else if (imagePath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imagePath,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        placeholder: (context, url) => Icon(
          Icons.fastfood, 
          size: 40,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        errorWidget: (context, url, error) => Icon(Icons.error),
      );
    }
    else {
      try {
        return Image.file(
          File(imagePath),
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.fastfood, 
            size: 40,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        );
      } catch (e) {
        return Icon(
          Icons.fastfood, 
          size: 40,
          color: isDarkMode ? Colors.white : Colors.black,
        );
      }
    }
  }
}

class FoodItem {
  String id;
  String name;
  String description;
  String? image;
  double protein;
  double carbs;
  double fats;

  FoodItem({
    required this.id, 
    required this.name, 
    required this.description, 
    this.image,
    this.protein = 0,
    this.carbs = 0,
    this.fats = 0,
  });
}