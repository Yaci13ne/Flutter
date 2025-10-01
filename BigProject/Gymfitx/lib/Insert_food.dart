import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme_notifier.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InsertFoodScreen extends StatefulWidget {
  const InsertFoodScreen({super.key});

  @override
  _InsertFoodScreenState createState() => _InsertFoodScreenState();
}

class _InsertFoodScreenState extends State<InsertFoodScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController caloriesController = TextEditingController();
  final TextEditingController proteinController = TextEditingController();
  final TextEditingController carbsController = TextEditingController();
  final TextEditingController fatsController = TextEditingController();
  
  XFile? _selectedImage;
  List<Map<String, String>> foodList = [];
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedFoods = prefs.getStringList('food_list');
    bool? savedDarkMode = prefs.getBool('isDarkMode');

    setState(() {
      foodList = savedFoods?.map((food) {
        List<String> fields = food.split(',');
        return {
          'name': fields[0],
          'description': fields[1],
          'calories': fields[2],
          'protein': fields[3],
          'carbs': fields[4],
          'fats': fields[5],
          'image': fields.length > 6 ? fields[6] : '',
        };
      }).toList()?? [];
    });
  
    setState(() {
      _isDarkMode = savedDarkMode ?? Theme.of(context).brightness == Brightness.dark;
    });
  }

  Future<void> _toggleDarkMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    await prefs.setBool('isDarkMode', _isDarkMode);
  
  
  
  
  }
  
  
  
void saveFood() async {
  if (nameController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please enter a food name')),
    );
    return;
  }

  Map<String, dynamic> newFood = {
    'name': nameController.text,
    'description': descriptionController.text,
    'calories': caloriesController.text,
    'protein': proteinController.text,
    'carbs': carbsController.text,
    'fats': fatsController.text,
    'image': _selectedImage?.path ?? '',
    'createdByMe': true,  // Add this flag
    'isMeal': false,      // Make sure it's not marked as a meal
  };

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? clickedJson = prefs.getString('clickedItems');
  List<Map<String, dynamic>> clickedItems = [];

// Line 97
clickedItems = List<Map<String, dynamic>>.from(json.decode(clickedJson ?? '[]'));
  // Avoid duplicate
  if (!clickedItems.any((item) => item['name'] == newFood['name'])) {
    clickedItems.add(newFood);
    await prefs.setString('clickedItems', json.encode(clickedItems));
  }

  Navigator.pop(context, newFood);
}
  Future<void> _saveToPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedFoods = foodList.map((food) =>
      "${food['name']},${food['description']},${food['calories']},${food['protein']},${food['carbs']},${food['fats']},${food['image']}"
    ).toList();
    
    await prefs.setStringList('food_list', savedFoods);
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

@override
  Widget build(BuildContext context) {
  final themeNotifier = Provider.of<ThemeNotifier>(context);
  final isDarkMode = themeNotifier.isDarkMode;

  return Scaffold(
    backgroundColor: isDarkMode ? const Color(0xFF212121) : Colors.white,
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
                  'Insert food',
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
            Center(
              child: GestureDetector(
                onTap: pickImage,
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
              SizedBox(height: 3),

              _buildTextField(nameController, 'Name'),
              SizedBox(height: 5),
              _buildTextField(descriptionController, 'Description', maxLines: 3),
          

              Text('Food Macros', 
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode ? Colors.white : Colors.black,
                  )),
              SizedBox(height: 5),

              _buildTextField(caloriesController, 'Calories', keyboardType: TextInputType.number),
              SizedBox(height: 5),
              _buildTextField(proteinController, 'Protein', keyboardType: TextInputType.number),
              SizedBox(height: 5),
              _buildTextField(carbsController, 'Carbs', keyboardType: TextInputType.number),
              SizedBox(height: 5),
              _buildTextField(fatsController, 'Fats', keyboardType: TextInputType.number),
              SizedBox(height: 5),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saveFood,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, 
                    backgroundColor: _isDarkMode ? Colors.green[800] : Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Save Food', style: TextStyle(fontSize: 18)),
                ),
              ),
              SizedBox(height: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: _isDarkMode ? Colors.green[900] : Colors.green,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 2),
                Text(
                  'Food Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: _isDarkMode ? Colors.white : Colors.black),
            title: Text(_isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode'),
            onTap: () {
              _toggleDarkMode();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
    );
  }
}