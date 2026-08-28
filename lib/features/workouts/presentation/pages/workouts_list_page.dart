import 'package:gym_app/core/widgets/refreshable_content.dart';
import 'package:gym_app/features/workouts/presentation/cubits/workout_list/workout_list_cubit.dart';
import 'package:gym_app/features/workouts/presentation/cubits/workout_list/workout_list_state.dart';
import 'package:gym_app/features/workouts/data/api_workout_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:gym_app/features/workouts/presentation/widgets/recent_workout_card.dart';
import 'package:shimmer/shimmer.dart';

class WorkoutsListPage extends StatefulWidget {
  const WorkoutsListPage({super.key});
  @override
  State<WorkoutsListPage> createState() => _WorkoutsListPageState();
}

class _WorkoutsListPageState extends State<WorkoutsListPage> {
  final apiWorkoutRepo = ApiWorkoutRepo();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
    context.read<WorkoutListCubit>().loadWorkouts();
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
    await context.read<WorkoutListCubit>().loadWorkouts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ultimos workouts'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
                        child: Text(
                          'No se encontraron entrenamientos',
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: ListView.separated(
                        controller: _scrollController,
                        separatorBuilder: (BuildContext context, int index) {
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
                          return recentWorkoutCard(context, workout: workout);
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
