import 'package:fit_track/workout/widget/build_weight_card.dart';
import 'package:fit_track/workout/widget/exercise_card_widget.dart';
import 'package:fit_track/workout/widget/history_bottom_sheet.dart';
import 'package:flutter/material.dart';

class WorkoutRecordWidget extends StatefulWidget {
  final String title;
  final bool isBreak;
  final bool isRunning;
  final double progress;
  final int currentSeconds;
  final int totalSets;
  final int reps;
  final Color primaryColor;
  final int workoutMinutes;
  final int breakSeconds;

  final VoidCallback onAddWorkoutTime;
  final VoidCallback onRemoveWorkoutTime;
  final VoidCallback onAddBreakTime;
  final VoidCallback onRemoveBreakTime;

  final double weight;
  final VoidCallback onAddWeight;
  final VoidCallback onRemoveWeight;

  final VoidCallback onStartPause;
  final VoidCallback onReset;
  final VoidCallback onBreak;
  final VoidCallback onAddRep;
  final VoidCallback onRemoveRep;
  final VoidCallback onSave;
  final VoidCallback onclose;

  final String Function(int) formatTime;

  const WorkoutRecordWidget({
    super.key,
    required this.isBreak,
    required this.isRunning,
    required this.progress,
    required this.currentSeconds,
    required this.totalSets,
    required this.reps,
    required this.primaryColor,
    required this.onStartPause,
    required this.onReset,
    required this.onBreak,
    required this.onAddRep,
    required this.onRemoveRep,
    required this.onSave,
    required this.formatTime,
    required this.weight,
    required this.onAddWeight,
    required this.onRemoveWeight,
    required this.title,
    required this.workoutMinutes,
    required this.breakSeconds,
    required this.onAddWorkoutTime,
    required this.onRemoveWorkoutTime,
    required this.onAddBreakTime,
    required this.onRemoveBreakTime,
    required this.onclose,
  });

  @override
  State<WorkoutRecordWidget> createState() => _WorkoutRecordWidgetState();
}

Map<String, List<Map<String, dynamic>>> historyMap = {};
List<Map<String, dynamic>> todayWorkouts = [];

Set<int> selectedIndexes = {};
bool isSelectionMode = false;

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

class _WorkoutRecordWidgetState extends State<WorkoutRecordWidget> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      padding: EdgeInsets.all(size.width * 0.05),
      child: Column(
        children: [
          /// 🔥 TOP RIGHT ICON + CENTER TEXT
          Stack(
            children: [
              Center(
                child: Text(
                  widget.isBreak ? "Break Time" : "Workout Timer",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size.width * 0.045,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    showHistoryBottomSheet(
                      context: context,
                      title: widget.title,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.list_alt,
                      color: Colors.black,
                      size: size.width * 0.05,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: size.height * 0.02),

          /// 🔥 TIMER
          GestureDetector(
            onTap: widget.onStartPause,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: size.width * 0.45,
                  width: size.width * 0.45,
                  child: CircularProgressIndicator(
                    value: widget.progress,
                    strokeWidth: size.width * 0.03,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation(widget.primaryColor),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isRunning ? Icons.pause : Icons.play_arrow,
                      size: size.width * 0.11,
                      color: widget.primaryColor,
                    ),
                    SizedBox(height: size.height * 0.01),
                    Text(
                      widget.formatTime(widget.currentSeconds),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size.width * 0.065,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: size.height * 0.02),

          /// MODE LABEL
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.05,
              vertical: size.height * 0.008,
            ),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: widget.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.isBreak ? "BREAK MODE" : "WORKOUT MODE",
              style: TextStyle(
                color: widget.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: size.width * 0.035,
              ),
            ),
          ),

          SizedBox(height: size.height * 0.01),

          /// BUTTONS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: widget.onReset,
                icon: Icon(Icons.refresh, size: size.width * 0.05),
                label: Text(
                  "Reset",
                  style: TextStyle(fontSize: size.width * 0.04),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),

              SizedBox(width: size.width * 0.05),

              /// STATS
              ElevatedButton.icon(
                onPressed: widget.onBreak,
                icon: Icon(Icons.pause, size: size.width * 0.05),
                label: Text(
                  "Break",
                  style: TextStyle(fontSize: size.width * 0.04),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.01),

          Row(
            children: [
              Expanded(
                child: buildTimeCard(
                  context,
                  "Workout",
                  "${widget.workoutMinutes} min",
                  Colors.orange,
                  widget.onAddWorkoutTime,
                  widget.onRemoveWorkoutTime,
                ),
              ),
              SizedBox(width: size.width * 0.02),
              Expanded(
                child: buildTimeCard(
                  context,
                  "Break",
                  "${widget.breakSeconds}s",
                  Colors.blue,
                  widget.onAddBreakTime,
                  widget.onRemoveBreakTime,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.01),

          Row(
            children: [
              Expanded(
                child: buildStatCard(
                  context,
                  "Sets",
                  widget.totalSets.toString(),
                  Colors.orange,
                  widget.onAddRep, // ✅ USE THIS
                  widget.onRemoveRep, // ✅ USE THIS
                ),
              ),

              SizedBox(width: size.width * 0.02),

              Expanded(
                child: buildWeightCard(
                  context,
                  weight: widget.weight,
                  onAddWeight: widget.onAddWeight,
                  onRemoveWeight: widget.onRemoveWeight,
                ), // ✅ fixed
              ),
            ],
          ),

          SizedBox(height: size.height * 0.02),

          /// 🔥 SAVE BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 236, 41, 41),
                padding: EdgeInsets.all(size.height * 0.02),
              ),
              onPressed: () {
                setState(() {
                  historyMap[widget.title] ??= [];

                  historyMap[widget.title]!.insert(0, {
                    "name": widget.title,
                    "sets": widget.totalSets,
                    "weight": "${widget.weight.toStringAsFixed(2)} kg",
                    "time": widget.formatTime(widget.currentSeconds),
                    "break": widget.isBreak
                        ? formatBreakTime(widget.breakSeconds)
                        : "No Break",
                    "date": DateTime.now(),
                  });
                });

                /// 🔥 ADD THIS
                widget.onSave();
              },
              child: Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ),
          SizedBox(height: size.height * 0.02),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD0FD3E),
                padding: EdgeInsets.all(size.height * 0.02),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                widget.onclose(); // ✅ only this
              },
              child: Text(
                "close",
                style: TextStyle(
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          /// SAVE BUTTON
          SizedBox(height: size.height * 0.08),
        ],
      ),
    );
  }
}
