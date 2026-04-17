import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFFD0FD3E);
  static const darkGreen = Color(0xFF1C2E05);
  static const deepBlack = Color(0xFF0B1A02);

  static const background = Colors.black;
  static const card = Colors.white10;
  static const glass = Colors.white12;

  static const textPrimary = Colors.white;
  static const textSecondary = Colors.white70;
  static const hint = Colors.white54;

  static const border = Colors.white24;
}

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1C2E05),
            Colors.black,
          ],
        ),
      ),
      child: child,
    );
  }
}