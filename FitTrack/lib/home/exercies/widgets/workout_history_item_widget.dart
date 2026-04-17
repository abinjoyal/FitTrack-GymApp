import 'package:flutter/material.dart';

class WorkoutHistoryItem extends StatelessWidget {
  final Map<String, dynamic> item;

  const WorkoutHistoryItem({
    super.key,
    required this.item, required String exerciseName,
  });

  @override
  Widget build(BuildContext context) {

    String name = item["name"] ?? "No Exercise";

    String firstLetter =
        name.isNotEmpty ? name.characters.first.toUpperCase() : "?";

    final Size size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;

    return Container(
      margin: EdgeInsets.only(bottom: height * 0.01),
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.03,
        vertical: height * 0.012,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [

          /// Avatar
          Container(
            width: height * 0.05,
            height: height * 0.05,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFB7F43B),
            ),
            child: item["image"] != null && item["image"] != ""
                ? ClipOval(
                    child: Image.network(
                      item["image"],
                      fit: BoxFit.cover,
                    ),
                  )
                : Center(
                    child: Text(
                      firstLetter,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: width * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),

          SizedBox(width: width * 0.03),

          /// Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// Exercise Name
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: width * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: height * 0.004),

                /// Sets + Weight
                Text(
                  "Sets: ${item["sets"] ?? 0}   Weight: ${item["weight"] ?? 0} kg",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: width * 0.032,
                  ),
                ),

                SizedBox(height: height * 0.002),

                /// Workout + Break
                Text(
                  "Workout: ${item["workout_time"] ?? "--"} min | Break: ${item["break_rest"] ?? "--"} sec",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: width * 0.03,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}