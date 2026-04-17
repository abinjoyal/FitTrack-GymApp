import 'package:flutter/material.dart';

Widget buildStatCard({
  required String title,
  required String value,
  required Color valueColor,
  required VoidCallback onAdd,
  required VoidCallback onMinus,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 30),
    decoration: BoxDecoration(
      color: const Color(0xFF1C1C1E),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: onMinus,
              child: Container(
                height: 32,
                width: 32,
                decoration: const BoxDecoration(
                  color: Colors.white12,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.remove, color: Colors.white),
              ),
            ),

            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            GestureDetector(
              onTap: onAdd,
              child: Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: valueColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, color: valueColor),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
