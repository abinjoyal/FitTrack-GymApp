import 'dart:io';
import 'package:flutter/material.dart';

class MealDetailScreen extends StatelessWidget {
  final Map<String, dynamic> meal;

  const MealDetailScreen({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    final String imagePath = meal["image"]?.toString() ?? "";
    final String mealName = meal["name"]?.toString() ?? "Meal";
    final String mealType = meal["mealType"]?.toString() ?? "";
    final String description =
        meal["description"]?.toString() ?? "No description available.";

    final int calories = int.tryParse(meal["calories"]?.toString() ?? "0") ?? 0;
    final int protein = int.tryParse(meal["protein"]?.toString() ?? "0") ?? 0;
    final int carbs = int.tryParse(meal["carbs"]?.toString() ?? "0") ?? 0;

    final Size size = MediaQuery.of(context).size;

    IconData getMealIcon(String type) {
      switch (type) {
        case "Breakfast":
          return Icons.free_breakfast;
        case "Lunch":
          return Icons.lunch_dining;
        case "Dinner":
          return Icons.dinner_dining;
        case "Evening Snack":
          return Icons.nightlight_round;
        case "Dessert":
          return Icons.icecream;
        case "Juice / Drinks":
          return Icons.local_drink;
        default:
          return Icons.restaurant;
      }
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1C2E05), Color(0xFF0F1A02), Colors.black],
        ),
      ),

      child: Scaffold(
        backgroundColor: Colors.transparent,

        body: SafeArea(
          child: Column(
            children: [
              /// IMAGE SECTION
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(20),
                      top: Radius.circular(20),
                    ),

                    child: imagePath.isNotEmpty && File(imagePath).existsSync()
                        ? Image.file(
                            File(imagePath),
                            height: size.height * 0.35,
                            width: size.width * 0.95,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            height: size.height * 0.35,
                            width: size.width * 0.95,
                            color: Colors.grey.shade900,
                            child: const Icon(
                              Icons.fastfood,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                  ),

                  /// BACK BUTTON
                  Positioned(
                    top: 15,
                    left: 15,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// BODY
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      /// MEAL NAME
                      Text(
                        mealName,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 8),

                      /// MEAL TYPE
                      if (mealType.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              getMealIcon(mealType),
                              color: Colors.white,
                              size: 18,
                            ),

                            const SizedBox(width: 6),

                            Text(
                              mealType,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 20),

                      /// MACRO ROW
                      Row(
                        children: [
                          Expanded(
                            child: _MacroBox(
                              icon: Icons.local_fire_department,
                              label: "Calories",
                              value: "$calories kcal",
                              color: Colors.orange,
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: _MacroBox(
                              icon: Icons.fitness_center,
                              label: "Protein",
                              value: "$protein g",
                              color: Colors.blue,
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: _MacroBox(
                              icon: Icons.grain,
                              label: "Carbs",
                              value: "$carbs g",
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// DESCRIPTION TITLE
                      const Text(
                        "Description",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// DESCRIPTION TEXT
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            description,
                            style: const TextStyle(
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// DONE BUTTON
                      SizedBox(
                        width: double.infinity,

                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD0FD3E),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),

                          onPressed: () => Navigator.pop(context),

                          child: const Text(
                            "Done",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
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

class _MacroBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MacroBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),

        gradient: LinearGradient(
          // ignore: deprecated_member_use
          colors: [color.withOpacity(0.25), color.withOpacity(0.08)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        // ignore: deprecated_member_use
        border: Border.all(color: color.withOpacity(0.4)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(icon, color: color, size: 22),

          const SizedBox(height: 8),

          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),

          const SizedBox(height: 6),

          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
