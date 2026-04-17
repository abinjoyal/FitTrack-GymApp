import 'package:fit_track/home/widgets/notification_page.dart';
import 'package:fit_track/provider/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HeaderWidget extends StatefulWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  const HeaderWidget({super.key, this.onNotificationTap, this.onProfileTap});

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  int badgeCount = 0;

  @override
  void initState() {
    super.initState();
    loadBadge();
  }

  Future<void> loadBadge() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      badgeCount = prefs.getInt("badge") ?? 0;
    });
  }

  Future<void> clearBadge() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("badge", 0);

    setState(() {
      badgeCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// LEFT SIDE
          Row(
            children: [
              /// PROFILE IMAGE
              GestureDetector(
                onTap: widget.onProfileTap,
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white12,
                  backgroundImage: provider.imageUrl.isNotEmpty
                      ? NetworkImage(
                          "${provider.imageUrl}?t=${DateTime.now().millisecondsSinceEpoch}",
                        )
                      : null,
                  child: provider.imageUrl.isEmpty
                      ? const Icon(
                          Icons.person,
                          color: Colors.black,
                          size: 30,
                        )
                      : null,
                ),
              ),

              SizedBox(width: size.width * 0.04),

              /// NAME
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hi, ${provider.name.isNotEmpty ? provider.name : "User"} 💪",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "Let's know about your progress",
                    style: TextStyle(fontSize: 14, color: Colors.white60),
                  ),
                ],
              ),
            ],
          ),

          /// RIGHT SIDE (NOTIFICATION + BADGE)
          GestureDetector(
            onTap: () async {
              await clearBadge(); // 🔥 reset badge

              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const NotificationScreen(),
                  transitionDuration: Duration.zero,
                ),
              );

              widget.onNotificationTap?.call();
            },
            child: Stack(
              children: [
                const CircleAvatar(
                  radius: 27,
                  backgroundColor: Colors.white12,
                  child: Icon(
                    Icons.notifications_none_outlined,
                    color: Colors.white,
                  ),
                ),

                /// 🔴 BADGE
                if (badgeCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        badgeCount > 9 ? "9+" : "$badgeCount",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}