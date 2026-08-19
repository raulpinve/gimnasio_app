import 'package:gym_app/features/routines/domain/entities/routine.dart';

abstract class RoutineDetailState {}

// Estado inicial
class RoutineDetailInitial extends RoutineDetailState {}

// Estado para cargar la información de la rutina
class RoutineDetailLoading extends RoutineDetailState {}

// Rutina carga
class RoutineDetailLoaded extends RoutineDetailState {
  final Routine routine;

  RoutineDetailLoaded({
    required this.routine,
  });
}

// Error
class RoutineDetailError extends RoutineDetailState {
  final String message;
  RoutineDetailError(this.message);
}
