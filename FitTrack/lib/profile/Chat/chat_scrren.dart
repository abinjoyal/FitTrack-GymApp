import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FoodChatScreen extends StatefulWidget {
  const FoodChatScreen({super.key});

  @override
  State<FoodChatScreen> createState() => _FoodChatScreenState();
}

class _FoodChatScreenState extends State<FoodChatScreen> {
  final TextEditingController controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, String>> messages = [
    {
      "role": "bot",
      "text": "💪 Gym AI Ready!\nAsk anything about workout, diet...",
    },
  ];

  /// ✅ SAFE TEXT (FIX UTF ERROR)
  String safeText(String? text) {
    if (text == null) return "No response";

    try {
      return text
          .replaceAll(RegExp(r'[\uD800-\uDFFF]'), '') // remove bad unicode
          .trim();
    } catch (e) {
      return "Error text";
    }
  }

  /// 🔥 Typing animation
  Future<void> typeWriterEffect(String text) async {
    text = safeText(text);

    String current = "";

    setState(() {
      messages.add({"role": "bot", "text": ""});
    });

    _scrollToBottom();

    for (int i = 0; i < text.length; i++) {
      await Future.delayed(const Duration(milliseconds: 15));
      current += text[i];

      setState(() {
        messages[messages.length - 1]["text"] = current;
      });

      _scrollToBottom();
    }
  }

  /// 🔥 Auto scroll
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// 🚀 Send message
  Future<void> sendMessage() async {
    String text = controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({"role": "user", "text": safeText(text)});
    });

    controller.clear();
    _scrollToBottom();

    /// typing indicator
    setState(() {
      messages.add({"role": "bot", "text": "Typing..."});
    });

    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:3000/api/chat"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": text}),
      );

      final data = jsonDecode(response.body);

      setState(() {
        messages.removeLast(); // remove typing
      });

      String reply = safeText(data["reply"]);
      await typeWriterEffect(reply);

    } catch (e) {
      setState(() {
        messages.removeLast();
        messages.add({"role": "bot", "text": "Server error ❌"});
      });

      _scrollToBottom();
    }
  }

  /// 💬 Message UI
  Widget buildMessage(Map<String, String> msg) {
    bool isUser = msg["role"] == "user";

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),

        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xFFD0FD3E)
              : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft:
                isUser ? const Radius.circular(18) : const Radius.circular(4),
            bottomRight:
                isUser ? const Radius.circular(4) : const Radius.circular(18),
          ),
          border: Border.all(
            color: isUser ? Colors.transparent : Colors.white12,
          ),
        ),

        child: Text(
          safeText(msg["text"]), // ✅ SAFE TEXT HERE
          style: TextStyle(
            color: isUser ? Colors.black : Colors.white,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text(
          "AI Chat",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),

      extendBodyBehindAppBar: true,

      body: Container(
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
        child: SafeArea(
          child: Column(
            children: [
              /// CHAT LIST
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return buildMessage(messages[index]);
                  },
                ),
              ),

              /// INPUT
              Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Ask workout, diet...",
                          hintStyle:
                              const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.grey.shade900,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 10),

                    CircleAvatar(
                      radius: 25,
                      backgroundColor: const Color(0xFFD0FD3E),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.black),
                        onPressed: sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}