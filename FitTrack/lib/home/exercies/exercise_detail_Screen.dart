import 'dart:async';
import 'package:fit_track/home/exercies/widgets/build_stat_card.dart';
import 'package:fit_track/home/exercies/widgets/time_editor.widget.dart';
import 'package:fit_track/home/exercies/widgets/weight_card_widget.dart';
import 'package:fit_track/home/exercies/widgets/workout_history_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExerciesDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> exercise;
  final String userId;
  final String title;
  final String image;
  final String muscle;
  final String instructions;
  final int timeInMinutes;

  const ExerciesDetailsScreen({
    super.key,
    required this.exercise,
    required this.title,
    required this.image,
    required this.muscle,
    required this.instructions,
    required this.timeInMinutes,
    required this.userId,
  });

  @override
  State<ExerciesDetailsScreen> createState() => _ExerciesDetailsScreenState();
}

class _ExerciesDetailsScreenState extends State<ExerciesDetailsScreen> {
  bool isBreak = false;
  bool isRunning = false;
  double weight = 0.15;
  double lastWeight = 0;
  bool weightGlow = false;

  Timer? holdTimer;
  int sets = 4;
  int breakSeconds = 30; // 1 minute break
  int totalSeconds = 60;
  int currentSeconds = 60;
  int workoutSeconds = 300;
  final supabase = Supabase.instance.client;
  Timer? timer;
  List<Map<String, dynamic>> historyList = [];

  void startTimer() {
    if (isRunning) return;

    setState(() => isRunning = true);

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }

      if (currentSeconds > 0) {
        setState(() => currentSeconds--);
      } else {
        t.cancel();

        if (!mounted) return;

        setState(() {
          isRunning = false;

          if (isBreak) {
            isBreak = false;
            totalSeconds = workoutSeconds;
            currentSeconds = workoutSeconds;
          } else {
            sets++;
          }
        });
      }
    });
  }

  void pauseTimer() {
    timer?.cancel();
    setState(() => isRunning = false);
  }

  void resetTimer() {
    timer?.cancel();

    setState(() {
      isRunning = false;

      if (isBreak) {
        totalSeconds = breakSeconds;
      } else {
        totalSeconds = workoutSeconds;
      }

      currentSeconds = totalSeconds;
    });
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remaining.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startBreak() {
    timer?.cancel();

    if (!mounted) return;

    setState(() {
      isBreak = true;
      isRunning = false;
      totalSeconds = breakSeconds;
      currentSeconds = breakSeconds;
    });

    startTimer();
  }

  void updateWeight(double value) {
    setState(() {
      lastWeight = weight;
      weight += value;
      if (weight < 0) weight = 0;
      weightGlow = true;
    });

    HapticFeedback.lightImpact();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => weightGlow = false);
      }
    });
  }

  void startHold(double value) {
    holdTimer?.cancel();
    holdTimer = Timer.periodic(const Duration(milliseconds: 150), (_) {
      updateWeight(value);
    });
  }

  void stopHold() {
    holdTimer?.cancel();
  }

  Future<void> loadWorkoutHistory() async {
  try {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return;

    String currentExercise =
        widget.exercise["name"] ?? widget.exercise["title"] ?? "";

    final response = await supabase
        .from("history") // 🔥 use single table
        .select()
        .eq("user_id", user.id)
        .eq("type", "workout") // 🔥 filter
        .eq("name", currentExercise)
        .order("date", ascending: false);

    if (!mounted) return;

    setState(() {
      historyList = List<Map<String, dynamic>>.from(response);

      /// 🔥 AUTO LOAD LAST WEIGHT
      if (historyList.isNotEmpty) {
        weight = (historyList.first["weight"] ?? 0).toDouble();
         sets = (historyList.first["sets"] ?? 1);
      }
    });
  } catch (e) {
    debugPrint("History load error: $e");
  }
}

  @override
  void initState() {
    super.initState();

    final workoutTime = widget.exercise["workoutTime"];
    if (workoutTime != null) {
      workoutSeconds = workoutTime;
    }

    final breakTimes = widget.exercise["breakTime"];
    if (breakTimes != null && breakTimes.isNotEmpty) {
      breakSeconds = int.tryParse(breakTimes[0].split(" ")[0]) ?? 60;
    }

    totalSeconds = workoutSeconds;
    currentSeconds = workoutSeconds;

    loadWorkoutHistory(); // 🔥 ADD THIS
  }

  Future<void> saveWorkout() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) return;

      String exerciseName =
          widget.exercise["name"] ?? widget.exercise["title"] ?? "";

      final workoutData = {
        "user_id": user.id,
        "type": "workout", // 🔥 MUST ADD
        "name": exerciseName,
        "sets": sets,
        "weight": weight,
        "workout_time": workoutSeconds ~/ 60,
        "break_rest": breakSeconds,
        "image": widget.exercise["image"] ?? "",
        "date": DateTime.now().toIso8601String(),
      };

      await supabase.from("history").insert(workoutData); // 🔥 TABLE CHANGE

      await loadWorkoutHistory();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Workout Saved 💪")));
    } catch (e) {
      debugPrint("Workout save error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds == 0 ? 0.0 : currentSeconds / totalSeconds;
    final primaryColor = isBreak ? Colors.blue : Colors.orange;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        toolbarHeight: 40, // 🔥 DEFAULT 56 → now smaller
        leading: const BackButton(color: Colors.white),
        title: Text(
          widget.exercise["name"] ?? widget.exercise["title"] ?? "",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  isBreak ? "Break Time" : "Workout Timer",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// Circular Timer
              Center(
                child: GestureDetector(
                  onTap: () {
                    if (isRunning) {
                      pauseTimer();
                    } else {
                      startTimer();
                    }
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 180,
                        width: 180,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 12,
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation(primaryColor),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isRunning ? Icons.pause : Icons.play_arrow,
                            size: 45,
                            color: primaryColor,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            formatTime(currentSeconds),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              /// Mode Label
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isBreak ? "BREAK MODE" : "WORKOUT MODE",
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              /// Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: resetTimer,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Reset"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: startBreak,
                    icon: const Icon(Icons.pause, color: Colors.white),
                    label: const Text(
                      "Break",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildTimeEditor(
                      title: "WORKOUT",
                      seconds: workoutSeconds,
                      color: Colors.orange,
                      isWorkout: true,
                      onAdd: () {
                        setState(() {
                          workoutSeconds += 60; // +1 minute
                          if (!isBreak) {
                            totalSeconds = workoutSeconds;
                            currentSeconds = workoutSeconds;
                          }
                        });
                      },
                      onMinus: () {
                        if (workoutSeconds > 60) {
                          setState(() {
                            workoutSeconds -= 60;
                            if (!isBreak) {
                              totalSeconds = workoutSeconds;
                              currentSeconds = workoutSeconds;
                            }
                          });
                        }
                      },
                    ),

                    buildTimeEditor(
                      title: "BREAK",
                      seconds: breakSeconds,
                      color: Colors.blue,
                      isWorkout: false,
                      onAdd: () {
                        setState(() {
                          breakSeconds += 5; // +5 sec
                        });
                      },
                      onMinus: () {
                        if (breakSeconds > 5) {
                          setState(() {
                            breakSeconds -= 5;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              /// FIRST ROW (Set + Reps)
              Row(
                children: [
                  Expanded(
                    child: buildStatCard(
                      title: "Set",
                      value: "$sets",
                      valueColor: Colors.orange,
                      onAdd: () {
                        setState(() => sets++);
                      },
                      onMinus: () {
                        if (sets > 1) {
                          setState(() => sets--);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: WeightCard(
                      weight: weight,
                      onAdd: () {
                        setState(() {
                          weight = double.parse(
                            (weight + 0.15).toStringAsFixed(2),
                          );
                        });
                      },
                      onRemove: () {
                        if (weight > 0.15) {
                          setState(() {
                            weight = double.parse(
                              (weight - 0.15).toStringAsFixed(2),
                            );
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () async {
                    await saveWorkout();

                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   const SnackBar(content: Text("Workout Saved 💪")),
                    // );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFB7F43B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// 🔥 WORKOUT HISTORY TITLE
              /// 🔥 WORKOUT HISTORY TITLE
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Workout History",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 5),

              Expanded(
                child: historyList.isEmpty
                    ? const Center(
                        child: Text(
                          "No workout history yet 💪",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: historyList.length,
                        itemBuilder: (context, index) {
                          final item = historyList[index];

                          /// current exercise name
                          String name =
                              (widget.exercise["name"] ??
                                      widget.exercise["title"] ??
                                      "")
                                  .toString();

                          /// show only this exercise history
                          if (item["name"] != name) {
                            return const SizedBox();
                          }

                          return WorkoutHistoryItem(
                            item: item,
                            exerciseName: name,
                          );
                        },
                      ),
              ),
              const SizedBox(height: 0),
            ],
          ),
        ),
      ),
    );
  }
}
