import 'package:flutter/material.dart';

Widget buildWeightCard(
  BuildContext context, {
  required double weight,
  required VoidCallback onAddWeight,
  required VoidCallback onRemoveWeight,
}) {
  final Size size = MediaQuery.of(context).size;

  return Container(
    padding: EdgeInsets.symmetric(vertical: size.height * 0.000),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: Colors.white24),
      color: Colors.grey.shade900,
    ),

    child: Column(
      children: [
        SizedBox(height: size.height * 0.01),

        Text(
          "Weight (kg)",
          style: TextStyle(color: Colors.white70, fontSize: size.width * 0.035),
        ),

        SizedBox(height: size.height * 0.01),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// ➖ MINUS
            GestureDetector(
              onTap: onRemoveWeight,
              child: Container(
                padding: EdgeInsets.all(size.width * 0.015),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white10,
                ),
                child: Icon(
                  Icons.remove,
                  color: Colors.white,
                  size: size.width * 0.05,
                ),
              ),
            ),

            SizedBox(width: size.width * 0.02),

            /// 🔥 WEIGHT VALUE
            Text(
              weight.toStringAsFixed(2), // 0.15 format
              style: TextStyle(
                color: Colors.blue,
                fontSize: size.width * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(width: size.width * 0.02),

            /// ➕ PLUS
            GestureDetector(
              onTap: onAddWeight,
              child: Container(
                padding: EdgeInsets.all(size.width * 0.015),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // ignore: deprecated_member_use
                  color: Colors.blue.withOpacity(0.2),
                ),
                child: Icon(
                  Icons.add,
                  color: Colors.blue,
                  size: size.width * 0.05,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: size.height * 0.01),
      ],
    ),
  );
}

Widget buildStatCard(
  BuildContext context,
  String title,
  String value,
  Color valueColor,
  VoidCallback onAdd,
  VoidCallback onRemove,
) {
  final Size size = MediaQuery.of(context).size;

  return Container(
    padding: EdgeInsets.symmetric(vertical: size.height * 0.000),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: Colors.white24),
      color: Colors.grey.shade900, // 🔥 better UI
    ),
    child: Column(
      children: [
        SizedBox(height: size.height * 0.01),
        Text(
          title,
          style: TextStyle(color: Colors.white70, fontSize: size.width * 0.035),
        ),

        SizedBox(height: size.height * 0.01),

        /// 🔥 VALUE + BUTTONS
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// ➖ MINUS BUTTON
            GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: EdgeInsets.all(size.width * 0.015),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white10,
                ),
                child: Icon(
                  Icons.remove,
                  color: Colors.white,
                  size: size.width * 0.05,
                ),
              ),
            ),

            SizedBox(width: size.width * 0.06),

            /// VALUE
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: size.width * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(width: size.width * 0.06),

            /// ➕ PLUS BUTTON
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding: EdgeInsets.all(size.width * 0.015),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // ignore: deprecated_member_use
                  color: valueColor.withOpacity(0.2),
                ),
                child: Icon(
                  Icons.add,
                  color: valueColor,
                  size: size.width * 0.05,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: size.height * 0.01),
      ],
    ),
  );
}
