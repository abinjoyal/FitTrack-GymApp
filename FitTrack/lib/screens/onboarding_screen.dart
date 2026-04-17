import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final int initialPage;

  const OnboardingScreen({super.key, this.initialPage = 0});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _controller;
  int currentIndex = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/onboarding_01.jpg",
      "title": "Build Raw Strength. Own The Grind.",
      "desc":
          "Push beyond your limits and transform your body daily. Every rep brings you closer to greatness.",
    },
    {
      "image": "assets/onboarding_02.jpg",
      "title": "Stay Consistent. Track Every Step.",
      "desc":
          "Monitor workouts, calories, and daily progress. Small efforts lead to big results.",
    },
    {
      "image": "assets/onboarding_03.jpg",
      "title": "Unleash Your Power. Reach Your Peak.",
      "desc":
          "Train harder, move smarter, and achieve your goals. Your strongest version starts today.",
    },
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialPage;
    _controller = PageController(initialPage: widget.initialPage);
  }

  /// NEXT BUTTON
  void nextPage() {
    if (currentIndex < onboardingData.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  /// 🔥 FIXED SKIP (IMPORTANT)
Future<void> skipToLast() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setBool('first_time', false); // ✅ IMPORTANT

  if (!mounted) return;

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const LoginScreen()),
  );
}

Future<void> _finishOnboarding() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setBool('first_time', false); // ✅ IMPORTANT

  if (!mounted) return;

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const LoginScreen()),
  );
}
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: PageView.builder(
        controller: _controller,
        itemCount: onboardingData.length,
        onPageChanged: (index) {
          setState(() => currentIndex = index);
        },
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  onboardingData[index]["image"]!,
                  fit: BoxFit.cover,
                ),
              ),

              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(150, 0, 0, 0),
                        Color.fromARGB(230, 0, 0, 0),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.06,
                  vertical: size.height * 0.07,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),

                    Text(
                      onboardingData[index]["title"]!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size.width * 0.075,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: size.height * 0.02),

                    Text(
                      onboardingData[index]["desc"]!,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: size.width * 0.04,
                      ),
                    ),

                    SizedBox(height: size.height * 0.04),

                    /// NEXT BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: size.height * 0.07,
                      child: ElevatedButton(
                        onPressed: nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD0FD3E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          currentIndex == onboardingData.length - 1
                              ? "Get Started"
                              : "Next",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: size.width * 0.04,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.02),

                    /// 🔥 SKIP BUTTON
                    if (currentIndex != onboardingData.length - 1)
                      Center(
                        child: GestureDetector(
                          onTap: skipToLast, // 🔥 FIXED
                          child: Text(
                            "Skip for now",
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: size.width * 0.035,
                            ),
                          ),
                        ),
                      ),

                    SizedBox(height: size.height * 0.05),

                    /// DOTS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        onboardingData.length,
                        (dotIndex) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(
                            horizontal: size.width * 0.01,
                          ),
                          width: currentIndex == dotIndex
                              ? size.width * 0.035
                              : size.width * 0.02,
                          height: size.height * 0.01,
                          decoration: BoxDecoration(
                            color: currentIndex == dotIndex
                                ? const Color(0xFFD0FD3E)
                                : const Color(0xFF6B6B6B),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}