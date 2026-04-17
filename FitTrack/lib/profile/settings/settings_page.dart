import 'dart:io';
import 'package:fit_track/profile/settings/alarm_screen.dart';
import 'package:fit_track/profile/settings/edit_profile_screen.dart';
import 'package:fit_track/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  File? imageFile;
  String? imageUrl;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  /// LOAD PROFILE DATA
  Future<void> loadProfile() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final data = await supabase
        .from("profiles")
        .select("image_url")
        .eq("id", auth.userId)
        .maybeSingle();

    if (data != null && data["image_url"] != null) {
      imageUrl = data["image_url"];
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final Size size = MediaQuery.of(context).size; // ✅ correct

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2E05), // 👈 best match
        elevation: 0,
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),

      body: Container(
        width: size.width, // ✅ use size
        height: size.height, // ✅ use size
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1C2E05), Colors.black],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.04, // 🔥 responsive padding
            vertical: size.height * 0.02,
          ),
          child: Column(
            children: [
              _sectionCard(
                title: "Account",
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white12,
                      backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
                          ? NetworkImage(
                              "${imageUrl!}?t=${DateTime.now().millisecondsSinceEpoch}",
                            )
                          : null,
                      child: imageUrl == null || imageUrl!.isEmpty
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    title: Text(
                      auth.userName,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      auth.userEmail,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    // trailing: const Icon(
                    //   Icons.chevron_right,
                    //   color: Colors.white,
                    // ),
                  ),
                  _tile(
                    "Edit Profile",
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) =>
                              const EditProfileScreen(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),
                  _tile("Privacy Settings"),
                ],
              ),

              SizedBox(height: size.height * 0.02),

              _sectionCard(
                title: "Notifications",
                children: [
                  _switchTile("Push Notifications", true),
                  _switchTile("Email Notifications", true),
                    _tile(
                    "Alarm",
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) =>
                              const AlarmScreen(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: size.height * 0.02),

              _sectionCard(
                title: "General",
                children: [
                  ListTile(
                    title: const Text(
                      "Language",
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          "English",
                          style: TextStyle(color: Colors.white70),
                        ),
                        Icon(Icons.chevron_right, color: Colors.white),
                      ],
                    ),
                  ),
                  _switchTile("Dark Mode", false),
                  _tile("Data & Storage"),
                ],
              ),

              SizedBox(height: size.height * 0.02),

              _sectionCard(
                title: "Support",
                children: [_tile("Help & FAQs"), _tile("Contact Us")],
              ),

              SizedBox(height: size.height * 0.04),
            ],
          ),
        ),
      ),
    );
  }

  /// SECTION CARD
  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.05), // glass effect
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          // ignore: deprecated_member_use
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  /// NORMAL TILE
  Widget _tile(String title, {VoidCallback? onTap}) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  /// SWITCH TILE
  Widget _switchTile(String text, bool value) {
    return StatefulBuilder(
      builder: (context, setState) {
        return SwitchListTile(
          title: Text(text, style: const TextStyle(color: Colors.white)),
          value: value,
          activeThumbColor: Colors.greenAccent,
          onChanged: (val) {
            setState(() => value = val);
          },
        );
      },
    );
  }
}
