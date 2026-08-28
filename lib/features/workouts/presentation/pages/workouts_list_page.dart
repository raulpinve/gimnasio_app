import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/features/auth/presentation/components/my_dropdown.dart';
import 'package:shimmer/shimmer.dart';
import 'package:gym_app/core/widgets/refreshable_content.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine_list/routine_list_cubit.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine_list/routine_list_state.dart';
import 'package:gym_app/features/workouts/data/api_workout_repo.dart';
import 'package:gym_app/features/workouts/presentation/cubits/workout_list/workout_list_cubit.dart';
import 'package:gym_app/features/workouts/presentation/cubits/workout_list/workout_list_state.dart';
import 'package:gym_app/features/workouts/presentation/widgets/recent_workout_card.dart';

class WorkoutsListPage extends StatefulWidget {
  const WorkoutsListPage({super.key});

  @override
  State<WorkoutsListPage> createState() => _WorkoutsListPageState();
}

class _WorkoutsListPageState extends State<WorkoutsListPage> {
  final apiWorkoutRepo = ApiWorkoutRepo();
  final ScrollController _scrollController = ScrollController();

  String? _selectedRoutineId;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);

    context.read<WorkoutListCubit>().loadWorkouts();
    context.read<RoutineListCubit>().loadRoutines();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<WorkoutListCubit>().loadMoreWorkouts();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await context.read<WorkoutListCubit>().loadWorkouts(
      routineId: _selectedRoutineId,
    );
  }

  Future<void> _onRoutineChanged(String? routineId) async {
    setState(() {
      _selectedRoutineId = routineId;
    });

    await context.read<WorkoutListCubit>().filterByRoutine(routineId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrenamientos recientes'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: const BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ============================================================
            // FILTRO DE RUTINA
            // ============================================================
            _buildRoutineFilter(),

            const SizedBox(height: 16),

            // ============================================================
            // LISTA DE WORKOUTS
            // ============================================================
            Expanded(
              child: BlocBuilder<WorkoutListCubit, WorkoutListState>(
                builder: (context, state) {
                  // CARGA INICIAL
                  if (state is WorkoutListLoading) {
                    return skeletonLoader(context);
                  }

                  // ERROR DE CARGA
                  if (state is WorkoutListError) {
                    return RefreshableContent(
                      onRefresh: _onRefresh,
                      child: Text(state.message),
                    );
                  }

                  // ENTRENAMIENTOS CARGADOS
                  if (state is WorkoutsListLoaded) {
                    // NO HAY ENTRENAMIENTOS
                    if (state.workouts.isEmpty) {
                      return RefreshableContent(
                        onRefresh: _onRefresh,
                        child: const Text(
                          'No se encontraron entrenamientos',
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: ListView.separated(
                        controller: _scrollController,
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 10);
                        },
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount:
                            state.workouts.length +
                            (state.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          // LOADING DE PAGINACIÓN
                          if (index >= state.workouts.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final workout = state.workouts[index];

                          return recentWorkoutCard(
                            context,
                            workout: workout,
                          );
                        },
                      ),
                    );
                  }

                  return skeletonLoader(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FILTRO DE RUTINA
  // ============================================================
  Widget _buildRoutineFilter() {
    return BlocBuilder<RoutineListCubit, RoutineListState>(
      builder: (context, state) {
        if (state is RoutineListLoading) {
          return const SizedBox(
            height: 56,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is! RoutinesListLoaded) {
          return const SizedBox.shrink();
        }

        return MyDropdown<String?>(
          value: _selectedRoutineId,
          hintText: 'Filtrar por rutina',
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Todas las rutinas'),
            ),

            ...state.routines.map(
              (routine) => DropdownMenuItem<String?>(
                value: routine.id,
                child: Text(routine.name),
              ),
            ),
          ],
          onChanged: _onRoutineChanged,
        );
      },
    );
  }

  // ============================================================
  // SKELETON
  // ============================================================
  Widget skeletonLoader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 12),
      itemCount: 10,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: isDark ? const Color(0xFF232323) : Colors.grey.shade200,
          highlightColor: isDark
              ? const Color(0xFF353535)
              : Colors.grey.shade100,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF232323) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre de la rutina
                  Container(
                    width: double.infinity,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Pills
                  Row(
                    children: [
                      Container(
                        width: 100,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 45,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Botón de eliminar
              trailing: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
