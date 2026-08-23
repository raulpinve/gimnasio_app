import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/features/auth/domain/entities/app_user.dart';
import 'package:gym_app/features/auth/domain/repos/auth_repo.dart';
import 'package:gym_app/features/auth/presentation/cubits/auth_states.dart';

// class AuthCubit extends Cubit<AuthState>: significa que AuthCubit hereda de Cubit y manejará estados de tipo AuthState.
// este Cubit solo puede emitir estados de tipo AuthState.
class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;
  AppUser? _currentUser;

  AuthCubit({required this.authRepo}) : super(AuthInitial());

  // Get current user
  AppUser? get currentUser => _currentUser;

  // Update current user
  void updateCurrentUser(AppUser updatedUser) {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(
      firstName: updatedUser.firstName,
      lastName: updatedUser.lastName,
    );

    emit(Authenticated(_currentUser!));
  }

  Future<void> checkAuth() async {
    emit(AuthChecking());

    try {
      final AppUser? user = await authRepo.getCurrentUser();

      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unanthenticated());
      }
    } catch (e) {
      emit(Unanthenticated());
    }
  }

  // Login with email + pw
  Future<void> login(String email, String pw) async {
    try {
      emit(AuthLoading());
      final user = await authRepo.loginWithEmailPassword(email, pw);
      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      }
    } catch (e) {
      final message = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : e.toString();

      emit(AuthError(message));
    }
  }

  // Register with email + pw
  Future<void> register(
    String name,
    String email,
    String pw,
  ) async {
    try {
      emit(AuthLoading());
      final user = await authRepo.registerWithEmailPassword(
        name,
        email,
        pw,
      );

      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      }
    } catch (e) {
      final message = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : e.toString();

      emit(AuthError(message));
    }
  }

  // Logout
  Future<void> logout() async {
    emit(AuthLoading());
    await authRepo.logout();
    emit(Unanthenticated());
  }

  // Forgot pw
  Future<String> forgotPassword(String email) async {
    try {
      final message = await authRepo.sendPasswordResetEmail(email);
      return message;
    } catch (e) {
      return e.toString();
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      emit(AuthLoading());
      await authRepo.deleteAccount();
      emit(Unanthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unanthenticated());
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      emit(AuthLoading());

      final user = await authRepo.signInWithGoogle();

      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unanthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unanthenticated());
    }
  }
}
