import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  int totalWorkouts = 0;
  int totalMinutes = 0;
  int totalCalories = 0;

  /// Nutrition totals
  int totalNutritionCalories = 0;
  int totalProtein = 0;
  int totalCarbs = 0;

  /// Today / Month / Year
  int todayCalories = 0;
  int monthCalories = 0;
  int yearCalories = 0;

  Map<String, int> weeklyData = {
    "Mon": 0,
    "Tue": 0,
    "Wed": 0,
    "Thu": 0,
    "Fri": 0,
    "Sat": 0,
    "Sun": 0,
  };

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();

    /// WORKOUT LOGS
    List<String> logs = prefs.getStringList("workout_logs") ?? [];

    int workouts = logs.length;
    int minutes = 0;

    Map<String, int> week = {
      "Mon": 0,
      "Tue": 0,
      "Wed": 0,
      "Thu": 0,
      "Fri": 0,
      "Sat": 0,
      "Sun": 0,
    };

    for (var log in logs) {
      final data = jsonDecode(log);

      int time = data["workoutTime"] ?? 0;
      minutes += time;

      DateTime date = DateTime.parse(data["date"]);

      String day = [
        "Mon",
        "Tue",
        "Wed",
        "Thu",
        "Fri",
        "Sat",
        "Sun",
      ][date.weekday - 1];

      week[day] = (week[day] ?? 0) + time;
    }

    /// NUTRITION LOGS
    List<String> nutritionLogs = prefs.getStringList("nutrition_logs") ?? [];

    int calories = 0;
    int protein = 0;
    int carbs = 0;

    int today = 0;
    int month = 0;
    int year = 0;

    DateTime now = DateTime.now();

    for (var log in nutritionLogs) {
      final data = jsonDecode(log);

      int cal = int.tryParse(data["calories"].toString()) ?? 0;
      int pro = int.tryParse(data["protein"].toString()) ?? 0;
      int car = int.tryParse(data["carbs"].toString()) ?? 0;

      calories += cal;
      protein += pro;
      carbs += car;

      DateTime date = DateTime.parse(data["date"]);

      /// TODAY
      if (date.day == now.day &&
          date.month == now.month &&
          date.year == now.year) {
        today += cal;
      }

      /// MONTH
      if (date.month == now.month && date.year == now.year) {
        month += cal;
      }

      /// YEAR
      if (date.year == now.year) {
        year += cal;
      }
    }

    setState(() {
      totalWorkouts = workouts;
      totalMinutes = minutes;
      totalCalories = minutes * 8;
      weeklyData = week;

      totalNutritionCalories = calories;
      totalProtein = protein;
      totalCarbs = carbs;

      todayCalories = today;
      monthCalories = month;
      yearCalories = year;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    int hours = totalMinutes ~/ 60;
    int mins = totalMinutes % 60;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Text(
          "Progress Dashboard",
          style: TextStyle(
            fontSize: size.width * 0.05,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.05),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              /// WORKOUT PROGRESS
              Text(
                "Workout Progress",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: size.height * 0.02),

              progressCard(
                size,
                "Calories Burned",
                "$totalCalories kcal",
                Icons.local_fire_department,
              ),

              SizedBox(height: size.height * 0.02),

              progressCard(
                size,
                "Workouts Completed",
                "$totalWorkouts",
                Icons.fitness_center,
              ),

              SizedBox(height: size.height * 0.02),

              progressCard(
                size,
                "Total Workout Time",
                "${hours}h ${mins}m",
                Icons.timer,
              ),

              SizedBox(height: size.height * 0.04),

              /// WEEKLY GRAPH
              Text(
                "Weekly Progress",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: size.height * 0.02),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: weeklyData.entries.map((e) {
                  double value = e.value / 60;
                  if (value > 1) value = 1;

                  return ProgressBar(e.key, value, size);
                }).toList(),
              ),

              SizedBox(height: size.height * 0.05),

              /// NUTRITION PROGRESS
              Text(
                "Nutrition Progress",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: size.height * 0.02),

              progressCard(
                size,
                "Calories Consumed",
                "$totalNutritionCalories kcal",
                Icons.restaurant,
              ),

              SizedBox(height: size.height * 0.02),

              progressCard(
                size,
                "Protein Intake",
                "$totalProtein g",
                Icons.fitness_center,
              ),

              SizedBox(height: size.height * 0.02),

              progressCard(size, "Carbs Intake", "$totalCarbs g", Icons.grain),

              SizedBox(height: size.height * 0.04),

              /// EXTRA STATS
              progressCard(
                size,
                "Today Calories",
                "$todayCalories kcal",
                Icons.today,
              ),

              SizedBox(height: size.height * 0.02),

              progressCard(
                size,
                "This Month Calories",
                "$monthCalories kcal",
                Icons.calendar_month,
              ),

              SizedBox(height: size.height * 0.02),

              progressCard(
                size,
                "This Year Calories",
                "$yearCalories kcal",
                Icons.calendar_today,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget progressCard(Size size, String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.045),

      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(14),
      ),

      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFD0FD3E), size: size.width * 0.07),

          SizedBox(width: size.width * 0.04),

          Text(
            title,
            style: TextStyle(
              color: Colors.white70,
              fontSize: size.width * 0.04,
            ),
          ),

          const Spacer(),

          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: size.width * 0.045,
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  final String day;
  final double value;
  final Size size;

  const ProgressBar(this.day, this.value, this.size, {super.key});

  @override
  Widget build(BuildContext context) {
    double barHeight = size.height * 0.15;

    return Column(
      children: [
        Container(
          width: size.width * 0.04,
          height: barHeight,
          alignment: Alignment.bottomCenter,

          child: Container(
            height: barHeight * value,

            decoration: BoxDecoration(
              color: const Color(0xFFD0FD3E),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),

        SizedBox(height: size.height * 0.005),

        Text(
          day,
          style: TextStyle(color: Colors.white70, fontSize: size.width * 0.03),
        ),
      ],
    );
  }
}
