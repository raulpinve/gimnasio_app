import 'package:gym_app/features/auth/domain/entities/app_user.dart';

abstract class UserRepo {
  Future<AppUser> getCurrentUser();
  Future<void> createCurrentUser({
    required String firstName,
    required String lastName,
    required String username,
  });
}
