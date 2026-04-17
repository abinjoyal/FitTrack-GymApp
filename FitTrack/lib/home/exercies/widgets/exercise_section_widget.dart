import 'package:fit_track/home/exercies/exercise_history_screen.dart';
import 'package:fit_track/provider/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ExerciseSectionWidget extends StatefulWidget {
  final String? selectedWorkoutName;
  final Map<String, List<Map<String, dynamic>>> workoutExercises;
  final Future<void> Function() onAddExercise;
  final DateTime selectedDate;
  final String instructions;

  const ExerciseSectionWidget({
    super.key,
    required this.selectedWorkoutName,
    required this.workoutExercises,
    required this.onAddExercise,
    required this.selectedDate,
    required this.instructions,
  });

  @override
  State<ExerciseSectionWidget> createState() => _ExerciseSectionWidgetState();
}

class _ExerciseSectionWidgetState extends State<ExerciseSectionWidget> {
  String getWorkoutTitle(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(date.year, date.month, date.day);

    if (selected == today) return "Today's Workout";
    if (selected == today.subtract(const Duration(days: 1))) {
      return "Yesterday's Workout";
    }
    if (selected == today.add(const Duration(days: 1))) {
      return "Tomorrow's Plan";
    }

    return "${DateFormat("d MMM").format(date)} Workout";
  }

  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool isFuture(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(date.year, date.month, date.day);
    return selected.isAfter(today);
  }

  /// 🔥 normalize key (IMPORTANT FIX)
  String normalize(String text) {
    return text.trim().toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final provider = context.watch<HomeProvider>();

    if (widget.selectedWorkoutName == null) {
      return const Center(
        child: Text(
          "Select a workout category",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final exercises = widget.workoutExercises[widget.selectedWorkoutName] ?? [];

    final today = isToday(widget.selectedDate);
    final future = isFuture(widget.selectedDate);

    if (future) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(
          child: Text(
            "Stay ready for tomorrow 💪",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                getWorkoutTitle(widget.selectedDate),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (today)
                GestureDetector(
                  onTap: widget.onAddExercise,
                  child: Container(
                    height: size.width * 0.12,
                    width: size.width * 0.12,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD0FD3E),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.black,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),

          if (exercises.isEmpty)
            const Center(
              child: Text(
                "No exercises added",
                style: TextStyle(color: Colors.grey),
              ),
            ),

          /// 🔥 EXERCISE LIST
          if (exercises.isNotEmpty)
            ...List.generate(exercises.length, (i) {
              final reversedIndex = exercises.length - 1 - i;
              final exercise = exercises[reversedIndex];

              final name = (exercise["name"] ?? "").toString().trim();

              /// 🔥 FIX: normalize key
              final normalizedName = normalize(name);

              final historyList = provider.historyMap[normalizedName] ?? [];

              final latestHistory = historyList.isNotEmpty
                  ? historyList.first
                  : null;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) =>
                          ExerciseHistoryScreen(exerciseName: normalizedName),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      /// ICON
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : "?",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      /// 🔥 TEXT SECTION (FIXED)
                      Expanded(
                        // 👈 MUST ADD THIS
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              (exercise["instructions"] ??
                                      exercise["description"] ??
                                      "")
                                  .toString(),
                              maxLines: 2,
                              overflow:
                                  TextOverflow.ellipsis, // 👈 FIX overflow
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
