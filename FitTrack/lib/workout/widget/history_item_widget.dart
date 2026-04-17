import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryItemWidget extends StatelessWidget {
  final int index;
  final String name;
  final String sets;
  final String weight;
  final String time;
  final String breakTime;
  final DateTime date;

  final bool isSelected;
  final bool isSelectionMode;

  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDelete;

  const HistoryItemWidget({
    super.key,
    required this.index,
    required this.name,
    required this.sets,
    required this.weight,
    required this.time,
    required this.breakTime,
    required this.date,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: isSelectionMode
          ? _buildItemUI()
          : Dismissible(
              key: ValueKey(index),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) => onDelete(),
              child: _buildItemUI(),
            ),
    );
  }

  Widget _buildItemUI() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSelected
            // ignore: deprecated_member_use
            ? Colors.green.withOpacity(0.3) // ✅ FIXED
            : Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔥 SAFE AVATAR
          CircleAvatar(
            radius: 27,
            backgroundColor: const Color(0xFFD0FD3E),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : "?", // ✅ FIXED
              style: const TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 12),

          /// 🔥 CONTENT
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        "Sets: $sets   Weight: $weight",
                        style: const TextStyle(color: Colors.white70),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        "Time: $time   Break: $breakTime",
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                ),

                /// 🔥 RIGHT SIDE
                Column(
                  children: [
                    Text(
                      DateFormat('hh:mm a').format(date),
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),

                    if (isSelectionMode)
                      Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: Colors.green,
                        size: 18,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}