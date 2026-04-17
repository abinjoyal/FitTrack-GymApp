import 'package:fit_track/workout/widget/exercise_text_widgets.dart';
import 'package:fit_track/workout/widget/workout_record_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class WorkoutDetailsScreen extends StatefulWidget {
  final String title;
  final String muscle;
  final String instructions;
  final int timeInMinutes;
  final String videoUrl;

  const WorkoutDetailsScreen({
    super.key,
    required this.title,
    required this.muscle,
    required this.instructions,
    required this.timeInMinutes,
    required this.videoUrl,
  });

  @override
  State<WorkoutDetailsScreen> createState() => _WorkoutDetailsScreenState();
}

class _WorkoutDetailsScreenState extends State<WorkoutDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  YoutubePlayerController? _youtubeController;

  late int totalSeconds;
  late int currentSeconds;
  int breakSeconds = 60;
  int workoutMinutes = 0;
  bool isRunning = false;
  bool isBreak = false;
  int totalSets = 1;
  int reps = 1;
  bool showControls = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    workoutMinutes = widget.timeInMinutes;

    totalSeconds = workoutMinutes * 60;
    currentSeconds = totalSeconds;

    initYoutube();
  }

  void initYoutube() {
    if (widget.videoUrl.isEmpty) {
      debugPrint("❌ No video URL");
      return;
    }

    /// 🔥 youtu.be support
    String cleanUrl(String url) {
      if (url.contains("youtu.be")) {
        final id = url.split("/").last.split("?").first;
        return "https://www.youtube.com/watch?v=$id";
      }
      return url;
    }

    final safeUrl = cleanUrl(widget.videoUrl);

    final videoId = YoutubePlayer.convertUrlToId(safeUrl);

    if (videoId == null) {
      debugPrint("❌ Invalid URL: $safeUrl");
      return;
    }
    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: false,
        forceHD: false,
        hideControls: false,
        disableDragSeek: false,
        controlsVisibleAtStart: false,
        hideThumbnail: false,
      ),
    );
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void startTimer() {
    if (isRunning) return;

    setState(() => isRunning = true);

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted || !isRunning) return false;

      if (currentSeconds > 0) {
        setState(() => currentSeconds--);
        return true;
      } else {
        setState(() {
          isRunning = false;

          if (isBreak) {
            isBreak = false;
            totalSeconds = workoutMinutes * 60;
            currentSeconds = totalSeconds;
          }
        });

        return false;
      }
    });
  }

  String formatBreakTime(int seconds) {
    if (seconds >= 60) {
      int min = seconds ~/ 60;
      int sec = seconds % 60;

      if (sec == 0) {
        return "$min min";
      } else {
        return "$min min $sec sec";
      }
    } else {
      return "$seconds sec";
    }
  }

  /// 🔥 WORKOUT TIME CONTROL
  void increaseWorkoutTime() {
    setState(() {
      workoutMinutes++;
      totalSeconds = workoutMinutes * 60;
      currentSeconds = totalSeconds;
    });
  }

  void decreaseWorkoutTime() {
    if (workoutMinutes > 1) {
      setState(() {
        workoutMinutes--;
        totalSeconds = workoutMinutes * 60;
        currentSeconds = totalSeconds;
      });
    }
  }

  /// 🔥 BREAK TIME CONTROL
  void increaseBreakTime() {
    setState(() {
      breakSeconds += 10;
    });
  }

  void decreaseBreakTime() {
    if (breakSeconds > 10) {
      setState(() {
        breakSeconds -= 10;
      });
    }
  }

  Widget buildVideo() {
    if (_youtubeController != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: YoutubePlayer(
            controller: _youtubeController!,
            showVideoProgressIndicator: true,
          ),
        ),
      );
    }

    /// 🔥 fallback UI
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: const Text(
        "No Video Available",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  void pauseTimer() {
    setState(() => isRunning = false);
  }

  void resetTimer() {
    setState(() {
      currentSeconds = totalSeconds;
      isRunning = false;
    });
  }

  void startBreak() {
    setState(() {
      isBreak = true;
      totalSeconds = breakSeconds;
      currentSeconds = breakSeconds;
      isRunning = false;
    });

    startTimer();
  }

  String formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;

    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  String formatMuscle(String text) {
    return text
        .toLowerCase()
        .split(' ')
        .map(
          (word) =>
              word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '',
        )
        .join(' ');
  }

  Future<void> saveWorkoutToSupabase() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        debugPrint("❌ User not logged in");
        return;
      }

      await supabase.from('history').insert({
        "user_id": user.id,
        "type": "workout",

        /// ✅ MATCH TABLE
        "exercise_name": widget.title,
        "category": widget.muscle,

        "sets": totalSets,
        "weight": weight,

        /// ✅ MUST BE INT
        "workout_time": currentSeconds,

        /// ⚠️ TABLE uses break_rest (int)
        "break_rest": isBreak ? breakSeconds : 0,

        /// optional fields
        "calories": 0,
        "protein": 0,
        "carbs": 0,

        /// DATE + TIME
        "date": DateTime.now().toIso8601String(),

        "created_at": DateTime.now().toIso8601String(),
      });

      debugPrint("✅ Saved to history table");
    } catch (e) {
      debugPrint("❌ Supabase error: $e");
    }
  }

  Future<void> saveWorkout({
    required String name,
    required int sets,
    required int reps,
    required int time,
  }) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      await supabase.from("exercise_categories").upsert({
        "user_id": user.id,
        "title": name,
        "icon": "💪",
        "date": today,
        "created_at": DateTime.now().toIso8601String(),
      });

      await supabase.from("exercises").insert({
        "user_id": user.id,
        "name": name,
        "category": name,
        "description": widget.instructions,
        "sets": sets,
        "reps": reps,
        "weight": weight,
        "duration": time * 60,
        "workout_date": today,
        "created_at": DateTime.now().toIso8601String(),
      });

      // await supabase.from("history").insert({
      //   "user_id": user.id,
      //   "name": name,
      //   "type": "workout",
      //   "sets": sets,
      //   "reps": reps,
      //   "weight": weight,
      //   "date": today,
      //   "created_at": DateTime.now().toIso8601String(),
      // });
    } catch (e) {
      debugPrint("Save Error: $e");
    }
  }

  double weight = 0;

  void addWeight() {
    setState(() {
      weight = double.parse((weight + 2.50).toStringAsFixed(2));
    });
  }

  void removeWeight() {
    setState(() {
      if (weight > 2.50) {
        weight = double.parse((weight - 2.50).toStringAsFixed(2));
      }
    });
  }

  void addSet() {
    setState(() {
      totalSets++;
    });
  }

  void removeSet() {
    setState(() {
      if (totalSets > 1) {
        totalSets--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    final progress = totalSeconds == 0 ? 0.0 : currentSeconds / totalSeconds;

    final primaryColor = isBreak ? Colors.blue : Colors.orange;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.fromARGB(255, 46, 74, 8), Colors.black],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05,
                  vertical: size.height * 0.02,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(height: size.height * 0.01),

                    Text(
                      widget.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size.width * 0.06,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (!mounted) return;

                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },

                      child: Container(
                        padding: EdgeInsets.all(size.width * 0.02),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1C1E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white70,
                          size: size.width * 0.05,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFFD0FD3E),
                labelColor: Colors.white,
                tabs: const [
                  Tab(text: "Instructions"),
                  Tab(text: "Record"),
                ],
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Column(
                      children: [
                        if (_youtubeController != null)
                          Padding(
                            padding: EdgeInsets.all(size.width * 0.05),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                children: [
                                  /// YOUTUBE PLAYER
                                  YoutubePlayer(
                                    controller: _youtubeController!,
                                    showVideoProgressIndicator: false,
                                    bottomActions: const [
                                      CurrentPosition(),
                                      ProgressBar(isExpanded: true),
                                      RemainingDuration(),
                                    ],
                                  ),

                                  /// DOUBLE TAP OVERLAY
                                  Positioned.fill(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            behavior:
                                                HitTestBehavior.translucent,
                                            onDoubleTap: () {
                                              final pos = _youtubeController!
                                                  .value
                                                  .position;
                                              _youtubeController!.seekTo(
                                                Duration(
                                                  seconds: pos.inSeconds - 10,
                                                ),
                                              );
                                            },
                                            child: Container(),
                                          ),
                                        ),

                                        Expanded(
                                          child: GestureDetector(
                                            behavior:
                                                HitTestBehavior.translucent,
                                            onDoubleTap: () {
                                              final pos = _youtubeController!
                                                  .value
                                                  .position;
                                              _youtubeController!.seekTo(
                                                Duration(
                                                  seconds: pos.inSeconds + 10,
                                                ),
                                              );
                                            },
                                            child: Container(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.05,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Text(
                                //   widget.title,
                                //   style: TextStyle(
                                //     color: Colors.white,
                                //     fontSize: size.width * 0.065,
                                //     fontWeight: FontWeight.bold,
                                //   ),
                                // ),
                                SizedBox(height: size.height * 0.01),

                                buildSectionTitle(context, "Focus Area"),
                                buildParagraph(
                                  context,
                                  formatMuscle(widget.muscle),
                                ),

                                SizedBox(height: size.height * 0.00),

                                buildSectionTitle(context, "Execution"),
                                buildParagraph(context, widget.instructions),

                                SizedBox(height: size.height * 0.02),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    WorkoutRecordWidget(
                      isBreak: isBreak,
                      isRunning: isRunning,
                      progress: progress,
                      currentSeconds: currentSeconds,
                      totalSets: totalSets,
                      reps: reps,
                      primaryColor: primaryColor,
                      formatTime: formatTime,
                      onStartPause: () {
                        isRunning ? pauseTimer() : startTimer();
                      },
                      onReset: resetTimer,
                      onBreak: startBreak,
                      onAddRep: addSet,
                      onRemoveRep: removeSet,
                      // workoutMinutes: workoutMinutes,
                      // breakSeconds: breakSeconds,
                      onAddWorkoutTime: increaseWorkoutTime,
                      onRemoveWorkoutTime: decreaseWorkoutTime,
                      onAddBreakTime: increaseBreakTime,
                      onRemoveBreakTime: decreaseBreakTime,
                      workoutMinutes: workoutMinutes,
                      breakSeconds: breakSeconds,
                      onclose: () async {
                        await saveWorkout(
                          name: widget.title,
                          sets: totalSets,
                          reps: reps,
                          time: widget.timeInMinutes,
                        );

                        if (!mounted) return;

                        if (Navigator.canPop(context)) {
                          Navigator.pop(context, {
                            "name": widget.title,
                            "sets": totalSets,
                            "reps": reps,
                            "weight": weight,
                            "time": formatTime(currentSeconds),
                            "break": isBreak
                                ? formatBreakTime(breakSeconds)
                                : "No Break",
                            "date": DateTime.now(),
                          });
                        }
                      },
                      weight: weight,
                      onAddWeight: addWeight,
                      onRemoveWeight: removeWeight,
                      title: widget.title,
                      onSave: () async {
                        await saveWorkoutToSupabase();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Workout saved successfully 💪")),
                        );
                      },
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
