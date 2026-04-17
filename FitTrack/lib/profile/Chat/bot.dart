import 'package:fit_track/profile/Chat/chat_scrren.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class DraggableChatHead extends StatefulWidget {
  const DraggableChatHead({super.key});

  @override
  State<DraggableChatHead> createState() => _DraggableChatHeadState();
}

class _DraggableChatHeadState extends State<DraggableChatHead>
    with SingleTickerProviderStateMixin {
  Offset position = const Offset(300, 500);
  Offset velocity = Offset.zero;

  late AnimationController _controller;

  final double sizeBall = 60;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updatePosition);
  }

  void _updatePosition() {
    final screen = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    setState(() {
      position += velocity;

      // friction
      velocity *= 0.985;

      // LEFT
      if (position.dx <= 0) {
        position = Offset(0, position.dy);
        velocity = Offset(-velocity.dx * 0.8, velocity.dy);
      }

      // RIGHT
      if (position.dx >= screen.width - sizeBall) {
        position = Offset(screen.width - sizeBall, position.dy);
        velocity = Offset(-velocity.dx * 0.8, velocity.dy);
      }

      // TOP (safe area)
      if (position.dy <= padding.top) {
        position = Offset(position.dx, padding.top);
        velocity = Offset(velocity.dx, -velocity.dy * 0.8);
      }

      // BOTTOM
      if (position.dy >= screen.height - sizeBall - 20) {
        position = Offset(position.dx, screen.height - sizeBall - 20);
        velocity = Offset(velocity.dx, -velocity.dy * 0.7);
      }

      // STOP
      if (velocity.distance < 0.6) {
        velocity = Offset.zero;
        _controller.stop();
        _snapToEdge(screen);
        HapticFeedback.lightImpact();
      }
    });
  }

  void _snapToEdge(Size screen) {
    double middle = screen.width / 2;

    setState(() {
      if (position.dx < middle) {
        position = Offset(10, position.dy);
      } else {
        position = Offset(screen.width - sizeBall - 10, position.dy);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanStart: (_) => _controller.stop(),

        onPanUpdate: (details) {
          setState(() {
            position += details.delta;
            velocity = details.delta * 3;
          });
        },

        onPanEnd: (details) {
          velocity = details.velocity.pixelsPerSecond * 0.004;
          _controller.repeat();
        },

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FoodChatScreen()),
          );
        },

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: sizeBall,
          height: sizeBall,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Colors.teal, Colors.green],
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 15,
                spreadRadius: 2,
                color: Colors.black26,
              ),
            ],
          ),
          child: const Icon(
            Icons.smart_toy,
            color: Colors.white,
            size: 28, // 🔥 improved
          ),
        ),
      ),
    );
  }
}