// user_data.dart
class UserData {
  final String gender;
  final int weight; // in kg
  final int height; // in cm
  final String activityLevel;
  final String goal;
  final int age; // You might want to add age later

  UserData({
    required this.gender,
    required this.weight,
    required this.height,
    required this.activityLevel,
    required this.goal,
    required this.age,
  });

  // Calculate Basal Metabolic Rate (BMR) using Mifflin-St Jeor Equation
  double calculateBMR() {
    if (gender == 'Male') {
      return 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      return 10 * weight + 6.25 * height - 5 * age - 161;
    }
  }

  // Calculate Total Daily Energy Expenditure (TDEE)
  double calculateTDEE() {
    double bmr = calculateBMR();
    double activityMultiplier;

    switch (activityLevel) {
      case "Not Very Active":
        activityMultiplier = 1.2;
        break;
      case "Lightly Active":
        activityMultiplier = 1.375;
        break;
      case "Moderately Active":
        activityMultiplier = 1.55;
        break;
      case "Highly Active":
        activityMultiplier = 1.725;
        break;
      default:
        activityMultiplier = 1.2;
    }

    return bmr * activityMultiplier;
  }

  // Calculate goal-adjusted calories
  double calculateGoalCalories() {
    double tdee = calculateTDEE();

    switch (goal) {
      case "Gain weight":
        return tdee + 350; // surplus for weight gain
      case "Lose weight":
        return tdee - 400; // deficit for weight loss
      case "Maintain your physique":
      default:
        return tdee;
    }
  }

Map<String, int> sendeverything() {
  return {
    'weight': weight,
    'height': height,
    'age': age,
  };
}

  // Calculate macronutrient distribution
  Map<String, double> calculateMacros() {
    double calories = calculateGoalCalories();

    double proteinGrams = weight * 1.9;
    double proteinCalories = proteinGrams * 4;

    // Fat: 25% of total calories
    double fatCalories = calories * 0.25;
    double fatGrams = fatCalories / 9;

    // Carbs: remaining calories
    double carbCalories = calories - proteinCalories - fatCalories;
    double carbGrams = carbCalories / 4;

    return {
      'protein': proteinGrams,
      'fat': fatGrams,
      'carbs': carbGrams,
      'calories': calories,
            'weight' :weight.toDouble(),
                        'height' :height.toDouble(),

            'age' :age.toDouble(),

    };
  }

  // Add to your UserData class
  Map<String, int> getNutritionGoals() {
    final macros =
        calculateMacros(); // Uses your existing calculateMacros() method
    return {
      'calories': macros['calories']?.round() ?? 2486,
      'protein': macros['protein']?.round() ?? 133,
      'fat': macros['fat']?.round() ?? 69,
      'carbs': macros['carbs']?.round() ?? 333,
    };
  }
}

class UserDataBuilder {
  String gender = "";
  int weight = 70;
  int height =180;
  String activityLevel = "";
  String goal = "";
  int age = 10;

  UserData build() {
    return UserData(
      gender: gender,
      weight: weight,
      height: height,
      activityLevel: activityLevel,
      goal: goal,
      age: age,
    );
  }
}
