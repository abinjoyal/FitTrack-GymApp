import 'package:flutter/material.dart';

class WeightCard extends StatelessWidget {
  final double weight;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const WeightCard({
    super.key,
    required this.weight,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          const Text("Weight (kg)", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onRemove,
                child: Container(
                  height: 32,
                  width: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white12,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.remove, color: Colors.white),
                ),
              ),

              Text(
                weight.toStringAsFixed(2),
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              GestureDetector(
                onTap: onAdd,
                child: Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.blue.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.blue),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
