import 'dart:io';
import 'package:fit_track/home/nutrition/add_meal_screen.dart';
import 'package:fit_track/home/nutrition/meal_detail_screen.dart';
import 'package:fit_track/provider/nutrition_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Nutritionscreen extends StatefulWidget {
  final VoidCallback onAddPressed;
  final DateTime selectedDate;

  const Nutritionscreen({
    super.key,
    required this.onAddPressed,
    required this.selectedDate,
    required Map<String, List<Map<String, dynamic>>> nutritionData,
  });

  @override
  State<Nutritionscreen> createState() => _NutritionscreenState();
}

class _NutritionscreenState extends State<Nutritionscreen> {
  /// TOTAL CALCULATION
  int _calculateTotal(List<Map<String, dynamic>> meals, String keyName) {
    int total = 0;

    for (var item in meals) {
      total += int.tryParse(item[keyName]?.toString() ?? "0") ?? 0;
    }

    return total;
  }

  /// HEADER TITLE
  String getNutritionTitle(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(date.year, date.month, date.day);

    if (selected == today) return "Today's Nutrition";
    if (selected == today.add(const Duration(days: 1)))
      return "Tomorrow's Nutrition";
    if (selected == today.subtract(const Duration(days: 1)))
      return "Yesterday's Nutrition";

    return "${DateFormat("d MMM").format(date)} Nutrition";
  }

  bool isToday(DateTime date) {
    final now = DateTime.now();

    return now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final provider = Provider.of<NutritionProvider>(context, listen: false);

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: provider.getMealsByDate(widget.selectedDate),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
         return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFD0FD3E),
        ),
      );
        }

        final meals = snapshot.data!;

        final totalCalories = _calculateTotal(meals, "calories");
        final totalProtein = _calculateTotal(meals, "protein");
        final totalCarbs = _calculateTotal(meals, "carbs");

        return Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              /// TITLE
              Text(
                getNutritionTitle(widget.selectedDate),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: size.height * 0.02),

              /// MACRO CARDS
              SizedBox(
                height: 130,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _MacroCard(
                      icon: Icons.local_fire_department,
                      label: "Calories",
                      value: "$totalCalories kcal",
                      color: Colors.orange,
                    ),

                    SizedBox(width: size.width * 0.03),

                    _MacroCard(
                      icon: Icons.fitness_center,
                      label: "Protein",
                      value: "$totalProtein g",
                      color: Colors.blue,
                    ),

                    SizedBox(width: size.width * 0.03),

                    _MacroCard(
                      icon: Icons.grain,
                      label: "Carbs",
                      value: "$totalCarbs g",
                      color: Colors.green,
                    ),
                  ],
                ),
              ),

              SizedBox(height: size.height * 0.02),

              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Planned Meals",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  /// ADD BUTTON ONLY TODAY
                  if (isToday(widget.selectedDate))
                    CircleAvatar(
                      backgroundColor: Colors.lime,
                      child: IconButton(
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.black,
                        ),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) =>
                                  const AddMealScreen(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );

                          if (result != null) {
                            await Provider.of<NutritionProvider>(
                              context,
                              listen: false,
                            ).addMeal(result, widget.selectedDate);

                            setState(() {});
                          }
                        },
                      ),
                    ),
                ],
              ),

              SizedBox(height: size.height * 0.02),

              meals.isEmpty
                  ? const Center(
                      child: Text(
                        "No meals added yet",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : _buildMealList(meals, size),
            ],
          ),
        );
      },
    );
  }

  /// MEAL LIST
  Widget _buildMealList(List meals, Size size) {
    return Column(
      children: List.generate(meals.length, (index) {
        final meal = meals[meals.length - 1 - index];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => MealDetailScreen(meal: meal),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },

          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(14),
            ),

            child: Row(
              children: [
                /// ✅ IMAGE FIXED VERSION
                Builder(
                  builder: (context) {
                    final path = meal["image"]?.toString() ?? "";
                    final file = File(path);

                    if (path.isNotEmpty && file.existsSync()) {
                      return SizedBox(
                        height: size.height * 0.06,
                        width: size.width * 0.16,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            file,
                            fit: BoxFit.cover,
                            cacheWidth: 200,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade800,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.red,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    } else {
                      return Container(
                        height: size.height * 0.06,
                        width: size.width * 0.16,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.fastfood, color: Colors.grey),
                      );
                    }
                  },
                ),

                SizedBox(width: size.width * 0.04),

                /// TEXT PART (same as yours)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal["name"] ?? "",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: size.height * 0.005),

                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            "🔥 ${meal["calories"] ?? 0} kcal",
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            "💪 ${meal["protein"] ?? 0} g",
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            "🍚 ${meal["carbs"] ?? 0} g",
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: size.height * 0.005),

                      Text(
                        meal["description"] ?? "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

/// MACRO CARD
class _MacroCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MacroCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          // ignore: deprecated_member_use
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
        ),
        // ignore: deprecated_member_use
        border: Border.all(color: color.withOpacity(0.4)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(icon, color: color),

          const SizedBox(height: 10),

          Text(label, style: const TextStyle(color: Colors.white70)),

          const SizedBox(height: 6),

          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
