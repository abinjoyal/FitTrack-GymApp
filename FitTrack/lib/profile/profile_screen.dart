import 'dart:ui';
import 'package:fit_track/profile/feedback_page.dart';
import 'package:fit_track/profile/settings/settings_page.dart';
import 'package:fit_track/profile/history_page.dart';
import 'package:fit_track/profile/progress_page.dart';
import 'package:fit_track/provider/auth_provider.dart';
import 'package:fit_track/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? imageUrl;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (auth.isGuest) {
      if (mounted) setState(() {});
      return;
    }

    final data = await supabase
        .from("profiles")
        .select("name, email, image_url")
        .eq("id", auth.userId)
        .maybeSingle();

    if (data != null) {
      imageUrl = data["image_url"];
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1C2E05), Colors.black],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: size.height * 0.05),

              /// 🔥 PROFILE CARD
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: size.height * 0.035,
                      ),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        children: [
                          /// 🔥 PROFILE IMAGE (FIXED)
                          CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.white12,
                            backgroundImage:
                                imageUrl != null && imageUrl!.isNotEmpty
                                ? NetworkImage(
                                    "${imageUrl!}?t=${DateTime.now().millisecondsSinceEpoch}",
                                  )
                                : null,
                            child: imageUrl == null || imageUrl!.isEmpty
                                ? const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 70,
                                  )
                                : null,
                          ),

                          SizedBox(height: size.height * 0.015),

                          /// 🔥 NAME
                          Text(
                            auth.userName,
                            style: TextStyle(
                              fontSize: size.width * 0.055,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          SizedBox(height: size.height * 0.005),

                          /// 🔥 EMAIL
                          Text(
                            auth.userEmail,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: size.width * 0.035,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.04),

              /// 🔥 MENU
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                  child: ListView(
                    children: [
                      _buildTile(
                        Icons.bar_chart,
                        "Progress Stats",
                        size,
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => ProgressPage(),
                              transitionDuration: Duration.zero,
                            ),
                          );
                        },
                      ),
                      _buildTile(
                        Icons.feedback,
                        "Feed back",
                        size,
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => FeedbackPage(),
                              transitionDuration: Duration.zero,
                            ),
                          );
                        },
                      ),
                      _buildTile(
                        Icons.history,
                        "History",
                        size,
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => HistoryPage(),
                              transitionDuration: Duration.zero,
                            ),
                          );
                        },
                      ),

                      _buildTile(
                        Icons.settings,
                        "Settings",
                        size,
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => SettingsPage(),
                              transitionDuration: Duration.zero,
                            ),
                          );
                        },
                      ),
                      SizedBox(height: size.height * 0.02),

                      /// 🔥 LOGOUT
                      GestureDetector(
                        onTap: () async {
                          await auth.logout();

                          Navigator.pushAndRemoveUntil(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => LoginScreen(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                            (route) => false,
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: size.height * 0.018,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFC71212), Color(0xFFDF3906)],
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.logout, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                "Logout",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: size.width * 0.04,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔧 TILE
  Widget _buildTile(
    IconData icon,
    String title,
    Size size, {
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: size.height * 0.02),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFD0FD3E)),
        title: Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: size.width * 0.04),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: size.width * 0.04,
          color: Colors.white70,
        ),
        onTap: onTap,
      ),
    );
  }
}
