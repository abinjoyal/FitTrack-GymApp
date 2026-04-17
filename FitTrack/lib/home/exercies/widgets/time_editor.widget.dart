 import 'package:flutter/material.dart';

Widget buildTimeEditor({
    required String title,
    required int seconds,
    required Color color,
    required VoidCallback onAdd,
    required VoidCallback onMinus,
    required bool isWorkout,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            GestureDetector(
              onTap: onMinus,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white12,
                child: const Icon(Icons.remove, color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),

            /// 🔥 DISPLAY DIFFERENT FORMAT
            Text(
              isWorkout ? "${(seconds ~/ 60)} min" : "$seconds sec",
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(width: 10),
            GestureDetector(
              onTap: onAdd,
              child: CircleAvatar(
                radius: 18,
                // ignore: deprecated_member_use
                backgroundColor: color.withOpacity(0.2),
                child: Icon(Icons.add, color: color),
              ),
            ),
          ],
        ),
      ],
    );
  }