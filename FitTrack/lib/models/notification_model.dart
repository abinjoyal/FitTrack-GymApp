import 'package:flutter/material.dart';

class NotificationModel {
  final String title;
  final String subtitle;
  final DateTime dateTime;
  final IconData icon;
  final Color color;
  bool isRead;

  NotificationModel({
    required this.title,
    required this.subtitle,
    required this.dateTime,
    required this.icon,
    required this.color,
    required this.isRead,
  });
}