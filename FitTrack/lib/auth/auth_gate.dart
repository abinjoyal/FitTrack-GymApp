// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../dashboard/dashboard_screen.dart';
// import '../screens/login_screen.dart';
// import '../screens/onboarding_screen.dart';

// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final supabase = Supabase.instance.client;

//     return FutureBuilder<bool>(
//       future: _checkFirstTime(),
//       builder: (context, snapshot) {
//         /// LOADING
//         if (!snapshot.hasData) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         final isFirstTime = snapshot.data!;

//         /// 🔥 FIRST TIME → ONBOARDING
//         if (isFirstTime) {
//           return const OnboardingScreen();
//         }

//         /// 🔐 AUTH CHECK
//         return StreamBuilder<AuthState>(
//           stream: supabase.auth.onAuthStateChange,
//           builder: (context, authSnapshot) {
//             if (authSnapshot.connectionState == ConnectionState.waiting) {
//               return const Scaffold(
//                 body: Center(child: CircularProgressIndicator()),
//               );
//             }

//             final session = authSnapshot.data?.session;

//             if (session != null) {
//               return const DashboardScreen();
//             }

//             return const LoginScreen();
//           },
//         );
//       },
//     );
//   }

//   Future<bool> _checkFirstTime() async {
//     final prefs = await SharedPreferences.getInstance();

//     await prefs.clear(); // 🔥 HARD RESET

//     await prefs.setBool('first_time', true); // 🔥 FORCE TRUE

//     final value = prefs.getBool('first_time');

//     print("FORCED VALUE: $value");

//     return value ?? true;
//   }
// }
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../dashboard/dashboard_screen.dart';
import '../screens/login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.data?.session;

        if (session != null) {
          return const DashboardScreen();
        }

        return const LoginScreen();
      },
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// import '../dashboard/dashboard_screen.dart';
// import '../screens/login_screen.dart';
// import '../screens/onboarding_screen.dart';

// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<bool>(
//       future: _checkFirstTime(),
//       builder: (context, snapshot) {

//         /// 🔄 LOADING
//         if (!snapshot.hasData) {
//           return const Scaffold(
//             backgroundColor: Colors.black,
//             body: Center(
//               child: CircularProgressIndicator(color: Color(0xFFD0FD3E)),
//             ),
//           );
//         }

//         final isFirstTime = snapshot.data!;

//         /// 🆕 FIRST TIME → ONBOARDING
//         if (isFirstTime) {
//           return const OnboardingScreen();
//         }

//         /// 🔐 AUTH CHECK (REALTIME)
//         return StreamBuilder<AuthState>(
//           stream: Supabase.instance.client.auth.onAuthStateChange,
//           builder: (context, authSnapshot) {

//             if (!authSnapshot.hasData) {
//               return const Scaffold(
//                 backgroundColor: Colors.black,
//                 body: Center(
//                   child: CircularProgressIndicator(color: Color(0xFFD0FD3E)),
//                 ),
//               );
//             }

//             final session = authSnapshot.data?.session;

//             /// ✅ LOGGED IN
//             if (session != null) {
//               return const DashboardScreen();
//             }

//             /// ❌ NOT LOGGED IN
//             return const LoginScreen();
//           },
//         );
//       },
//     );
//   }

//   /// 🔥 CHECK FIRST TIME
//   Future<bool> _checkFirstTime() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool('first_time') ?? true;
//   }
// }