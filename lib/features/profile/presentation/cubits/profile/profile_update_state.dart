import 'package:gym_app/features/auth/domain/entities/app_user.dart';

class ProfileUpdateState {
  final bool isUpdating;
  final bool isUpdated;
  final AppUser? updatedUser;
  final String? errorMessage;
  final Map<String, dynamic>? fieldErrors;

  const ProfileUpdateState({
    this.isUpdating = false,
    this.isUpdated = false,
    this.updatedUser,
    this.errorMessage,
    this.fieldErrors,
  });

  ProfileUpdateState copyWith({
    bool? isUpdating,
    bool? isUpdated,
    AppUser? updatedUser,
    String? errorMessage,
    Map<String, dynamic>? fieldErrors,
  }) {
    return ProfileUpdateState(
      isUpdating: isUpdating ?? this.isUpdating,
      isUpdated: isUpdated ?? this.isUpdated,
      updatedUser: updatedUser ?? this.updatedUser,
      errorMessage: errorMessage ?? this.errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }
}
