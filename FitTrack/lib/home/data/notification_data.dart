import 'package:fit_track/models/notification_model.dart';
import 'package:flutter/material.dart';

List<NotificationModel> notificationList = [
  NotificationModel(
    title: "Workout Time 💪",
    subtitle: "No pain, no gain!",
    dateTime: DateTime.now().subtract(const Duration(minutes: 5)),
    icon: Icons.fitness_center,
    color: Colors.orange,
    isRead: false,
  ),
  NotificationModel(
    title: "Calories Burned 🔥",
    subtitle: "You burned 300 kcal today",
    dateTime: DateTime.now().subtract(const Duration(hours: 1)),
    icon: Icons.local_fire_department,
    color: Colors.red,
    isRead: false,
  ),
  NotificationModel(
    title: "Hydration 💧",
    subtitle: "Drink water bro!",
    dateTime: DateTime.now().subtract(const Duration(days: 1)),
    icon: Icons.water_drop,
    color: Colors.blue,
    isRead: true,
  ),

  /// 🔥 NEW 5 MESSAGES
  NotificationModel(
    title: "Protein Reminder 🥚",
    subtitle: "Time to hit your protein goal!",
    dateTime: DateTime.now().subtract(const Duration(minutes: 30)),
    icon: Icons.restaurant,
    color: Colors.green,
    isRead: false,
  ),
  NotificationModel(
    title: "Steps Goal 🚶",
    subtitle: "You reached 8,000 steps!",
    dateTime: DateTime.now().subtract(const Duration(hours: 2)),
    icon: Icons.directions_walk,
    color: Colors.teal,
    isRead: false,
  ),
  NotificationModel(
    title: "Sleep Reminder 😴",
    subtitle: "Get at least 7 hours sleep",
    dateTime: DateTime.now().subtract(const Duration(hours: 5)),
    icon: Icons.bedtime,
    color: Colors.deepPurple,
    isRead: true,
  ),
  NotificationModel(
    title: "New Workout Plan 🏋️",
    subtitle: "Try today's chest workout",
    dateTime: DateTime.now().subtract(const Duration(days: 2)),
    icon: Icons.sports_gymnastics,
    color: Colors.amber,
    isRead: false,
  ),
  NotificationModel(
    title: "Weekly Progress 📊",
    subtitle: "You improved by 12% this week!",
    dateTime: DateTime.now().subtract(const Duration(days: 3)),
    icon: Icons.bar_chart,
    color: Colors.cyan,
    isRead: true,
  ),
];