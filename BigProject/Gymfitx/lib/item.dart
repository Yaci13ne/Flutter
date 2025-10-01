import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'basket_manager.dart';
import 'theme_notifier.dart'; // Add this import
import 'package:provider/provider.dart'; // Add this import

class ProductPage extends StatefulWidget {
  final bool isFavorite;
  final Function(bool) onFavoriteToggle;
  final VoidCallback onRemove;
  final Map<String, dynamic> foodItem;
  final bool isFromMealCreator;

  const ProductPage({
    super.key,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onRemove,
    required this.foodItem, 
    this.isFromMealCreator = false, required foodFlag, required Null Function(dynamic updatedItem) onSave,
  });

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  String getFoodName() => widget.foodItem['name'] ?? "Unknown Food";
  String getFoodImage() => widget.foodItem['image'] ?? 'assets/default.png';

  Map<String, dynamic> getFoodMacros() {
    return {
      'protein': widget.foodItem['protein'] ?? 0,
      'carbs': widget.foodItem['carbs'] ?? 0,
      'fats': widget.foodItem['fats'] ?? 0,
      'calories': widget.foodItem['calories'] ?? 0,
    };
  }

  late bool isFavorite;
  int quantity = 100;
  bool isAddedToBasket = false;
  late double baseProtein, baseCarbs, baseFats;
  late int baseCalories;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isFavorite;
    isAddedToBasket = BasketManager().isItemAdded(getFoodName());
    final macros = getFoodMacros();
    baseProtein = macros['protein'];
    baseCarbs = macros['carbs'];
    baseFats = macros['fats'];
    baseCalories = macros['calories'];
  }

  Widget _buildMainFoodImage() {
    final imagePath = getFoodImage();
    
    if (imagePath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imagePath,
        width: double.infinity,
        height: 190,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => _buildImagePlaceholder(),
      );
    } 
    else if (imagePath.startsWith('/') || imagePath.contains('data/')) {
      return Image.file(
        File(imagePath),
        width: double.infinity,
        height: 190,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
      );
    } 
    else {
      return Image.asset(
        imagePath,
        width: double.infinity,
        height: 190,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
      );
    }
  }

  Widget _buildImagePlaceholder() {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    return Container(
      color: themeNotifier.isDarkMode ? Colors.grey[800] : Colors.grey[200],
      child: Center(
        child: Icon(Icons.food_bank, size: 50, color: Colors.grey),
      ),
    );
  }

  double get protein => baseProtein * (quantity / 100);
  double get carbs => baseCarbs * (quantity / 100);
  double get fats => baseFats * (quantity / 100);
  double get calories => (baseCalories * (quantity / 100));

  void _addToBasket() {
    if (isAddedToBasket) return;

    BasketManager().addItem({
      'name': getFoodName(),
      'image': getFoodImage(),
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'calories': calories.round(),
    });

    setState(() {
      isAddedToBasket = true;
    });
  }Widget _buildIngredientsList() {
  // Add debug logging
  print('Building ingredients list for foodItem: ${widget.foodItem}');
  
  // Check for foods data in multiple possible locations
  dynamic foodsData = widget.foodItem['foods'] ?? widget.foodItem['ingredients'];
  
  // Convert to List if it isn't already
  List? foods;
  if (foodsData is List) {
    foods = foodsData;
  } else if (foodsData != null) {
    foods = [foodsData];
  }

  if (foods == null || foods.isEmpty) {
    print('No ingredients found or empty list');
    return SizedBox.shrink();
  }

  print('Found ${foods.length} ingredients');
  
  final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);

  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: themeNotifier.isDarkMode
            ? [Colors.grey[900]!, Colors.grey[900]!]
            : [const Color.fromARGB(255, 255, 255, 255), const Color.fromARGB(255, 153, 226, 150)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          'Meal Ingredients',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: themeNotifier.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        children: foods.map((food) {
          try {
            // Handle case where food might be a Map or a String
            Map<String, dynamic> foodMap;
            if (food is Map) {
              foodMap = Map<String, dynamic>.from(food);
            } else if (food is String) {
              foodMap = json.decode(food) as Map<String, dynamic>;
            } else {
              return ListTile(
                title: Text('Invalid ingredient format',
                    style: TextStyle(color: Colors.red)),
              );
            }

            return ListTile(
              leading: _buildFoodImage(foodMap['image']),
              title: Text(
                foodMap['name'] ?? 'Unknown',
                style: TextStyle(
                  color: themeNotifier.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              subtitle: Text(
                '${foodMap['calories']?.toString() ?? '0'} kcal | '
                'P: ${foodMap['protein']?.toStringAsFixed(1) ?? '0'}g '
                'C: ${foodMap['carbs']?.toStringAsFixed(1) ?? '0'}g '
                'F: ${foodMap['fats']?.toStringAsFixed(1) ?? '0'}g',
                style: TextStyle(
                  color: themeNotifier.isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            );
          } catch (e) {
            print('Error rendering food item: $e');
            return ListTile(
              title: Text('Could not display ingredient',
                  style: TextStyle(color: Colors.red)),
            );
          }
        }).toList(),
      ),
    ),
  );
}
  Widget _buildFoodItem(Map<String, dynamic> food) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    
    return ListTile(
      leading: _buildFoodImage(food['image']),
      title: Text(
        food['name'] ?? 'Unknown',
        style: TextStyle(color: themeNotifier.isDarkMode ? Colors.white : Colors.black),
      ),
      subtitle: Text(
        '${food['calories']?.toString() ?? '0'} kcal | '
        'P: ${food['protein']?.toStringAsFixed(1) ?? '0'}g '
        'C: ${food['carbs']?.toStringAsFixed(1) ?? '0'}g '
        'F: ${food['fats']?.toStringAsFixed(1) ?? '0'}g',
        style: TextStyle(color: themeNotifier.isDarkMode ? Colors.white70 : Colors.black54),
      ),
    );
  }

  Widget _buildFoodImage(String? image) {
    if (image == null) return const Icon(Icons.fastfood, size: 40);

    if (image.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: image,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
      );
    } else if (image.startsWith('/') || image.startsWith('data/')) {
      return Image.file(
        File(image),
        width: 40,
        height: 40,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        image,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => 
            const Icon(Icons.fastfood, size: 40),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final backgroundColor = themeNotifier.isDarkMode ? Colors.grey[900]! : Color(0xFFF3F4F6);
    final cardColor = themeNotifier.isDarkMode ? Colors.grey[900]! : Colors.white;
    final textColor = themeNotifier.isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 15, top: 20),
          child: IconButton(
            icon: Icon(Icons.close, color: textColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: _buildMainFoodImage(),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            getFoodName(),
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: isAddedToBasket
                              ? () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        backgroundColor: cardColor,
                                        title: Text(
                                          "Remove Item",
                                          style: TextStyle(color: textColor),
                                        ),
                                        content: Text(
                                          "Are you sure you want to remove this item from the basket?",
                                          style: TextStyle(color: textColor),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              "Cancel",
                                              style: TextStyle(color: Colors.green),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              BasketManager().removeItem(getFoodName());
                                              widget.onRemove();
                                              setState(() {
                                                isAddedToBasket = false;
                                              });
                                              Navigator.of(context).pop();
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              "Remove",
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isAddedToBasket
                                ? Colors.red
                                : Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text('Remove', style: TextStyle(color: Colors.white)),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  quantity = (quantity - 100).clamp(0, 1000);
                                });
                              },
                              icon: Icon(Icons.remove),
                              color: Colors.green,
                            ),
                            GestureDetector(
                              onTap: () {
                                FocusScope.of(context).requestFocus(FocusNode());
                              },
                              child: Container(
                                width: 100,
                                height: 30,
                                padding: EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.green),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: TextField(
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(color: textColor),
                                  ),
                                  style: TextStyle(color: textColor),
                                  controller: TextEditingController(text: '$quantity'),
                                  onSubmitted: (value) {
                                    setState(() {
                                      quantity = int.tryParse(value) ?? 100;
                                      quantity = quantity.clamp(0, 1000);
                                    });
                                  },
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  quantity = (quantity + 100).clamp(0, 1000);
                                });
                              },
                              icon: Icon(Icons.add),
                              color: Colors.green,
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              isFavorite = !isFavorite;
                            });
                            widget.onFavoriteToggle(isFavorite);
                          },
                          icon: Icon(
                            isFavorite ? Icons.star : Icons.star_border,
                            color: isFavorite ? Colors.green : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: Padding(
                        padding: EdgeInsets.only(top: 55),
                        child: CustomPaint(
                          painter: NutritionRingPainter(
                            protein: protein,
                            carbs: carbs,
                            fats: fats,
                            calories: calories,
                            textColor: textColor, // Pass text color to painter
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 150),
                    if (widget.isFromMealCreator) _buildIngredientsList(),
                    SizedBox(height: 2),
                    ElevatedButton(
                      onPressed: isAddedToBasket ? null : _addToBasket,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAddedToBasket
                            ? Colors.grey
                            : Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_basket, color: Colors.white),
                          SizedBox(width: 3, height: 3),
                          Text(
                            isAddedToBasket ? 'Added' : 'Add to Basket',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NutritionRingPainter extends CustomPainter {
  final double protein;
  final double carbs;
  final double fats;
  final double calories;
  final Color textColor;

  NutritionRingPainter({
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.calories,
    this.textColor = Colors.black,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double total = protein + carbs + fats;
    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);
    final double strokeWidth = 12;
    final Rect rect =
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    double startAngle = -pi / 2;
    final double proteinAngle = (protein / total) * 2 * pi;
    final double carbsAngle = (carbs / total) * 2 * pi;
    final double fatsAngle = (fats / total) * 2 * pi;

    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    paint.color = Colors.red;
    canvas.drawArc(rect, startAngle, proteinAngle, false, paint);
    startAngle += proteinAngle;

    paint.color = Colors.blue;
    canvas.drawArc(rect, startAngle, carbsAngle, false, paint);
    startAngle += carbsAngle;

    paint.color = Colors.cyan;
    canvas.drawArc(rect, startAngle, fatsAngle, false, paint);

    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: '$calories kcal',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          color: textColor, // Use the provided text color
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
        canvas, center - Offset(textPainter.width / 2, textPainter.height / 2));

    _drawLabel(canvas, center, radius, -pi / 2 + proteinAngle / 2, "${protein.toStringAsFixed(1)}g", "Protein", Colors.red, 10, lineLength: 12, extendedLine: 38);
    _drawLabel(canvas, center, radius, -pi / 2 + proteinAngle + carbsAngle / 2, "${carbs.toStringAsFixed(1)}g", "Carbohydrates", Colors.blue, 35, lineLength: 43, extendedLine: 145);
    _drawLabel(canvas, center, radius, -pi / 2 + proteinAngle + carbsAngle + fatsAngle / 2, "${fats.toStringAsFixed(1)}g", "Fats", Colors.cyan, 60, lineLength: 50, extendedLine: 15);
  }

  void _drawLabel(Canvas canvas, Offset center, double radius, double angle,
      String value, String label, Color color, double offsetAngle,
      {required double lineLength, required double extendedLine}) {
    final double lineOffset = 30;

    final Offset dotPosition = Offset(
      center.dx + radius * cos(angle),
      center.dy + radius * sin(angle),
    );

    final Offset slantedLineEnd = Offset(
      dotPosition.dx + lineLength * cos(angle),
      dotPosition.dy + lineLength * sin(angle),
    );

    final Offset finalLineEnd = Offset(
      slantedLineEnd.dx + extendedLine,
      slantedLineEnd.dy,
    );

    Paint linePaint = Paint()
      ..color = color
      ..strokeWidth = 2;
    canvas.drawLine(dotPosition, slantedLineEnd, linePaint);
    canvas.drawLine(slantedLineEnd, finalLineEnd, linePaint);

    Paint circlePaint = Paint()..color = Colors.black;
    canvas.drawCircle(dotPosition, 3, circlePaint);

    TextPainter valuePainter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    valuePainter.layout();
    valuePainter.paint(
        canvas, finalLineEnd + Offset(-valuePainter.width / 8, -17));

    TextPainter labelPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 15,
          fontStyle: FontStyle.italic,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    labelPainter.layout();
    labelPainter.paint(
        canvas, finalLineEnd + Offset(-labelPainter.width / 5, 10));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}