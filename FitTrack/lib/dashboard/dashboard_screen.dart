import 'package:fit_track/profile/Chat/chat_scrren.dart';
import 'package:flutter/material.dart';
import 'package:fit_track/home/home_screen.dart';
import 'package:fit_track/profile/profile_screen.dart';
import 'package:fit_track/workout/exercies_screen.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    FoodChatScreen(),
    ExerciseScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: _screens[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.black,
        color: Colors.white24,
        buttonBackgroundColor: const Color(0xFFD0FD3E),
        height: size.height * 0.07,
        animationDuration: const Duration(milliseconds: 300),
        items: [
          Icon(
            Icons.home,
            color: _currentIndex == 0 ? Colors.black : Colors.white,
          ),

          Icon(
            Icons.smart_toy,
            color: _currentIndex == 1 ? Colors.black : Colors.white,
          ),

          Icon(
            Icons.fitness_center,
            color: _currentIndex == 2 ? Colors.black : Colors.white,
          ),

          Icon(
            Icons.person,
            color: _currentIndex == 3 ? Colors.black : Colors.white,
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
