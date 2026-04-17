import 'package:flutter/material.dart';

class CountWeightToggle extends StatelessWidget {
  final double width;
  final double height;

  final bool isCountMode;
  final int foodCount;
  final double weight;

  final TextEditingController weightController;

  final VoidCallback onCountTap;
  final VoidCallback onWeightTap;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final Function(String) onWeightChanged;

  const CountWeightToggle({
    super.key,
    required this.width,
    required this.height,
    required this.isCountMode,
    required this.foodCount,
    required this.weight,
    required this.weightController,
    required this.onCountTap,
    required this.onWeightTap,
    required this.onIncrement,
    required this.onDecrement,
    required this.onWeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        /// TOGGLE BUTTON
        Expanded(
          child: Container(
            height: height * 0.06,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 35, 57, 6),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                /// COUNT
                Expanded(
                  child: GestureDetector(
                    onTap: onCountTap,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isCountMode
                            ? const Color(0xFFC6F432)
                            : const Color.fromARGB(255, 35, 57, 6),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          "Count",
                          style: TextStyle(
                            color: isCountMode
                                ? const Color.fromARGB(255, 35, 57, 6)
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                /// WEIGHT
                Expanded(
                  child: GestureDetector(
                    onTap: onWeightTap,
                    child: Container(
                      decoration: BoxDecoration(
                        color: !isCountMode
                            ? const Color(0xFFC6F432)
                            : const Color.fromARGB(255, 35, 57, 6),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          "Weight",
                          style: TextStyle(
                            color: !isCountMode
                                ? Colors.black
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(width: width * 0.025),

        /// RIGHT SIDE
        if (isCountMode)
          /// COUNT STEPPER
          Container(
            height: height * 0.06,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1C2E05),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onDecrement,
                  child: const Icon(Icons.remove, color: Colors.white),
                ),
                SizedBox(width: width * 0.03),
                Text(
                  foodCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: width * 0.03),
                GestureDetector(
                  onTap: onIncrement,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          )
        else
          /// WEIGHT INPUT
          Container(
            height: height * 0.06,
            width: width * 0.3,
            padding: EdgeInsets.symmetric(horizontal: width * 0.03),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 35, 57, 6),
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "100",
                suffixText: " g",
                hintStyle: TextStyle(color: Colors.white70),
              ),
              onChanged: onWeightChanged,
            ),
          ),
      ],
    );
  }
}