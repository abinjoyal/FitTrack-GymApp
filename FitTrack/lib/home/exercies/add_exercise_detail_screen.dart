import 'dart:io';
import 'package:fit_track/thems/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class AddExerciseDetailScreen extends StatefulWidget {
  const AddExerciseDetailScreen({
    super.key,
    required this.exercise,
    this.initialMuscle,
    required this.selectedDate,
  });

  final Map<String, dynamic>? exercise;
  final String? initialMuscle;
  final DateTime selectedDate;

  @override
  State<AddExerciseDetailScreen> createState() =>
      _AddExerciseDetailScreenState();
}

class _AddExerciseDetailScreenState
    extends State<AddExerciseDetailScreen> {
  final supabase = Supabase.instance.client;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController =
      TextEditingController();

  List<String> addedBreakTimes = [];
  List<String> presetBreakTimes = ["30 sec", "45 sec", "60 sec", "90 sec"];

  File? selectedImage;
  String? selectedMuscle;

  bool isSaving = false;

  final Color primaryColor = const Color(0xFFB6FF00);

  /// ===============================
  /// PICK IMAGE
  /// ===============================
  Future<void> pickImage() async {
    final image =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  /// ===============================
  /// UPLOAD IMAGE
  /// ===============================
  Future<String> uploadImage() async {
    if (selectedImage == null) return "";

    final fileName =
        "exercise_${DateTime.now().millisecondsSinceEpoch}.jpg";

    await supabase.storage
        .from("exercise_images")
        .upload("images/$fileName", selectedImage!);

    return supabase.storage
        .from("exercise_images")
        .getPublicUrl("images/$fileName");
  }

  /// ===============================
  /// INIT
  /// ===============================
  @override
  void initState() {
    super.initState();

    selectedMuscle = widget.initialMuscle ?? "General";

    if (widget.exercise != null) {
      nameController.text = widget.exercise!["name"] ?? "";
      descriptionController.text =
          widget.exercise!["description"] ?? "";

      addedBreakTimes =
          List<String>.from(widget.exercise!["break_time"] ?? []);
    }
  }

  /// ===============================
  /// INPUT STYLE
  /// ===============================
  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: const Color.fromARGB(255, 35, 57, 6),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white24),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  /// ===============================
  /// CHIP
  /// ===============================
  Widget buildChip(String text) {
    return Container(
      margin: const EdgeInsets.only(right: 10, bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: const TextStyle(color: Colors.white)),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: () {
              setState(() {
                addedBreakTimes.remove(text);
              });
            },
            child:
                const Icon(Icons.close, size: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  /// ===============================
  /// SAVE EXERCISE (FINAL FIX 🔥)
  /// ===============================
  Future<void> saveExercise() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter exercise name")),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      final imageUrl = await uploadImage();

      final newExercise = {
        "user_id": user.id,
        "name": nameController.text.trim(),
        "description": descriptionController.text.trim(),
        "break_time": addedBreakTimes,
        "image": imageUrl,
        "category": selectedMuscle ?? "General",
        "workout_date":
            DateFormat('yyyy-MM-dd').format(widget.selectedDate),
        "created_at": DateTime.now().toIso8601String(),
      };

      /// ✅ INSERT DB
      await supabase.from("exercises").insert(newExercise);

      /// 🔥 JUST CLOSE (REALTIME WILL UPDATE UI)
      if (!mounted) return;
      Navigator.pop(context);

    } catch (e) {
      debugPrint("Save error: $e");

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save")),
      );
    }

    if (mounted) {
      setState(() => isSaving = false);
    }
  }

  /// ===============================
  /// UI
  /// ===============================
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1C2E05), Colors.black],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          title: Text(
            widget.initialMuscle ?? "Add Exercise",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        body: SingleChildScrollView(
          padding: EdgeInsets.all(size.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// IMAGE
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: size.height * 0.20,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 35, 57, 6),
                    border: Border.all(color: Colors.white24),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: selectedImage == null
                      ? const Center(
                          child: Text("Upload Image",
                              style: TextStyle(color: Colors.grey)),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.file(selectedImage!,
                              fit: BoxFit.cover),
                        ),
                ),
              ),

              SizedBox(height: size.height * 0.02),

              /// NAME
              const Text("Name", style: TextStyle(color: Colors.white)),
              const SizedBox(height: 8),

              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: inputDecoration("Exercise name"),
              ),

              SizedBox(height: size.height * 0.02),

              /// DESCRIPTION
              const Text("Description",
                  style: TextStyle(color: Colors.white)),
              const SizedBox(height: 8),

              TextField(
                controller: descriptionController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: inputDecoration("Description"),
              ),

              SizedBox(height: size.height * 0.02),

              /// BREAK TIME
              const Text("Break Time",
                  style: TextStyle(color: Colors.white)),

              const SizedBox(height: 10),

              Wrap(
                children:
                    addedBreakTimes.map((e) => buildChip(e)).toList(),
              ),

              const SizedBox(height: 10),

              Wrap(
                children: presetBreakTimes.map((time) {
                  return GestureDetector(
                    onTap: () {
                      if (!addedBreakTimes.contains(time)) {
                        setState(() {
                          addedBreakTimes.add(time);
                        });
                      }
                    },
                    child: Container(
                      margin:
                          const EdgeInsets.only(right: 10, bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: primaryColor),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(time,
                          style: TextStyle(color: primaryColor)),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),

              /// SAVE BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: isSaving ? null : saveExercise,
                  child: isSaving
                      ? const CircularProgressIndicator(
                          color: Colors.black)
                      : const Text("Save",
                          style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}