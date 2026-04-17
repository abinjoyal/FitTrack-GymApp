import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'history_item_widget.dart';

String formatDuration(int seconds) {
  if (seconds <= 0) return "0 sec";

  int min = seconds ~/ 60;
  int sec = seconds % 60;

  if (min > 0 && sec > 0) {
    return "$min min $sec sec";
  } else if (min > 0) {
    return "$min min";
  } else {
    return "$sec sec";
  }
}

void showHistoryBottomSheet({
  required BuildContext context,
  required String title,
}) {
  final supabase = Supabase.instance.client;

  Set<int> selectedIndexes = {};
  bool isSelectionMode = false;

  List<Map<String, dynamic>> historyList = [];
  bool isLoading = true;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.black,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
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
                  .eq("exercise_name", title)
                  .order("date", ascending: false);

              setModalState(() {
                historyList = List<Map<String, dynamic>>.from(data);
                isLoading = false;
              });
            } catch (e) {
              debugPrint("❌ Load error: $e");
              setModalState(() => isLoading = false);
            }
          }

          /// 🔥 FIRST LOAD
          if (isLoading) {
            loadHistory();
          }

          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.45,
            maxChildSize: 0.45,
            builder: (_, controller) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    /// 🔥 DRAG HANDLE
                    Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    /// 🔥 HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        isSelectionMode
                            ? Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setModalState(() {
                                        selectedIndexes.clear();
                                        isSelectionMode = false;
                                      });
                                    },
                                  ),
                                  Text(
                                    "${selectedIndexes.length} selected",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              )
                            : const Text(
                                "Workout History",
                                style: TextStyle(color: Colors.white),
                              ),

                        if (isSelectionMode)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final ids = selectedIndexes
                                  .map((i) => historyList[i]["id"])
                                  .toList();

                              await supabase
                                  .from("history")
                                  .delete()
                                  .inFilter("id", ids);

                              selectedIndexes.clear();
                              isSelectionMode = false;

                              await loadHistory();
                            },
                          ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    /// 🔥 BODY
                    Expanded(
                      child: isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : historyList.isEmpty
                          ? const Center(
                              child: Text(
                                "No History",
                                style: TextStyle(color: Colors.white54),
                              ),
                            )
                          : ListView.builder(
                              controller: controller,
                              itemCount: historyList.length,
                              itemBuilder: (context, index) {
                                final item = historyList[index];

                                return HistoryItemWidget(
                                  index: index,
                                  name: item["exercise_name"] ?? "",
                                  sets: "${item["sets"] ?? 0} sets",
                                  weight: "${item["weight"] ?? 0} kg",
                                  time: formatDuration(
                                    item["workout_time"] ?? 0,
                                  ),
                                  breakTime: formatDuration(
                                    item["break_rest"] ?? 0,
                                  ),

                                  /// 🔥 FIXED DATE
                                  date: item["date"] != null
                                      ? DateTime.parse(item["date"])
                                      : DateTime.now(),

                                  isSelected: selectedIndexes.contains(index),
                                  isSelectionMode: isSelectionMode,

                                  onLongPress: () {
                                    setModalState(() {
                                      isSelectionMode = true;
                                      selectedIndexes.add(index);
                                    });
                                  },

                                  onTap: () {
                                    if (isSelectionMode) {
                                      setModalState(() {
                                        if (selectedIndexes.contains(index)) {
                                          selectedIndexes.remove(index);
                                        } else {
                                          selectedIndexes.add(index);
                                        }

                                        if (selectedIndexes.isEmpty) {
                                          isSelectionMode = false;
                                        }
                                      });
                                    }
                                  },

                                  onDelete: () async {
                                    await supabase
                                        .from("history")
                                        .delete()
                                        .eq("id", item["id"]);

                                    await loadHistory();
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}
