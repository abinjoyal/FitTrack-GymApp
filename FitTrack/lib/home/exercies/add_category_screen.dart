import 'package:fit_track/thems/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class AddCategoryScreen extends StatefulWidget {
  final bool isNutrition;
  final DateTime selectedDate;

  const AddCategoryScreen({
    super.key,
    required this.isNutrition,
    required this.selectedDate,
  });

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  late List<Map<String, dynamic>> categories;

  String searchText = "";
  Map<String, dynamic>? selectedCategory;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    categories = [
      {"title": "Chest", "icon": Icons.fitness_center},
      {"title": "Back", "icon": Icons.accessibility_new},
      {"title": "Shoulders", "icon": Icons.accessibility},
      {"title": "Biceps", "icon": Icons.sports_gymnastics},
      {"title": "Triceps", "icon": Icons.sports_mma},
      {"title": "Legs", "icon": Icons.directions_run},
      {"title": "Abs", "icon": Icons.self_improvement},
      {"title": "Cardio", "icon": Icons.favorite},
      {"title": "HIIT", "icon": Icons.flash_on},
      {"title": "Yoga", "icon": Icons.self_improvement},
    ];

    /// 🔥 STATUS BAR FIX
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  bool isFutureDate() {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    final selectedOnly = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
    );

    return selectedOnly.isAfter(todayOnly);
  }

  Future<void> saveCategory() async {
    if (selectedCategory == null) return;

    setState(() => isLoading = true);

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    final formattedDate = DateFormat('yyyy-MM-dd').format(widget.selectedDate);

    try {
      final existing = await supabase
          .from("exercise_categories")
          .select()
          .eq("user_id", user.id)
          .eq("title", selectedCategory!["title"])
          .eq("date", formattedDate);

      if (existing.isNotEmpty) {
        setState(() => isLoading = false);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Already added")));
        return;
      }

      final iconCode = (selectedCategory!["icon"] as IconData).codePoint;

      final now = DateTime.now().toIso8601String();

      await supabase.from("exercise_categories").insert({
        "user_id": user.id,
        "title": selectedCategory!["title"],
        "icon": iconCode,
        "date": formattedDate,
        "created_at": now,
      });

      setState(() => isLoading = false);

      Navigator.pop(context, {
        "title": selectedCategory!["title"],
        "icon": iconCode,
        "date": formattedDate,
        "created_at": now,
      });
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    final filtered = categories.where((cat) {
      return cat["title"].toLowerCase().contains(searchText.toLowerCase());
    }).toList();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1C2E05), Color(0xFF0F1A02), Colors.black],
          stops: [0.0, 0.5, 1.0],
        ),
      ),

      child: Scaffold(
        backgroundColor: Colors.transparent,

        /// 🔥 APPBAR
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          title: const Text(
            "Add Category",
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),

        /// 🔥 BODY
        body: Column(
          children: [
            /// PREVIEW
            Container(
              height: size.height * 0.12,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.glass,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: selectedCategory == null
                    ? const Text(
                        "Select Category",
                        style: TextStyle(color: AppColors.textSecondary),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            selectedCategory!["icon"],
                            size: 40,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            selectedCategory!["title"],
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            /// SEARCH
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (v) => setState(() => searchText = v),
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: "Search...",
                  hintStyle: const TextStyle(color: AppColors.hint),
                  filled: true,
                  fillColor: AppColors.glass,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// LIST
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(
                  context,
                ).copyWith(overscroll: false),
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final cat = filtered[i];
                    final isSelected =
                        selectedCategory?["title"] == cat["title"];

                    return GestureDetector(
                      onTap: () => setState(() => selectedCategory = cat),
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              cat["icon"],
                              color: isSelected
                                  ? Colors.black
                                  : AppColors.textPrimary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              cat["title"],
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.black
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),

        /// 🔥 BUTTON
        bottomNavigationBar: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: (selectedCategory == null || isFutureDate() || isLoading)
                ? null
                : saveCategory,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Color(0xFFD0FD3E))
                : const Text(
                    "Save",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
