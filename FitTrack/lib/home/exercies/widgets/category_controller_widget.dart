import 'package:fit_track/home/exercies/add_category_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'category_widget.dart';

class CategoryControllerWidget extends StatefulWidget {
  final List<Map<String, dynamic>> exerciseCategories;
  final String selectedExerciseCategory;
  final Function(String) onWorkoutSelected;
  final bool isToday;
  final DateTime selectedDate;

  const CategoryControllerWidget({
    super.key,
    required this.exerciseCategories,
    required this.selectedExerciseCategory,
    required this.onWorkoutSelected,
    required this.isToday,
    required this.selectedDate,
  });

  @override
  State<CategoryControllerWidget> createState() =>
      _CategoryControllerWidgetState();
}

class _CategoryControllerWidgetState extends State<CategoryControllerWidget> {
  final supabase = Supabase.instance.client;

  late String selectedExerciseCategory;

  List<Map<String, dynamic>> dbCategories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    selectedExerciseCategory = widget.selectedExerciseCategory;

    loadCategories();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (selectedExerciseCategory.isNotEmpty) {
        widget.onWorkoutSelected(selectedExerciseCategory);
      }
    });
  }

  /// 🔥 LOAD CATEGORIES (LATEST FIRST FIXED)
  Future<void> loadCategories() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final formattedDate = DateFormat(
        'yyyy-MM-dd',
      ).format(widget.selectedDate);

      final data = await supabase
          .from("exercise_categories")
          .select()
          .eq("user_id", user.id)
          .eq("date", formattedDate)
          .order('created_at', ascending: false); // ✅ FIX

      if (!mounted) return;

      setState(() {
        dbCategories = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Load Error: $e");

      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load categories")),
      );
    }
  }

  /// DATE CHECK
  bool isSameDate(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  /// CATEGORY TAP
  Future<void> _handleCategoryTap(String category) async {
    /// ❌ FUTURE DATE BLOCK
    if (!isSameDate(widget.selectedDate, DateTime.now()) && category == "Add") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can only add workouts for today")),
      );
      return;
    }

    /// ➕ ADD CATEGORY
    if (category == "Add") {
      // ⚠️ IMPORTANT: only return data, DO NOT insert again
      final result = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => AddCategoryScreen(
            isNutrition: false,
            selectedDate: widget.selectedDate,
          ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );

      if (result != null && result is Map<String, dynamic>) {
        /// 🔥 JUST RELOAD (no duplicate insert)
        await loadCategories();

        String newTitle = result["title"];

        setState(() {
          selectedExerciseCategory = newTitle;
        });

        widget.onWorkoutSelected(newTitle);
      }
    }
    /// 🏋️ SELECT CATEGORY
    else {
      setState(() {
        selectedExerciseCategory = category;
      });

      widget.onWorkoutSelected(category);
    }
  }

  /// ICON FIX
  IconData _convertIcon(dynamic iconValue) {
    if (iconValue is int) {
      return IconData(iconValue, fontFamily: 'MaterialIcons');
    }

    if (iconValue is String) {
      int? parsed = int.tryParse(iconValue);
      if (parsed != null) {
        return IconData(parsed, fontFamily: 'MaterialIcons');
      }
    }

    return Icons.fitness_center;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
  child: CircularProgressIndicator(
    color: Color(0xFFD0FD3E),
  ),
);
    }

    /// 🔥 FILTER BY DATE
    final filtered = dbCategories.where((cat) {
      if (cat["date"] == null) return false;

      DateTime savedDate = DateTime.parse(cat["date"]);

      return savedDate.year == widget.selectedDate.year &&
          savedDate.month == widget.selectedDate.month &&
          savedDate.day == widget.selectedDate.day;
    }).toList();

    /// 🔥 ADD BUTTON LAST
    final merged = [
      ...filtered.map(
        (e) => {"title": e["title"], "icon": _convertIcon(e["icon"])},
      ),
      {"title": "Add", "icon": Icons.add_circle_outline},
    ];

    return CategoryWidget(
      categories: merged,
      selectedCategory: selectedExerciseCategory,
      onCategorySelected: _handleCategoryTap,
      isToday: widget.isToday,
    );
  }
}
