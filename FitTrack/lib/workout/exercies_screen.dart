import 'package:fit_track/workout/widget/exercise_skeleton.dart';
import 'package:fit_track/workout/workout_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fit_track/workout/widget/exercise_card_widget.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  bool isSearching = false;
  String searchQuery = "";
  String selectedMuscle = "all";

  List<Map<String, dynamic>> exercises = [];
  bool isLoading = true;

  List<String> muscles = ["all"];
  bool isMuscleLoading = true;

  @override
  void initState() {
    super.initState();
    fetchExercises();
    fetchMuscles();
  }

  /// ================= FETCH =================

  Future<void> fetchExercises() async {
    if (!mounted) return;

    setState(() => isLoading = true);

    try {
      final response = await Supabase.instance.client
          .from('workexercises')
          .select();

      List<Map<String, dynamic>> loadedExercises = [];

      for (var e in response) {
        loadedExercises.add({
          "title": e["name"] ?? "",
          "time": e["time"] ?? 0,
          "kcal": e["kcal"] ?? 0,
          "instructions": e["description"] ?? "",
          "muscle": e["muscle"] ?? "other",
          "image": e["image"] ?? "",
          "video_url": e["video_url"] ?? "",
        });
      }

      if (!mounted) return;

      setState(() {
        exercises = loadedExercises;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchMuscles() async {
    try {
      final response = await Supabase.instance.client
          .from('muscle_categories')
          .select('name');

      List<String> data = response.map((e) => e['name'].toString()).toList();

      data.remove("all");
      data.insert(0, "all");

      setState(() {
        muscles = data;
        isMuscleLoading = false;
      });
    } catch (e) {
      setState(() => isMuscleLoading = false);
    }
  }

  /// ================= UI =================

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    final filteredExercises = exercises.where((exercise) {
      final matchesSearch = exercise["title"].toLowerCase().contains(
        searchQuery.toLowerCase(),
      );

      if (selectedMuscle == "all") return matchesSearch;

      final matchesMuscle = exercise["muscle"] == selectedMuscle;

      return matchesSearch && matchesMuscle;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: isSearching
            ? TextField(
                autofocus: true,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size.width * 0.04,
                ),
                decoration: InputDecoration(
                  hintText: "Search exercise...",
                  hintStyle: TextStyle(
                    color: Colors.white54,
                    fontSize: size.width * 0.04,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() => searchQuery = value);
                },
              )
            : Text(
                "Exercises",
                style: TextStyle(
                  fontSize: size.width * 0.05,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              isSearching ? Icons.close : Icons.search,
              color: Colors.white,
              size: size.width * 0.06,
            ),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                searchQuery = "";
              });
            },
          ),
        ],
      ),

      body: isLoading
    ? const FullExerciseSkeleton()
    : Column(
        children: [
          SizedBox(height: size.height * 0.02),

          /// CHIPS
          SizedBox(
            height: size.height * 0.06,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
              itemCount: muscles.length,
              itemBuilder: (context, index) {
                return buildChip(muscles[index], size);
              },
            ),
          ),

          SizedBox(height: size.height * 0.02),

          /// LIST
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.04,
              ),
              itemCount: filteredExercises.length,
              itemBuilder: (context, index) {
                final exercise = filteredExercises[index];

                return GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => WorkoutDetailsScreen(
                          title: exercise["title"],
                          muscle: exercise["muscle"],
                          instructions: exercise["instructions"],
                          timeInMinutes: exercise["time"],
                          videoUrl: exercise["video_url"],
                        ),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );

                    if (result != null && context.mounted) {
                      Navigator.pop(context, result);
                    }
                  },
                  child: ExerciseCardWidget(
                    title: exercise["title"],
                    time: exercise["time"],
                    kcal: exercise["kcal"],
                    instructions: exercise["instructions"],
                    muscle: exercise["muscle"],
                    videoUrl: exercise["video_url"],
                    imageUrl: exercise["image"],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// ================= CHIP =================

  Widget buildChip(String muscle, Size size) {
    final isSelected = selectedMuscle == muscle;

    return GestureDetector(
      onTap: () {
        setState(() => selectedMuscle = muscle);
      },
      child: Container(
        margin: EdgeInsets.only(right: size.width * 0.03),
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD0FD3E) : const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(25),
        ),
        alignment: Alignment.center,
        child: Text(
          muscle.replaceAll("_", " ").toUpperCase(),
          style: TextStyle(
            fontSize: size.width * 0.035,
            color: isSelected ? Colors.black : Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
