import 'package:gym_app/features/profile/domain/entities/stats.dart';

abstract class StatState {}

class StatsInitial extends StatState {}

class StatsLoading extends StatState {}

class StatsLoaded extends StatState {
  final Stats stats;
  StatsLoaded({
    required this.stats,
  });
}

class StatsDeleting extends StatState {}

class StatsDeleted extends StatState {}

class StatsError extends StatState {
  final String message;
  final Map<String, dynamic>? fieldErrors;

  StatsError(
    this.message, {
    this.fieldErrors,
  });
}
