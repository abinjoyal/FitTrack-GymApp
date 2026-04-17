import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class WorkoutProvider extends ChangeNotifier {

  final supabase = Supabase.instance.client;

  /// FORMAT DATE
  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// ADD WORKOUT
  Future<void> addWorkout(Map<String, dynamic> data) async {

    final user = supabase.auth.currentUser;

    if (user == null) return;

    data["user_id"] = user.id; // ✅ important

    await supabase
        .from("workouts")
        .insert(data);

    notifyListeners();
  }

  /// GET WORKOUTS BY DATE
  Future<List<Map<String, dynamic>>> getWorkouts(DateTime date) async {

    final user = supabase.auth.currentUser;

    if (user == null) return [];

    final formattedDate = formatDate(date);

    final data = await supabase
        .from("workouts")
        .select()
        .eq("user_id", user.id) // ✅ filter user
        .eq("workout_date", formattedDate)
        .order("created_at", ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  /// SAVE WORKOUT HISTORY
  Future<void> saveWorkoutHistory(Map<String, dynamic> data) async {

    final user = supabase.auth.currentUser;

    if (user == null) return;

    data["user_id"] = user.id; // ✅ important

    await supabase
        .from("workout_history")
        .insert(data);

    notifyListeners();
  }

  /// GET HISTORY BY EXERCISE NAME
  Future<List<Map<String, dynamic>>> getWorkoutHistory(String exerciseName) async {

    final user = supabase.auth.currentUser;

    if (user == null) return [];

    final data = await supabase
        .from("workout_history")
        .select()
        .eq("user_id", user.id) // ✅ filter user
        .eq("name", exerciseName)
        .order("date", ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }
}