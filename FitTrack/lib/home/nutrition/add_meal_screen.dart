import 'dart:io';
import 'dart:ui';
import 'package:fit_track/home/nutrition/widgets/count_weight_toggle.dart';
import 'package:fit_track/home/nutrition/widgets/custom_text_field.dart';
import 'package:fit_track/home/nutrition/widgets/image_picker_box.dart';
import 'package:fit_track/home/nutrition/widgets/macro_row.dart';
import 'package:fit_track/home/nutrition/widgets/meal_dropdown.dart';
import 'package:fit_track/home/nutrition/widgets/mode_toggle.dart';
import 'package:fit_track/services/food_ai_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({super.key});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController caloriesController = TextEditingController();
  final TextEditingController proteinController = TextEditingController();
  final TextEditingController carbsController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  File? selectedImage;
  String? selectedMeal;

  bool isLoading = false;
  bool useAI = false;

  /// COUNT / WEIGHT
  bool isCountMode = true;
  int foodCount = 1;
  double weight = 100;

  /// BASE VALUES (very important)
  int baseCalories = 0;
  int baseProtein = 0;
  int baseCarbs = 0;

  final picker = ImagePicker();
  List detectedFoods = [];

  final List<String> mealTypes = [
    "Breakfast",
    "Morning Snack",
    "Lunch",
    "Evening Snack",
    "Dinner",
    "Dessert",
    "Juice / Drinks",
  ];

  /// UPDATE NUTRITION
  void updateNutrition() {
    /// COUNT MODE
    if (isCountMode) {
      caloriesController.text = (baseCalories * foodCount).toString();
      proteinController.text = (baseProtein * foodCount).toString();
      carbsController.text = (baseCarbs * foodCount).toString();
    }
    /// WEIGHT MODE
    else {
      double currentWeight = double.tryParse(weightController.text) ?? weight;
      double factor = currentWeight / 100;
      caloriesController.text = (baseCalories * factor).round().toString();
      proteinController.text = (baseProtein * factor).round().toString();
      carbsController.text = (baseCarbs * factor).round().toString();
    }
  }

  /// FOOD AI ANALYSIS
  Future<void> analyzeFood(File image) async {
    if (!useAI) return;
    setState(() => isLoading = true);
    final result = await FoodAIService.analyzeFood(image);
    if (result == null) {
      showNoFoodMessage();
      setState(() => isLoading = false);
      return;
    }

    setState(() {
      nameController.text = result["name"];
      baseCalories = result["calories"];
      baseProtein = result["protein"];
      baseCarbs = result["carbs"];
      if (result["foods"] != null) {
        detectedFoods = result["foods"];
      }

      updateNutrition();
      isLoading = false;
    });
  }

  void showNoFoodMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1C1C1E),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 3),
        content: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "Sorry, we couldn't recognize this food. Try another image or use Manual Mode.",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// PICK IMAGE
  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      File imageFile = File(picked.path);

      setState(() {
        selectedImage = imageFile;
      });

      if (useAI) {
        await analyzeFood(imageFile);
      } else {
        /// Manual mode → clear fields for typing
        nameController.clear();
        caloriesController.clear();
        proteinController.clear();
        carbsController.clear();
      }
    }
  }

  /// CAMERA SCAN
  Future<void> scanFoodCamera() async {
    final picked = await picker.pickImage(source: ImageSource.camera);

    if (picked != null) {
      File imageFile = File(picked.path);
      setState(() {
        selectedImage = imageFile;
      });
      if (useAI) {
        await analyzeFood(imageFile);
      } else {
        nameController.clear();
        caloriesController.clear();
        proteinController.clear();
        carbsController.clear();
      }
    }
  }

  /// SAVE MEAL
  Future<void> saveMeal() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter meal name",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Color(0xFFC6F432),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
      return;
    }

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      debugPrint("User not logged in");
      return;
    }

    try {
      Map<String, dynamic> mealData = {
        "user_id": user.id,

        "type": "meal", // 🔥 VERY IMPORTANT

        "name": nameController.text.trim(),

        "description": descriptionController.text,
        "meal_type": selectedMeal ?? "",

        "calories": int.tryParse(caloriesController.text) ?? 0,
        "protein": int.tryParse(proteinController.text) ?? 0,
        "carbs": int.tryParse(carbsController.text) ?? 0,

        "count": foodCount,
        "weight": weight,
        "mode": isCountMode ? "count" : "weigh",

        "image": selectedImage?.path ?? "",

        "date": DateTime.now().toIso8601String(), // 🔥 unified column
      };

      await supabase.from("history").insert(mealData);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Meal Saved 🍔")));

      Navigator.pop(context, mealData);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final height = media.size.height;

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
          title: const Text("Add Meal", style: TextStyle(color: Colors.white)),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(width * 0.05),

              child: Column(
                children: [
                  /// AI MODE / MANUAL MODE
                  ModeToggle(
                    width: width,
                    height: height,
                    useAI: useAI,

                    onManualTap: () {
                      setState(() {
                        useAI = false;

                        isCountMode = true;
                        foodCount = 1;
                        weight = 0;
                        weightController.clear();
                        nameController.clear();
                        descriptionController.clear();
                        baseCalories = 0;
                        baseProtein = 0;
                        baseCarbs = 0;
                        selectedImage = null;
                        detectedFoods.clear();
                        selectedMeal = null;
                      });
                    },

                    onAITap: () {
                      setState(() {
                        useAI = true;

                        selectedImage = null;
                        selectedMeal = null;
                        nameController.clear();
                        caloriesController.clear();
                        proteinController.clear();
                        carbsController.clear();
                        descriptionController.clear();
                        weightController.clear();
                        baseCalories = 0;
                        baseProtein = 0;
                        baseCarbs = 0;
                        foodCount = 1;
                        weight = 0;

                        detectedFoods.clear();
                      });
                    },
                  ),

                  SizedBox(height: height * 0.015),

                  ImagePickerBox(
                    width: width,
                    height: height,
                    selectedImage: selectedImage,

                    onCameraTap: () {
                      scanFoodCamera();
                    },

                    onGalleryTap: () {
                      pickImage();
                    },
                  ),

                  SizedBox(height: height * 0.025),

                  /// MEAL NAME
                  CustomTextField(
                    controller: nameController,
                    hintText: "Meal Name",
                  ),
                  SizedBox(height: height * 0.012),

                  /// COUNT / WEIGHT ONLY IN AI MODE
                  if (useAI && selectedImage != null)
                    CountWeightToggle(
                      width: width,
                      height: height,
                      isCountMode: isCountMode,
                      foodCount: foodCount,
                      weight: weight,
                      weightController: weightController,

                      onCountTap: () {
                        setState(() {
                          isCountMode = true;
                          weightController.clear();
                        });
                      },
                      onWeightTap: () {
                        setState(() {
                          isCountMode = false;
                        });
                      },
                      onIncrement: () {
                        setState(() {
                          foodCount++;
                          updateNutrition();
                        });
                      },
                      onDecrement: () {
                        setState(() {
                          if (foodCount > 1) foodCount--;
                          updateNutrition();
                        });
                      },
                      onWeightChanged: (value) {
                        setState(() {
                          weight = double.tryParse(value) ?? 0;
                          updateNutrition();
                        });
                      },
                    ),

                  SizedBox(height: height * 0.012),

                  /// MACROS
                  MacroRow(
                    width: width,
                    caloriesController: caloriesController,
                    proteinController: proteinController,
                    carbsController: carbsController,
                    useAI: useAI,
                    onChanged: () {
                      setState(() {
                        if (!useAI) {
                          baseCalories =
                              int.tryParse(caloriesController.text) ?? 0;
                          baseProtein =
                              int.tryParse(proteinController.text) ?? 0;
                          baseCarbs = int.tryParse(carbsController.text) ?? 0;
                        }
                      });
                    },
                  ),

                  SizedBox(height: height * 0.018),

                  /// MEAL TYPE
                  MealDropdown(
                    selectedMeal: selectedMeal,
                    mealTypes: mealTypes,
                    onChanged: (value) {
                      setState(() {
                        selectedMeal = value;
                      });
                    },
                  ),
                  SizedBox(height: height * 0.018),

                  /// DESCRIPTION
                  CustomTextField(
                    controller: descriptionController,
                    hintText: "Description",
                    maxLines: 4,
                  ),
                  SizedBox(height: height * 0.018),

                  /// SAVE BUTTON
                  SizedBox(
                    width: width,
                    height: height * 0.065,
                    child: ElevatedButton(
                      onPressed: saveMeal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC6F432),
                      ),
                      child: const Text(
                        "Save",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              Positioned.fill(
                child: Stack(
                  children: [
                    /// 🌫️ BLUR BACKGROUND
                    BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 5,
                        sigmaY: 5,
                      ), // 👈 reduce blur
                      child: Container(
                        color: Colors.black.withOpacity(
                          0.2,
                        ), // 👈 lighter overlay
                      ),
                    ),

                    /// 🤖 ANALYZING UI
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          /// 🔄 GLOW LOADER
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(
                              strokeWidth: 8,
                              color: Color(0xFFC6F432),
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// 🔥 MAIN TEXT
                          const Text(
                            "Analyzing Food...",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),

                          const SizedBox(height: 8),

                          /// 💬 SUB TEXT
                          const Text(
                            "AI is detecting calories & nutrients",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
