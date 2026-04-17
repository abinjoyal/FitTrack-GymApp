import 'package:flutter/material.dart';
import 'package:fit_track/workout/workout_details_screen.dart';

class ExerciseCardWidget extends StatelessWidget {
  final String title;
  final int time;
  final int kcal;
  final String instructions;
  final String muscle;
  final String videoUrl;
  final String imageUrl; // Supabase image url

  const ExerciseCardWidget({
    super.key,
    required this.title,
    required this.time,
    required this.kcal,
    required this.instructions,
    required this.muscle,
    required this.videoUrl,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () async {
        //  final result = await Navigator.push(
        final _ = await Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => WorkoutDetailsScreen(
              title: title,
              muscle: muscle,
              instructions: instructions,
              timeInMinutes: time,
              videoUrl: videoUrl,
            ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );

        // ✅ DO NOTHING HERE
      },
      child: Container(
        margin: EdgeInsets.only(bottom: size.height * 0.02),
        padding: EdgeInsets.all(size.width * 0.035),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(size.width * 0.05),
        ),
        child: Row(
          children: [
            /// SUPABASE IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                height: size.width * 0.22,
                width: size.width * 0.22,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: size.width * 0.22,
                    width: size.width * 0.22,
                    color: Colors.grey,
                    child: const Icon(Icons.image, color: Colors.white),
                  );
                },
              ),
            ),

            SizedBox(width: size.width * 0.04),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * 0.042,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: size.height * 0.012),

                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Colors.white54,
                        size: size.width * 0.045,
                      ),

                      SizedBox(width: size.width * 0.015),

                      Text(
                        "$time min",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: size.width * 0.036,
                        ),
                      ),

                      SizedBox(width: size.width * 0.04),

                      Icon(
                        Icons.local_fire_department,
                        color: Colors.white54,
                        size: size.width * 0.045,
                      ),

                      SizedBox(width: size.width * 0.015),

                      Text(
                        "$kcal kcal",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: size.width * 0.036,
                        ),
                      ),
                    ],
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

Widget buildTimeCard(
  BuildContext context,
  String title,
  String value,
  Color color,
  VoidCallback onAdd,
  VoidCallback onRemove,
) {
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
          title,
          style: TextStyle(color: Colors.white70, fontSize: size.width * 0.035),
        ),

        SizedBox(height: size.height * 0.01),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// ➖
            GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: EdgeInsets.all(size.width * 0.015),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white10,
                ),
                child: Icon(Icons.remove, color: Colors.white),
              ),
            ),

            SizedBox(width: size.width * 0.02),

            /// VALUE
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(width: size.width * 0.02),

            /// ➕
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding: EdgeInsets.all(size.width * 0.015),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // ignore: deprecated_member_use
                  color: color.withOpacity(0.2),
                ),
                child: Icon(Icons.add, color: color),
              ),
            ),
          ],
        ),
        SizedBox(height: size.height * 0.01),
      ],
    ),
  );
}
