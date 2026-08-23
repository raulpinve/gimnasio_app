import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/core/errors/api_error_handler.dart';
import 'package:gym_app/features/profile/domain/repos/profile_repo.dart';
import 'package:gym_app/features/profile/presentation/cubits/profile/profile_update_state.dart';

class ProfileUpdateCubit extends Cubit<ProfileUpdateState> {
  final ProfileRepo profileRepo;

  ProfileUpdateCubit({
    required this.profileRepo,
  }) : super(ProfileUpdateState());

  Future<void> updateProfile(
    Map<String, dynamic> profileBody,
  ) async {
    try {
      if (isClosed) return;

      emit(
        state.copyWith(
          isUpdating: true,
          errorMessage: null,
          fieldErrors: null,
        ),
      );

      final updatedUser = await profileRepo.updateProfile(profileBody);

      if (isClosed) return;

      emit(
        state.copyWith(
          isUpdating: false,
          isUpdated: true,
          updatedUser: updatedUser,
        ),
      );
    } on ApiError catch (e) {
      if (isClosed) return;

      emit(
        state.copyWith(
          isUpdating: false,
          errorMessage: e.message,
          fieldErrors: e.fieldErrors,
        ),
      );
    } catch (e) {
      if (isClosed) return;

      emit(
        state.copyWith(
          isUpdating: false,
          errorMessage: 'Ocurrió un error inesperado',
        ),
      );
    }
  }
}
