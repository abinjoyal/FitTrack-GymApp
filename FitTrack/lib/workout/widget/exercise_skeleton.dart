import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class FullExerciseSkeleton extends StatelessWidget {
  const FullExerciseSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade900,
      highlightColor: Colors.grey.shade800,
      child: Column(
        children: [
          const SizedBox(height: 20),

          /// 🔥 CHIP SKELETON
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5,
              itemBuilder: (_, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 80,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(25),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          /// 🔥 LIST SKELETON
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 6,
              itemBuilder: (_, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      /// IMAGE
                      Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      const SizedBox(width: 12),

                      /// TEXT
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(height: 14, color: Colors.grey),
                            const SizedBox(height: 10),
                            Container(height: 12, width: 120, color: Colors.grey),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}