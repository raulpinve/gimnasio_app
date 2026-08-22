/* Auth states */

import 'package:gym_app/features/auth/domain/entities/app_user.dart';

abstract class AuthState {}

// Initial
class AuthInitial extends AuthState {}

// Loading
class AuthLoading extends AuthState {}

// Cheking if user is authenticated
class AuthChecking extends AuthState {}

// Authenticated
class Authenticated extends AuthState {
  final AppUser user;
  Authenticated(this.user);
}

// UnAuthenticated
class Unanthenticated extends AuthState {}

// Errors
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
