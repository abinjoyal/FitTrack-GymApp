import 'package:flutter/material.dart';

class WorkoutTimerWidget extends StatelessWidget {
  final bool isRunning;
  final bool isBreak;
  final double progress;
  final int currentSeconds;
  final VoidCallback onTap;

  const WorkoutTimerWidget({
    super.key,
    required this.isRunning,
    required this.isBreak,
    required this.progress,
    required this.currentSeconds,
    required this.onTap,
  });

  String formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {

    final Size size = MediaQuery.of(context).size;

    final primaryColor = isBreak ? Colors.blue : Colors.orange;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [

          /// TIMER CIRCLE
          SizedBox(
            height: size.width * 0.45,
            width: size.width * 0.45,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: size.width * 0.03,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation(primaryColor),
            ),
          ),

          /// CENTER CONTENT
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Icon(
                isRunning ? Icons.pause : Icons.play_arrow,
                size: size.width * 0.11,
                color: primaryColor,
              ),

              SizedBox(height: size.height * 0.01),

              Text(
                formatTime(currentSeconds),
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
    );
  }
}
