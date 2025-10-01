import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme_notifier.dart';
import 'package:provider/provider.dart';
import 'basket_manager.dart';
import 'sidebar.dart';
import 'user_provider.dart';

class Dashboard extends StatefulWidget {
  final NutritionGoals? goals;



  const Dashboard({super.key, this.goals});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentTipIndex = 0;
  final List<String> _tips = [
    "Fuel Up Before Training! 💪\nEat complex carbs like oats, bananas, or whole wheat toast 30-60 minutes before your workout for sustained energy.",
    "Stay Hydrated! 💧\nDrink plenty of water throughout the day, especially before, during, and after exercise.",
    "Protein is Key! 🥩\nInclude a source of protein in every meal to help repair and build muscle tissue.",
    "Don't Skip Breakfast! 🍳\nStart your day with a balanced breakfast to kickstart your metabolism.",
    "Healthy Snacking! 🥜\nChoose healthy snacks like nuts, fruits, or yogurt to keep your energy levels stable."
  ];

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        _currentTipIndex = (_currentTipIndex + 1) % _tips.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final basketManager = Provider.of<BasketManager>(context);
    final userProvider =
        Provider.of<UserProvider>(context); // Get the user provider
    String today =
        "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";

    print('Final goals in Dashboard: ${widget.goals?.dailyCalories}');

    final goals = widget.goals ?? userProvider.calculateNutritionGoals();
    final dailyCalories = goals.dailyCalories;
    final proteinGoal = goals.proteinGoal;
    final fatGoal = goals.fatGoal;
    final carbsGoal = goals.carbsGoal;
    final weight = goals.weight;
    print('Final goals in Dashboard: ${widget.goals?.weight}');
    print('Final go0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000als in Dashboard: ${widget.goals?.height}');
    print('Final go00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000als in Dashboard: ${widget.goals?.age}');

    return Scaffold(
      drawer: Sidebar(
        toggleDarkMode: () => themeNotifier.toggleTheme(),
        isDarkMode: themeNotifier.isDarkMode,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(themeNotifier.isDarkMode
                ? 'assets/fill3.png'
                : 'assets/fill.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    themeNotifier.isDarkMode
                        ? 'assets/logo2.png'
                        : 'assets/logo.png',
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
                  color: themeNotifier.isDarkMode
                      ? Colors.white
                      : const Color.fromRGBO(0, 0, 0, 1),
                ),
              ),
              SizedBox(height: 10),

              /// Date Section
              SizedBox(height: 0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today",
                    style: TextStyle(
                      color: themeNotifier.isDarkMode
                          ? Colors.green[300]
                          : Colors.green[900],
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    today,
                    style: TextStyle(
                      color: themeNotifier.isDarkMode
                          ? Colors.green[300]
                          : Colors.green[800],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50),

              /// Progress Circle (Calories)
              Center(
                child: HomePageProgress(
                  percentage:
                      (basketManager.totalCalories / dailyCalories) * 100,
                  color: themeNotifier.isDarkMode
                      ? Colors.green[300]!
                      : Colors.green,
                  size: 160,
                  label: "Calories",
                  value: "${basketManager.totalCalories} kcal",
                  total: "$dailyCalories kcal",
                ),
              ),
              SizedBox(height: 30),

              /// Macronutrient Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  HomePageProgress(
                    percentage: (basketManager.totalFats / fatGoal) * 100,
                    color: themeNotifier.isDarkMode
                        ? Color.fromARGB(255, 100, 150, 255)
                        : Color.fromARGB(255, 20, 0, 243),
                    label: "Fat",
                    value: "${basketManager.totalFats}g",
                    total: "${fatGoal}g",
                  ),
                  HomePageProgress(
                    percentage: (basketManager.totalCarbs / carbsGoal) * 100,
                    color: themeNotifier.isDarkMode
                        ? Color.fromARGB(255, 255, 180, 80)
                        : Color.fromARGB(255, 255, 128, 1),
                    label: "Carbs",
                    value: "${basketManager.totalCarbs}g",
                    total: "${carbsGoal}g",
                  ),
                  HomePageProgress(
                    percentage:
                        (basketManager.totalProtein / proteinGoal) * 100,
                    color: themeNotifier.isDarkMode
                        ? Color.fromARGB(255, 255, 100, 100)
                        : Colors.red,
                    label: "Protein",
                    value: "${basketManager.totalProtein}g",
                    total: "${proteinGoal}g",
                  ),
                ],
              ),
              SizedBox(height: 80),

              /// Tips Section
              Card(
                color:
                    themeNotifier.isDarkMode ? Colors.grey[900] : Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tips",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: themeNotifier.isDarkMode
                              ? Colors.green[300]
                              : Colors.green[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _tips[_currentTipIndex],
                        style: TextStyle(
                          fontSize: 14,
                          color: themeNotifier.isDarkMode
                              ? Colors.green[200]
                              : Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePageProgress extends StatelessWidget {
  final double percentage;
  final Color color;
  final double size;
  final String label;
  final String value;
  final String total;

  const HomePageProgress({
    super.key,
    required this.percentage,
    required this.color,
    this.size = 120,
    required this.label,
    required this.value,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);

    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: RingChartPainter(
                  percentage,
                  color,
                  backgroundColor: themeNotifier.isDarkMode
                      ? Colors.grey[700]!
                      : Colors.grey[300]!,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    '$value / $total',
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class RingChartPainter extends CustomPainter {
  final double percentage;
  final Color color;
  final Color backgroundColor;

  RingChartPainter(this.percentage, this.color,
      {this.backgroundColor = Colors.grey});

  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = size.width * 0.15;
    double radius = size.width / 2;

    Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    Paint fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(
        Offset(radius, radius), radius - strokeWidth / 2, backgroundPaint);

    double angle = max((percentage / 100) * 2 * pi, 0.05);
    Rect rect = Rect.fromCircle(
        center: Offset(radius, radius), radius: radius - strokeWidth / 2);
    canvas.drawArc(rect, -pi / 2, angle, false, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class NutritionGoals {
  final int dailyCalories;
  final int proteinGoal;
  final int fatGoal;
  final int carbsGoal;
  final int weight;
  final int height;
  final int age;

  const NutritionGoals(
      {required this.dailyCalories,
      required this.proteinGoal,
      required this.fatGoal,
      required this.carbsGoal,
      required this.weight
            ,required this.height,
      required this.age
      });
}
