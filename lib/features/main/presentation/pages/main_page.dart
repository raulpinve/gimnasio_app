import 'package:gym_app/features/workouts/presentation/cubits/active_workout/active_workout_cubit.dart';
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
          create: (_) => ActiveWorkoutCubit(
            workoutRepo: ApiWorkoutRepo(),
          )..loadActiveWorkout(),
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
              height: 74,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(28),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavItem(
                    icon: Icons.checklist_rtl_rounded,
                    activeIcon: Icons.checklist_rounded,
                    label: 'Rutinas',
                    isSelected: currentIndex == 0,
                    onTap: () => setState(() => currentIndex = 0),
                  ),
                  _CenterNavItem(
                    isSelected: currentIndex == 1,
                    onTap: () => setState(() => currentIndex = 1),
                  ),
                  _NavItem(
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: 'Perfil',
                    isSelected: currentIndex == 2,
                    onTap: () => setState(() => currentIndex = 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: 44,
              height: 30,
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary.withValues(alpha: 0.16)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(
                isSelected ? activeIcon : icon,
                size: 22,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.45),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterNavItem extends StatefulWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _CenterNavItem({required this.isSelected, required this.onTap});

  @override
  State<_CenterNavItem> createState() => _CenterNavItemState();
}

class _CenterNavItemState extends State<_CenterNavItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: Transform.translate(
        offset: const Offset(0, -10),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          scale: _pressed ? 0.9 : 1.0,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.tertiary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.isSelected
                  ? Icons.local_fire_department
                  : Icons.local_fire_department_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
