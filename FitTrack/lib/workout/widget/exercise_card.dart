import 'dart:io';

import 'package:flutter/material.dart';

class ExerciseCard extends StatelessWidget {
  final Map<String, dynamic> exercise;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    File? imageFile;
    final imagePath = exercise["image"];

    if (imagePath != null &&
        imagePath.toString().isNotEmpty &&
        File(imagePath).existsSync()) {
      imageFile = File(imagePath);
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      imageFile,
                      height: size.width * 0.16,
                      width: size.width * 0.16,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    height: size.width * 0.16,
                    width: size.width * 0.16,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        (exercise["name"] ?? "?")
                            .toString()
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

            SizedBox(width: size.width * 0.04),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise["name"] ?? "",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exercise["description"] ?? "",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}