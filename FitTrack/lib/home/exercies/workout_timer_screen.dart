import 'dart:async';
import 'package:flutter/material.dart';

class WorkoutTimerScreen extends StatefulWidget {
  final String workoutName;

  const WorkoutTimerScreen({super.key, required this.workoutName});

  @override
  State<WorkoutTimerScreen> createState() => _WorkoutTimerScreenState();
}

class _WorkoutTimerScreenState extends State<WorkoutTimerScreen> {
  int seconds = 0;
  Timer? timer;

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        seconds++;
      });
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.workoutName),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$seconds s",
              style: const TextStyle(fontSize: 50, color: Color(0xFFD0FD3E)),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                stopTimer();

                Navigator.pop(context, seconds);
              },

              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
