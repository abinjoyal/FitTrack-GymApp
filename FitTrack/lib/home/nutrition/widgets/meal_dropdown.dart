import 'package:flutter/material.dart';

class MealDropdown extends StatelessWidget {
  final String? selectedMeal;
  final List<String> mealTypes;
  final Function(String?) onChanged;

  const MealDropdown({
    super.key,
    required this.selectedMeal,
    required this.mealTypes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return DropdownButtonFormField<String>(
      initialValue: selectedMeal,
      dropdownColor: const Color(0xFF1C1C1E),
      style: const TextStyle(color: Colors.white),
      icon: const Icon(
        Icons.keyboard_arrow_down,
        color: Colors.white,
      ),

      decoration: InputDecoration(
        hintStyle: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: const Icon(
          Icons.restaurant_menu,
          color: Colors.orange,
        ),
        filled: true,
        fillColor: const Color(0xFF1C2E05),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Colors.white24,
            width: 1,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Color(0xFFC6F432),
            width: 1.5,
          ),
        ),
      ),

      items: mealTypes.map((meal) {
        return DropdownMenuItem(
          value: meal,
          child: Row(
            children: [
              const Icon(
                Icons.fastfood,
                color: Colors.orange,
                size: 18,
              ),
              SizedBox(width: width * 0.025),
              Text(meal),
            ],
          ),
        );
      }).toList(),

      onChanged: onChanged,
    );
  }
}