import 'package:flutter/material.dart';

class ModeToggle extends StatelessWidget {
  final double width;
  final double height;
  final bool useAI;

  final VoidCallback onManualTap;
  final VoidCallback onAITap;

  const ModeToggle({
    super.key,
    required this.width,
    required this.height,
    required this.useAI,
    required this.onManualTap,
    required this.onAITap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        /// MANUAL
        Expanded(
          child: GestureDetector(
            onTap: onManualTap,
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: height * 0.01,
              ),
              decoration: BoxDecoration(
                color: !useAI
                    ? const Color(0xFFC6F432)
                    : const Color(0xFF1C2E05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: Center(
                child: Text(
                  "Manual",
                  style: TextStyle(
                    color: !useAI ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),

        SizedBox(width: width * 0.02),

        /// AI MODE
        Expanded(
          child: GestureDetector(
            onTap: onAITap,
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: height * 0.01,
              ),
              decoration: BoxDecoration(
                color: useAI
                    ? const Color(0xFFC6F432)
                    : const Color(0xFF1C2E05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: Center(
                child: Text(
                  "AI Mode",
                  style: TextStyle(
                    color: useAI ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}