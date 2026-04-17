import 'dart:async';
import 'package:fit_track/home/data/motivation_data.dart';
import 'package:flutter/material.dart';

class MotivationWidget extends StatefulWidget {
  const MotivationWidget({super.key});

  @override
  State<MotivationWidget> createState() => _MotivationWidgetState();
}

class _MotivationWidgetState extends State<MotivationWidget> {
  int currentIndex = 0;

  final motivationData = MotivationData.list;

  // @override
  // void initState() {
  //   super.initState();

  //   _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
  //     setState(() {
  //       currentIndex = (currentIndex + 1) % motivationData.length;
  //     });
  //   });
  // }

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;

      setState(() {
        currentIndex = (currentIndex + 1) % motivationData.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final data = motivationData[currentIndex];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: Container(
          key: ValueKey(currentIndex),
          height: size.height * 0.20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1C2E05), Colors.black],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Opacity(
                  opacity: 0.25,
                  child: Image.asset(
                    data["image"]!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  data["text"]!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
