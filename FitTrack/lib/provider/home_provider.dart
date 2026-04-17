import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class HomeProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  /// ===============================
  /// 🔥 PROFILE DATA
  /// ===============================
  String name = '';
  String email = '';
  String phone = '';
  String imageUrl = '';


   HomeProvider() {
    loadProfile(); // 🔥 AUTO LOAD
  }

  /// ===============================
  /// 🔥 WORKOUT STATE
  /// ===============================
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;

  String? selectedWorkoutName;
  String selectedExerciseCategory = "default";

  Map<String, List<Map<String, dynamic>>> workoutExercises = {};

  List<Map<String, dynamic>> exerciseCategories = [
    {"icon": Icons.add_circle_outline, "title": "Add"},
  ];

  /// ===============================
  /// 🔥 HISTORY
  /// ===============================
  Map<String, List<Map<String, dynamic>>> historyMap = {};

  /// ===============================
  /// 🔥 CONSTRUCTOR
  /// ===============================
 Future<void> loadProfile() async {
  final user = supabase.auth.currentUser;
  if (user == null) return;

  try {
    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    /// ✅ IF PROFILE EXISTS
    if (data != null) {
      name = data['name'] ?? '';
      email = data['email'] ?? user.email ?? '';
      phone = data['phone'] ?? '';
      imageUrl = data['image_url'] ?? '';
    } else {
      /// 🔥 IF NO PROFILE → LOAD FROM AUTH
      name = user.userMetadata?['name'] ?? '';
      email = user.email ?? '';
      phone = '';
      imageUrl = '';
    }

    notifyListeners();
  } catch (e) {
    debugPrint("❌ Load Profile Error: $e");
  }
}
Future<void> updateProfile({
  required String name,
  required String email,
  required String phone,
  String? imageUrl,
}) async {
  final user = supabase.auth.currentUser;
  if (user == null) return;

  try {
    /// 🔐 1. UPDATE AUTH EMAIL
    if (user.email != email) {
      await supabase.auth.updateUser(
        UserAttributes(email: email),
      );
    }

    /// 💾 2. UPDATE PROFILES TABLE
   await supabase.from('profiles').upsert({
  'id': user.id,
  'name': name,
  'email': email,
  'phone': phone,
  'image_url': imageUrl ?? '',
  'updated_at': DateTime.now().toIso8601String(),
}, onConflict: 'id');

    /// 🔄 LOCAL UPDATE
    this.name = name;
    this.email = email;
    this.phone = phone;
    if (imageUrl != null) this.imageUrl = imageUrl;

    notifyListeners();

    print("✅ Profile Updated");
  } catch (e) {
    debugPrint("❌ Update Error: $e");
  }
}



  String get profileImage =>
      imageUrl.isNotEmpty
          ? imageUrl
          : "https://via.placeholder.com/150";

  /// ===============================
  /// 🔥 LOGOUT
  /// ===============================
  Future<void> logout(BuildContext context) async {
  try {
    await supabase.auth.signOut();

    workoutExercises.clear();
    exerciseCategories.clear();
    historyMap.clear();

    notifyListeners();

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );

    print("✅ Logged out");
  } catch (e) {
    debugPrint("❌ Logout Error: $e");
  }
}

  /// ===============================
  /// 🔥 HISTORY METHODS
  /// ===============================
  String normalize(String text) => text.trim().toLowerCase();

  Future<void> addHistory(String name, Map<String, dynamic> data) async {
    final key = normalize(name);
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      await supabase.from("exercise_history").insert({
        "user_id": user.id,
        "exercise_name": key,
        "sets": data["sets"],
        "weight": data["weight"],
        "created_at": DateTime.now().toIso8601String(),
      });

      historyMap.putIfAbsent(key, () => []);
      historyMap[key]!.insert(0, {...data, "date": DateTime.now()});

      notifyListeners();
      print("✅ HISTORY SAVED");
    } catch (e) {
      debugPrint("❌ History Save Error: $e");
    }
  }

  Future<void> loadHistory() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await supabase
          .from("exercise_history")
          .select()
          .eq("user_id", user.id)
          .order("created_at", ascending: false);

      Map<String, List<Map<String, dynamic>>> tempMap = {};

      for (var item in data) {
        final key = item["exercise_name"];

        tempMap.putIfAbsent(key, () => []);
        tempMap[key]!.add({
          "sets": item["sets"],
          "weight": item["weight"],
          "date": DateTime.parse(item["created_at"]),
        });
      }

      historyMap = tempMap;
      notifyListeners();
      print("✅ HISTORY LOADED");
    } catch (e) {
      debugPrint("❌ Load History Error: $e");
    }
  }

  /// ===============================
  /// 🔥 EXERCISES
  /// ===============================
  Future<void> loadExercises() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      isLoading = true;
      notifyListeners();

      final date = DateFormat('yyyy-MM-dd').format(selectedDate);

      final data = await supabase
          .from("exercises")
          .select()
          .eq("user_id", user.id)
          .eq("workout_date", date);

      Map<String, List<Map<String, dynamic>>> grouped = {};

      for (var e in data) {
        final exercise = {
          "name": e["name"] ?? "",
          "muscle": (e["muscle"] ?? e["category"] ?? "General").toString(),
          "description": e["description"] ?? "",
          "time": (e["duration"] ?? 600) ~/ 60,
          "videoUrl": e["video_url"] ?? "",
        };

        String category = (e["category"] ?? "General").toString().trim();

        grouped.putIfAbsent(category, () => []).add(exercise);
      }

      workoutExercises = grouped;

      if (selectedWorkoutName == null && workoutExercises.isNotEmpty) {
        selectedWorkoutName = workoutExercises.keys.first;
      }
    } catch (e) {
      debugPrint("❌ Load Exercise Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    final data = await supabase
        .from("exercise_categories")
        .select()
        .eq("user_id", user.id)
        .eq("date", formattedDate)
        .order('created_at', ascending: false);

    exerciseCategories = [
      ...List<Map<String, dynamic>>.from(data)
          .map((e) => {"title": e["title"], "icon": "💪"}),
      {"icon": Icons.add_circle_outline, "title": "Add"},
    ];

    notifyListeners();
  }

  void listenRealtime() {
    supabase
        .channel('exercise_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'exercises',
          callback: (_) {
            loadExercises();
          },
        )
        .subscribe();
  }

  void changeDate(DateTime date) {
    selectedDate = date;
    loadExercises();
    loadCategories();
  }

  void selectWorkout(String workout) {
    selectedWorkoutName = workout.trim();
    selectedExerciseCategory = workout.trim();
    notifyListeners();
  }

  void addCategory(Map<String, dynamic> newCategory) {
    final newTitle = newCategory["title"].toString().trim().toLowerCase();

    exerciseCategories.removeWhere(
      (e) => e["title"].toString().toLowerCase() == newTitle,
    );

    exerciseCategories.removeWhere((e) => e["title"] == "Add");

    exerciseCategories.insert(0, {
      "title": newCategory["title"],
      "icon": newCategory["icon"] ?? "💪",
    });

    exerciseCategories.add({"icon": Icons.add_circle_outline, "title": "Add"});

    notifyListeners();
  }

  Future<void> addExercise(Map<String, dynamic> exercise) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final date = DateFormat('yyyy-MM-dd').format(selectedDate);

    final newExercise = {
      ...exercise,
      "user_id": user.id,
      "workout_date": date,
      "category": selectedWorkoutName ?? "General",
    };

    try {
      await supabase.from("exercises").insert(newExercise);

      final category = selectedWorkoutName ?? "General";

      workoutExercises.putIfAbsent(category, () => []);
      workoutExercises[category]!.insert(0, newExercise);

      notifyListeners();
    } catch (e) {
      debugPrint("❌ Insert Error: $e");
    }
  }

  bool isToday(DateTime date) {
    final now = DateTime.now();
    return now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
  }

  bool isFuture(DateTime date) {
    final today = DateTime.now();

    final onlyToday = DateTime(today.year, today.month, today.day);
    final onlyDate = DateTime(date.year, date.month, date.day);

    return onlyDate.isAfter(onlyToday);
  }

  /// 🔥 YOUTUBE HELPER
  String extractYoutubeId(String url) {
    if (url.isEmpty) return "";

    final uri = Uri.parse(url);

    if (uri.host.contains("youtu.be")) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : "";
    }

    if (uri.queryParameters.containsKey("v")) {
      return uri.queryParameters["v"] ?? "";
    }

    return "";
  }
}