import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/features/exercise/data/api_exercise_repo.dart';
import 'package:gym_app/features/exercise/presentation/cubits/exercise_list_cubit.dart';
import 'package:gym_app/features/exercise/presentation/pages/exercises_list_page.dart';
import 'package:gym_app/features/routines/data/api_routine_repo.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine_list_cubit.dart';
import 'package:gym_app/features/routines/presentation/pages/routine_list_page.dart';
import 'package:gym_app/features/workouts/data/api_workout_repo.dart';
import 'package:gym_app/features/workouts/presentation/cubits/workout_list/workout_list_cubit.dart';
import 'package:gym_app/features/workouts/presentation/pages/workouts_list_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;

  final pages = [
    ExercisesListPage(),
    RoutineListPage(),
    WorkoutsListPage(),
    Center(
      child: Text("Perfil"),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ExerciseListCubit(
            exerciseRepo: ApiExerciseRepo(),
          )..loadExercises(),
        ),
        BlocProvider(
          create: (_) => WorkoutListCubit(
            workoutRepo: ApiWorkoutRepo(),
          )..loadWorkouts(),
        ),
        BlocProvider(
          create: (_) => RoutineListCubit(
            routineRepo: ApiRoutineRepo(),
          )..loadRoutines(),
        ),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: pages,
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 12,
              top: 10,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30.0),
              child: MediaQuery.removePadding(
                context: context,
                removeBottom: true,
                child: SizedBox(
                  height: 75,
                  child: BottomNavigationBar(
                    elevation: 0,
                    currentIndex: currentIndex,
                    selectedItemColor: Theme.of(context).colorScheme.primary,
                    unselectedItemColor: Colors.grey.shade400,
                    backgroundColor: Colors.transparent,
                    type: BottomNavigationBarType.shifting,
                    selectedFontSize: 11,
                    unselectedFontSize: 11,
                    selectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      // letterSpacing: 0.2,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                    onTap: (index) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(
                          currentIndex == 0
                              ? Icons.fitness_center
                              : Icons.fitness_center_outlined,
                        ),
                        label: 'Ejercicios',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(
                          currentIndex == 1
                              ? Icons.checklist_rounded
                              : Icons.checklist_rtl_rounded,
                        ),
                        label: 'Rutinas',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(
                          currentIndex == 2
                              ? Icons.local_fire_department
                              : Icons.local_fire_department_outlined,
                        ),
                        label: 'Workouts',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(
                          currentIndex == 3
                              ? Icons.person
                              : Icons.person_outline,
                        ),
                        label: 'Perfil',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
