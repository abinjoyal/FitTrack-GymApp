import 'package:fit_track/home/data/notification_data.dart';
import 'package:fit_track/models/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationModel> notifications = notificationList;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    final grouped = groupByDate();

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2E05),
        title: const Text("Notifications"),
        centerTitle: true,

        actions: [
          Stack(
            children: [
              const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.notifications),
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),

      /// 🔥 GRADIENT BODY
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1C2E05), Colors.black],
          ),
        ),

        child: ListView(
          padding: const EdgeInsets.all(12),
          children: grouped.entries.map((entry) {
            return buildSection(entry.key, entry.value);
          }).toList(),
        ),
      ),
    );
  }

  /// 📅 GROUP FUNCTION
  Map<String, List<NotificationModel>> groupByDate() {
    Map<String, List<NotificationModel>> map = {};

    for (var n in notifications) {
      String key;

      if (isToday(n.dateTime)) {
        key = "Today";
      } else if (isYesterday(n.dateTime)) {
        key = "Yesterday";
      } else {
        key = DateFormat('dd MMM yyyy').format(n.dateTime);
      }

      map.putIfAbsent(key, () => []);
      map[key]!.add(n);
    }

    return map;
  }

  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.day == now.day &&
        date.month == now.month &&
        date.year == now.year;
  }

  bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.day == yesterday.day &&
        date.month == yesterday.month &&
        date.year == yesterday.year;
  }

  /// 🧾 SECTION UI
  Widget buildSection(String title, List<NotificationModel> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),

        ...items.map((item) {
          return Dismissible(
            key: Key(item.title + item.dateTime.toString()),
            direction: DismissDirection.endToStart,

            onDismissed: (_) {
              setState(() {
                notifications.remove(item);
              });

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Deleted")));
            },

            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: Colors.red,
              child: const Icon(Icons.delete, color: Colors.white),
            ),

            child: GestureDetector(
              onTap: () {
                setState(() {
                  item.isRead = true;
                });
              },

              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: item.isRead
                      // ignore: deprecated_member_use
                      ? Colors.white.withOpacity(0.08)
                      // ignore: deprecated_member_use
                      : Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Row(
                  children: [
                    CircleAvatar(
                      // ignore: deprecated_member_use
                      backgroundColor: item.color.withOpacity(0.2),
                      child: Icon(item.icon, color: item.color),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.subtitle,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('hh:mm a').format(item.dateTime),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (!item.isRead)
                      const Icon(Icons.circle, size: 10, color: Colors.green),
                  ],
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 20),
      ],
    );
  }
}


