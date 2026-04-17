import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> workoutHistory = [];
  List<Map<String, dynamic>> mealHistory = [];

  late TabController _tabController;

  bool selectionMode = false;
  Set<int> selectedItems = {};

  @override
  void initState() {
    super.initState();
    loadHistory();
    _tabController = TabController(length: 2, vsync: this);
  }

  /// 🔥 LOAD HISTORY
  Future<void> loadHistory() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final workouts = await supabase
        .from("history")
        .select()
        .eq("user_id", user.id)
        .eq("type", "workout")
        .order("date", ascending: false);

    final meals = await supabase
        .from("history")
        .select()
        .eq("user_id", user.id)
        .eq("type", "meal")
        .order("date", ascending: false);

    setState(() {
      workoutHistory = List<Map<String, dynamic>>.from(workouts);
      mealHistory = List<Map<String, dynamic>>.from(meals);
    });
  }

  /// 🔥 DELETE SELECTED
  Future<void> deleteSelected() async {
    final list =
        _tabController.index == 0 ? workoutHistory : mealHistory;

    final ids = selectedItems.map((i) => list[i]["id"]).toList();

    await supabase.from("history").delete().inFilter("id", ids);

    selectedItems.clear();
    selectionMode = false;

    await loadHistory();
  }

  /// 🔥 DELETE ALL
  Future<void> deleteAllHistory() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final type = _tabController.index == 0 ? "workout" : "meal";

    await supabase
        .from("history")
        .delete()
        .eq("user_id", user.id)
        .eq("type", type);

    await loadHistory();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("All history deleted")),
    );
  }

  void confirmDeleteAll() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text("Delete All?", style: TextStyle(color: Colors.white)),
        content: const Text(
          "This cannot be undone",
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteAllHistory();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// 🔥 WORKOUT UI
  Widget buildWorkoutHistory() {
    if (workoutHistory.isEmpty) {
      return const Center(
        child: Text("No Workout History",
            style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: workoutHistory.length,
      itemBuilder: (context, index) {
        final item = workoutHistory[index];

        String name = item["exercise_name"] ?? "";
        int sets = item["sets"] ?? 0;
        double weight = (item["weight"] ?? 0).toDouble();

        String date = "";
        if (item["date"] != null) {
          date = DateFormat('dd MMM yyyy')
              .format(DateTime.parse(item["date"]));
        }

        return GestureDetector(
          onLongPress: () {
            setState(() {
              selectionMode = true;
              selectedItems.add(index);
            });
          },
          onTap: () {
            if (selectionMode) {
              setState(() {
                if (selectedItems.contains(index)) {
                  selectedItems.remove(index);
                } else {
                  selectedItems.add(index);
                }
              });
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: selectedItems.contains(index)
                  // ignore: deprecated_member_use
                  ? const Color(0xFFB7F43B).withOpacity(0.2)
                  : const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                if (selectionMode)
                  Icon(
                    selectedItems.contains(index)
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: selectedItems.contains(index)
                        ? const Color(0xFFB7F43B)
                        : Colors.grey,
                  ),

                const SizedBox(width: 10),

                CircleAvatar(
                  backgroundColor: const Color(0xFFB7F43B),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : "?",
                    style: const TextStyle(color: Colors.black),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Sets: $sets | Weight: $weight kg",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        date,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 🔥 MEAL UI
  Widget buildMealHistory() {
    if (mealHistory.isEmpty) {
      return const Center(
        child:
            Text("No Food History", style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mealHistory.length,
      itemBuilder: (context, index) {
        final item = mealHistory[index];

        String name = item["name"] ?? "";

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFB7F43B),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : "?",
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    Text(
                      "🔥 ${item["calories"] ?? 0} | 💪 ${item["protein"] ?? 0}g | 🍞 ${item["carbs"] ?? 0}g",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: selectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    selectionMode = false;
                    selectedItems.clear();
                  });
                },
              )
            : const BackButton(color: Colors.white),
        title: Text(
          selectionMode
              ? "${selectedItems.length} Selected"
              : "History",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          if (selectionMode)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: deleteSelected,
            )
          else
            PopupMenuButton(
              onSelected: (value) {
                if (value == "select") {
                  setState(() => selectionMode = true);
                } else if (value == "delete_all") {
                  confirmDeleteAll();
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: "select", child: Text("Select")),
                PopupMenuItem(
                  value: "delete_all",
                  child: Text("Delete All",
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFC6F432),
          labelColor: const Color(0xFFC6F432),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "Workout"),
            Tab(text: "Food"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [buildWorkoutHistory(), buildMealHistory()],
      ),
    );
  }
}