import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class NutritionProvider extends ChangeNotifier {

  final supabase = Supabase.instance.client;

  /// DATE FORMAT
  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// ADD MEAL → SAVE TO SUPABASE
  Future<void> addMeal(Map<String, dynamic> meal, DateTime date) async {

    final user = supabase.auth.currentUser;

    if (user == null) return;

    final formattedDate = formatDate(date);

    try {

      /// SAVE TO DAILY NUTRITION TABLE
      await supabase.from('meals').insert({
        "user_id": user.id, // ✅ important
        "name": meal["name"],
        "calories": meal["calories"],
        "protein": meal["protein"],
        "carbs": meal["carbs"],
        "description": meal["description"],
        "image": meal["image"],
        "meal_date": formattedDate
      });

      /// SAVE TO HISTORY TABLE
      await supabase.from('meal_history').insert({
        "user_id": user.id, // ✅ important
        "name": meal["name"],
        "calories": meal["calories"],
        "protein": meal["protein"],
        "carbs": meal["carbs"],
        "image": meal["image"],
        "date": DateTime.now().toIso8601String()
      });

      notifyListeners();

    } catch (e) {
      debugPrint("Add meal error: $e");
    }
  }

  /// GET MEALS BY DATE
  Future<List<Map<String, dynamic>>> getMealsByDate(DateTime date) async {

    final user = supabase.auth.currentUser;

    if (user == null) return [];

    final formattedDate = formatDate(date);

    try {

      final data = await supabase
          .from('meals')
          .select()
          .eq('user_id', user.id) // ✅ filter user
          .eq('meal_date', formattedDate)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(data);

    } catch (e) {

      debugPrint("Fetch meals error: $e");
      return [];

    }
  }

  /// CALCULATE TOTAL
  int calculateTotal(List meals, String keyName) {

    int total = 0;

    for (var meal in meals) {
      total += int.tryParse(meal[keyName]?.toString() ?? "0") ?? 0;
    }

    return total;
  }

  /// DAILY TOTALS
  Future<Map<String, int>> dailyTotals(DateTime date) async {

    final meals = await getMealsByDate(date);

    return {
      "calories": calculateTotal(meals, "calories"),
      "protein": calculateTotal(meals, "protein"),
      "carbs": calculateTotal(meals, "carbs"),
    };
  }

  /// MONTHLY TOTALS
  Future<Map<String, int>> monthlyTotals(DateTime date) async {

    final user = supabase.auth.currentUser;

    if (user == null) {
      return {"calories": 0, "protein": 0, "carbs": 0};
    }

    final start = DateTime(date.year, date.month, 1);
    final end = DateTime(date.year, date.month + 1, 0);

    try {

      final data = await supabase
          .from('meals')
          .select()
          .eq('user_id', user.id) // ✅ filter user
          .gte('meal_date', formatDate(start))
          .lte('meal_date', formatDate(end));

      final meals = List<Map<String, dynamic>>.from(data);

      return {
        "calories": calculateTotal(meals, "calories"),
        "protein": calculateTotal(meals, "protein"),
        "carbs": calculateTotal(meals, "carbs"),
      };

    } catch (e) {

      debugPrint("Monthly total error: $e");

      return {
        "calories": 0,
        "protein": 0,
        "carbs": 0,
      };
    }
  }

  /// YEARLY TOTALS
  Future<Map<String, int>> yearlyTotals(DateTime date) async {

    final user = supabase.auth.currentUser;

    if (user == null) {
      return {"calories": 0, "protein": 0, "carbs": 0};
    }

    final start = DateTime(date.year, 1, 1);
    final end = DateTime(date.year, 12, 31);

    try {

      final data = await supabase
          .from('meals')
          .select()
          .eq('user_id', user.id) // ✅ filter user
          .gte('meal_date', formatDate(start))
          .lte('meal_date', formatDate(end));

      final meals = List<Map<String, dynamic>>.from(data);

      return {
        "calories": calculateTotal(meals, "calories"),
        "protein": calculateTotal(meals, "protein"),
        "carbs": calculateTotal(meals, "carbs"),
      };

    } catch (e) {

      debugPrint("Year total error: $e");

      return {
        "calories": 0,
        "protein": 0,
        "carbs": 0,
      };
    }
  }
}