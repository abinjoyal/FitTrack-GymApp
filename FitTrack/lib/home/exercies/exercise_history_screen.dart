import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExerciseHistoryScreen extends StatefulWidget {
  final String exerciseName;

  const ExerciseHistoryScreen({super.key, required this.exerciseName});

  @override
  State<ExerciseHistoryScreen> createState() => _ExerciseHistoryScreenState();
}

class _ExerciseHistoryScreenState extends State<ExerciseHistoryScreen> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> historyList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  /// 🔥 LOAD DATA
  Future<void> loadHistory() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await supabase
          .from("history")
          .select()
          .eq("user_id", user.id)
          .eq("type", "workout")
          .ilike("exercise_name", widget.exerciseName)
          .order("date", ascending: false);

      setState(() {
        historyList = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ Error: $e");
      setState(() => isLoading = false);
    }
  }

  /// 🔥 SAFE TIME
  String getTime(dynamic item) {
    final value = item["time"];
    if (value == null || value.toString().isEmpty) return "0";
    return value.toString();
  }

  /// 🔥 SAFE BREAK
  String getBreak(dynamic item) {
    final value = item["break_time"];

    if (value == null || value.toString().isEmpty) return "No Break";
    if (value.toString().toLowerCase() == "no") return "No Break";

    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.exerciseName,
          style: const TextStyle(color: Colors.white),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : historyList.isEmpty
          ? const Center(
              child: Text(
                "No History",
                style: TextStyle(color: Colors.white54),
              ),
            )
          : ListView.builder(
              itemCount: historyList.length,
              itemBuilder: (context, index) {
                final item = historyList[index];

                return Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ICON
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: const Color(0xFFD0FD3E),
                        child: Text(
                          widget.exerciseName.isNotEmpty
                              ? widget.exerciseName[0].toUpperCase()
                              : "?",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 28, // 🔥 increase this
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      /// DETAILS
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// NAME
                            Text(
                              item["exercise_name"] ?? "",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 4),

                            /// SET + WEIGHT (FIXED GAP ❌➡️✅)
                            Row(
                              children: [
                                Text(
                                  "Set: ${item["sets"] ?? 0}",
                                  style: const TextStyle(color: Colors.white70),
                                ),

                                const SizedBox(width: 20),

                                Text(
                                  "Weight: ${item["weight"] ?? 0} kg",
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),

                            const SizedBox(height: 2),

                            /// TIME + BREAK
                            Row(
                              children: [
                                Text(
                                  "Time: ${getTime(item)}",
                                  style: const TextStyle(color: Colors.white54),
                                ),

                                const SizedBox(width: 20),

                                Text(
                                  "Break: ${getBreak(item)}",
                                  style: const TextStyle(color: Colors.white54),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      /// RIGHT TIME
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item["date"] != null
                                ? DateFormat(
                                    'hh:mm a',
                                  ).format(DateTime.parse(item["date"]))
                                : "",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item["date"] != null
                                ? DateFormat(
                                    'dd MMM yyyy',
                                  ).format(DateTime.parse(item["date"]))
                                : "",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
