import 'package:gym_app/features/auth/domain/entities/app_user.dart';

abstract class ProfileRepo {
  Future<AppUser> updateProfile(
    Map<String, dynamic> profileBody,
  );
}
