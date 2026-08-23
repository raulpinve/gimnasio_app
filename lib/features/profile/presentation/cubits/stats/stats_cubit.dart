import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/features/profile/domain/repos/stat_repo.dart';
import 'package:gym_app/features/profile/presentation/cubits/stats/stat_state.dart';

class StatsCubit extends Cubit<StatState> {
  final StatRepo statRepo;

  StatsCubit({required this.statRepo}) : super(StatsInitial());

  Future<void> loadStats() async {
    try {
      emit(StatsLoading());

      final response = await statRepo.getStat();

      if (isClosed) return;

      emit(StatsLoaded(stats: response));
    } catch (e) {
      if (isClosed) return;
      emit(StatsError(e.toString()));
    }
  }
}
