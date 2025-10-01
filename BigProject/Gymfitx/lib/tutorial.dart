import 'package:flutter/material.dart';

class TutorialPage extends StatelessWidget {
  const TutorialPage({super.key});

  final List<TutorialSection> sections = const [
    TutorialSection(
      title: 'The full Way to Track Your Food',
      steps: [
        TutorialItemData(imagePath: 'pictures/pp1.png', title: 'Step 1', description: 'Open the "Food" page and choose the food you wanna eat.'),
        TutorialItemData(imagePath: 'pictures/pp2.png', title: 'Step 2', description: 'Check if the food macros are the right one for you and add the food to Basket.'),
        TutorialItemData(imagePath: 'pictures/pp3.png', title: 'Step 3', description: 'Go to "Basket" and when you finished eating click here'),
        TutorialItemData(imagePath: 'pictures/pp4.png', title: 'Step 4', description: 'Now the food will appear in the category "Finished eating".'),
        TutorialItemData(imagePath: 'pictures/Home.png', title: 'Step 5', description: 'Now you can track your day in the "Home".'),
      ],
    ),
    TutorialSection(
      title: 'The Way to Insert Your Food',
      steps: [
        TutorialItemData(imagePath: 'pictures/ppinsert.png', title: 'Step 1', description: 'Tap "Insert food" from the menu.'),
        TutorialItemData(imagePath: 'pictures/ppinsert2.png', title: 'Step 2', description: 'Fill the name, description and all the macros.'),
        TutorialItemData(imagePath: 'pictures/ppinsert2.5.png', title: 'Step 3', description: 'Click on "Save food".'),
        TutorialItemData(imagePath: 'pictures/ppinsert3.png', title: 'Step 4', description: 'Now your food is on the "Created by me" category.'),
      ],
    ),
    TutorialSection(
      title: 'The Way to Create Your Meal',
      steps: [
        TutorialItemData(imagePath: 'pictures/ppcreate.png', title: 'Step 1', description: 'Tap "Create Meal" from the menu.'),
        TutorialItemData(imagePath: 'pictures/ppcreate2.png', title: 'Step 2', description: 'Select foods to include in your meal, name your meal and add a description.'),
        TutorialItemData(imagePath: 'pictures/ppcreate3.png', title: 'Step 3', description: 'Click on "Save food".'),
        TutorialItemData(imagePath: 'pictures/ppcreate4.png', title: 'Step 4', description: 'You can see your food in the "meals" category.'),
        TutorialItemData(imagePath: 'pictures/pping.png', title: 'Step 5', description: 'You can check your meal ingredient.'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorial'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final section = sections[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                section.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 10, 68, 13), // You can change this color
                ),
              ),
              const SizedBox(height: 16),
              ...section.steps.map((item) => TutorialItem(item: item)),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}

class TutorialSection {
  final String title;
  final List<TutorialItemData> steps;

  const TutorialSection({required this.title, required this.steps});
}

class TutorialItemData {
  final String imagePath;
  final String title;
  final String description;

  const TutorialItemData({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}

class TutorialItem extends StatelessWidget {
  final TutorialItemData item;

  const TutorialItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            child: Image.asset(
              item.imagePath,
              fit: BoxFit.contain,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color.fromARGB(255, 224, 224, 224),
                height: 200,
                child: const Center(
                  child: Icon(Icons.broken_image, size: 50),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}