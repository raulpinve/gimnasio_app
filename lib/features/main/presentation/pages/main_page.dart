import 'package:gym_app/features/workouts/presentation/cubits/create_workout/workout_create_cubit.dart';
import 'package:gym_app/features/workouts/presentation/cubits/workout_list/workout_list_cubit.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine_list/routine_list_cubit.dart';
import 'package:gym_app/features/exercise/presentation/cubits/exercise_list_cubit.dart';
import 'package:gym_app/features/routines/presentation/pages/routine_list_page.dart';
import 'package:gym_app/features/profile/presentation/cubits/stats/stats_cubit.dart';
import 'package:gym_app/features/profile/presentation/pages/profile_page.dart';
import 'package:gym_app/features/exercise/data/api_exercise_repo.dart';
import 'package:gym_app/features/workouts/data/api_workout_repo.dart';
import 'package:gym_app/features/routines/data/api_routine_repo.dart';
import 'package:gym_app/features/profile/data/api_stat_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:gym_app/features/workouts/presentation/pages/workouts_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;

  final pages = [
    // ExercisesListPage(),
    RoutineListPage(),
    WorkoutsPage(),
    ProfilePage(),
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
        BlocProvider(
          create: (_) => StatsCubit(
            statRepo: ApiStatRepo(),
          )..loadStats(),
        ),
        BlocProvider(
          create: (_) => WorkoutCreateCubit(
            workoutRepo: ApiWorkoutRepo(),
          ),
        ),

        BlocProvider(
          create: (_) => WorkoutListCubit(
            workoutRepo: ApiWorkoutRepo(),
          )..loadWorkouts(),
        ),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: pages,
        ),

        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 12,
              top: 10,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: SizedBox(
                  height: 80,
                  child: BottomNavigationBar(
                    elevation: 0,
                    currentIndex: currentIndex,
                    selectedItemColor: Theme.of(context).colorScheme.primary,
                    unselectedItemColor: Colors.grey.shade400,
                    backgroundColor: Colors.transparent,
                    type: BottomNavigationBarType.fixed,
                    showSelectedLabels: true,
                    showUnselectedLabels: false,
                    selectedFontSize: 11,
                    unselectedFontSize: 11,
                    selectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    onTap: (index) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                    items: [
                      BottomNavigationBarItem(
                        icon: const SizedBox(
                          height: 40,
                          child: Icon(
                            Icons.checklist_rtl_rounded,
                            size: 25,
                          ),
                        ),
                        activeIcon: const SizedBox(
                          height: 40,
                          child: Icon(
                            Icons.checklist_rounded,
                            size: 25,
                          ),
                        ),
                        label: 'Rutinas',
                      ),
                      BottomNavigationBarItem(
                        icon: SizedBox(
                          height: 40,
                          child: Center(
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.local_fire_department_outlined,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ),
                        ),
                        activeIcon: SizedBox(
                          height: 40,
                          child: Center(
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.local_fire_department,
                                color: Colors.white,
                                size: 27,
                              ),
                            ),
                          ),
                        ),
                        label: 'Entrenar',
                      ),
                      BottomNavigationBarItem(
                        icon: const SizedBox(
                          height: 40,
                          child: Icon(
                            Icons.person_outline,
                            size: 25,
                          ),
                        ),
                        activeIcon: const SizedBox(
                          height: 40,
                          child: Icon(
                            Icons.person,
                            size: 25,
                          ),
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
