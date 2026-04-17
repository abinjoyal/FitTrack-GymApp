import 'package:fit_track/home/exercies/add_exercise_detail_screen.dart';
import 'package:fit_track/home/exercies/widgets/category_controller_widget.dart';
import 'package:fit_track/home/exercies/widgets/exercise_section_widget.dart';
import 'package:fit_track/home/nutrition/nutritionscreen.dart';
import 'package:fit_track/home/widgets/date_widget.dart';
import 'package:fit_track/home/widgets/category_tap_widget.dart';
import 'package:fit_track/home/widgets/header_widget.dart';
import 'package:fit_track/home/widgets/motivation_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/home_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeTab selectedTab = HomeTab.exercise;

  /// 🔥 ADD EXERCISE
  Future<void> addExercise(BuildContext context) async {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);

    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, __) => AddExerciseDetailScreen(
          exercise: null,
          initialMuscle: homeProvider.selectedWorkoutName,
          selectedDate: homeProvider.selectedDate,
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );

    if (result == true) {
      await homeProvider.loadExercises();
    }
  }

  /// 🔥 REFRESH ALL
  Future<void> refreshAll(HomeProvider homeProvider) async {
    await homeProvider.loadExercises();
    await homeProvider.loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);
    final size = MediaQuery.of(context).size;

    /// 🔥 GLOBAL LOADER
    if (homeProvider.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFD0FD3E),
          ),
        ),
      );
    }

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

        body: SafeArea(
          child: RefreshIndicator(
            color: const Color(0xFFD0FD3E),

            /// 🔥 PULL TO REFRESH
            onRefresh: () => refreshAll(homeProvider),

            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.02),

                  /// 🔔 HEADER (NOTIFICATION INCLUDED)
                  const HeaderWidget(),

                  SizedBox(height: size.height * 0.02),

                  /// 📅 DATE
                  DateWidget(
                    selectedDate: homeProvider.selectedDate,
                    onDateSelected: homeProvider.changeDate,
                  ),

                  SizedBox(height: size.height * 0.01),

                  /// 🔥 MOTIVATION
                  const MotivationWidget(),

                  const SizedBox(height: 20),

                  /// 🔄 TAB SWITCH
                  CategoryTapWidget(
                    selectedTab: selectedTab,
                    onTabSelected: (tab) {
                      setState(() => selectedTab = tab);
                    },
                  ),

                  SizedBox(height: size.height * 0.02),

                  /// 🏋️ EXERCISE / 🍎 NUTRITION
                  if (selectedTab == HomeTab.exercise)
                    CategoryControllerWidget(
                      exerciseCategories:
                          homeProvider.exerciseCategories,
                      selectedExerciseCategory:
                          homeProvider.selectedExerciseCategory,
                      onWorkoutSelected:
                          homeProvider.selectWorkout,
                      isToday: homeProvider
                          .isToday(homeProvider.selectedDate),
                      selectedDate: homeProvider.selectedDate,
                    )
                  else
                    Nutritionscreen(
                      nutritionData: const {},
                      onAddPressed: () {},
                      selectedDate: homeProvider.selectedDate,
                    ),

                  SizedBox(height: size.height * 0.02),

                  /// 🏋️ EXERCISE LIST
                  if (!homeProvider
                          .isFuture(homeProvider.selectedDate) &&
                      selectedTab == HomeTab.exercise)
                    ExerciseSectionWidget(
                      selectedWorkoutName:
                          homeProvider.selectedWorkoutName,
                      workoutExercises:
                          homeProvider.workoutExercises,
                      onAddExercise:
                          homeProvider.isToday(
                                  homeProvider.selectedDate)
                              ? () async => await addExercise(context)
                              : () async {},
                      selectedDate: homeProvider.selectedDate,
                      instructions: '',
                    ),

                  const SizedBox(height: 40),
                  // const DraggableChatHead(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}