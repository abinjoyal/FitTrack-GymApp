import 'package:flutter/material.dart';

class MacroBox extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String unit;

  final bool useAI;
  final Function() onChanged;

  const MacroBox({
    super.key,
    required this.label,
    required this.controller,
    required this.unit,
    required this.useAI,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    double value = double.tryParse(controller.text) ?? 0;

    Color accentColor;

    if (label == "Calories") {
      accentColor = const Color(0xFFC6F432);
    } else if (label == "Protein") {
      accentColor = Colors.blue;
    } else {
      accentColor = Colors.orange;
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1C2E05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white24, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF1C1C1E),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ICON + LABEL
            Row(
              children: [
                Icon(
                  label == "Calories"
                      ? Icons.local_fire_department
                      : label == "Protein"
                          ? Icons.fitness_center
                          : Icons.grass,
                  color: accentColor,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(label, style: const TextStyle(color: Colors.white)),
              ],
            ),

            const SizedBox(height: 2),

            /// TEXT FIELD
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "0",
                hintStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                suffixText: unit,
                suffixStyle: const TextStyle(color: Colors.grey),
              ),
              onChanged: (_) => onChanged(),
            ),

            const SizedBox(height: 6),

            /// PROGRESS BAR
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (value / 100).clamp(0, 1),
                backgroundColor: Colors.white12,
                color: accentColor,
                minHeight: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}