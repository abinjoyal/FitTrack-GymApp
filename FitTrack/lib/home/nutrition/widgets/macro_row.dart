import 'package:flutter/material.dart';
import 'macro_box.dart';

class MacroRow extends StatelessWidget {
  final double width;

  final TextEditingController caloriesController;
  final TextEditingController proteinController;
  final TextEditingController carbsController;

  final bool useAI;

  final Function() onChanged;

  const MacroRow({
    super.key,
    required this.width,
    required this.caloriesController,
    required this.proteinController,
    required this.carbsController,
    required this.useAI,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MacroBox(
          label: "Calories",
          controller: caloriesController,
          unit: "kcal",
          useAI: useAI,
          onChanged: onChanged,
        ),

        SizedBox(width: width * 0.02),

        MacroBox(
          label: "Protein",
          controller: proteinController,
          unit: "g",
          useAI: useAI,
          onChanged: onChanged,
        ),

        SizedBox(width: width * 0.02),

        MacroBox(
          label: "Carbs",
          controller: carbsController,
          unit: "g",
          useAI: useAI,
          onChanged: onChanged,
        ),
      ],
    );
  }
}