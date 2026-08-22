import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gym_app/features/auth/domain/entities/app_user.dart';
import 'package:gym_app/features/auth/domain/repos/auth_repo.dart';
import 'package:gym_app/features/auth/domain/repos/user_repo.dart';

class FirebaseAuthRepo implements AuthRepo {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final UserRepo userRepo;

  String _getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'El correo electrónico no es válido.';

      case 'user-not-found':
        return 'No existe una cuenta con este correo.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'El correo o la contraseña son incorrectos.';

      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo.';

      case 'weak-password':
        return 'La contraseña es demasiado débil.';

      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';

      case 'too-many-requests':
        return 'Demasiados intentos. Inténtalo nuevamente más tarde.';

      case 'operation-not-allowed':
        return 'Este método de autenticación no está habilitado.';

      case 'network-request-failed':
        return 'No se pudo conectar con el servidor. Revisa tu conexión.';

      default:
        return 'No se pudo iniciar sesión. Inténtalo nuevamente.';
    }
  }

  FirebaseAuthRepo({
    required this.userRepo,
  });

  // LOGIN: Email && password
  @override
  Future<AppUser?> loginWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(
            email: email,
            password: password,
          );

      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception("Usuario no existe");
      }

      final String? token = await firebaseUser.getIdToken();

      if (token == null) {
        throw Exception("No se pudo obtener el token");
      }

      final AppUser backendUser = await userRepo.getCurrentUser();

      return AppUser(
        uid: firebaseUser.uid,
        email: backendUser.email,
        token: token,
        firstName: backendUser.firstName,
        lastName: backendUser.lastName,
        username: backendUser.username,
        avatar: backendUser.avatar,
        avatarThumbnail: backendUser.avatarThumbnail,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint("Error al iniciar sesión: ${e.code}");
      throw Exception(_getFirebaseAuthErrorMessage(e));
    } catch (e) {
      debugPrint("Error al iniciar sesión: $e");
      throw Exception("No se pudo iniciar sesión.");
    }
  }

  // REGISTER: Email & password
  @override
  Future<AppUser?> registerWithEmailPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception("Error al crear el usuario en Firebase");
      }

      final String? token = await firebaseUser.getIdToken();

      if (token == null) {
        throw Exception("No se pudo obtener el token");
      }

      final nameParts = name
          .trim()
          .split(RegExp(r'\s+'))
          .where((part) => part.isNotEmpty)
          .toList();

      final String firstName = nameParts.isNotEmpty ? nameParts[0] : '';
      final String lastName = nameParts.length > 1 ? nameParts[1] : '';

      await userRepo.createCurrentUser(
        firstName: firstName,
        lastName: lastName,
        username: firebaseUser.uid,
      );

      final backendUser = await userRepo.getCurrentUser();

      return AppUser(
        uid: backendUser.uid,
        email: backendUser.email,
        token: token,
        firstName: backendUser.firstName,
        lastName: backendUser.lastName,
        username: backendUser.username,
        avatar: backendUser.avatar,
        avatarThumbnail: backendUser.avatarThumbnail,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint("Error al registrarse: ${e.code}");
      throw Exception(_getFirebaseAuthErrorMessage(e));
    } catch (e) {
      debugPrint("Error al registrarse: $e");
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      // 1. Get current user
      final user = firebaseAuth.currentUser;

      // Check if there is a logged in user
      if (user == null) throw Exception("No user logged in..");

      /*

      // 2. Obtenemos el token antes de destruir la cuenta
      String? token = await user.getIdToken();
      if (token == null) throw Exception("Could not retrieve security token");

      // 3. Llamamos al backend para borrar los datos del usuario
      await _exerciseService.eliminarDatosUsuariosbackend(token: token);

      */

      // delete account
      await user.delete();
    } catch (e) {
      throw Exception("Failed to delete account: $e");
    }
  }

  // GET CURRENT USER
  @override
  Future<AppUser?> getCurrentUser() async {
    try {
      final firebaseUser = firebaseAuth.currentUser;

      if (firebaseUser == null) {
        return null;
      }

      final String? tokenActualizado = await firebaseUser.getIdToken(true);

      if (tokenActualizado == null) {
        return null;
      }

      final backendUser = await userRepo.getCurrentUser();

      return AppUser(
        uid: backendUser.uid,
        email: backendUser.email,
        token: tokenActualizado,
        firstName: backendUser.firstName,
        lastName: backendUser.lastName,
        username: backendUser.username,
        avatar: backendUser.avatar,
        avatarThumbnail: backendUser.avatarThumbnail,
      );
    } catch (e) {
      debugPrint("Error al obtener usuario actual: $e");
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<String> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return "¡Correo de restablecimiento enviado! Revisa tu bandeja de entrada.";
    } catch (e) {
      return "Un error ha ocurrido";
    }
  }

  @override
  Future<AppUser?> signInWithGoogle() async {
    try {
      // 1. Obtener la instancia global única
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      // 2. Inicializar el plugin
      await GoogleSignIn.instance.initialize(
        serverClientId:
            '739771923607-qlgvf5fjv8emk18ql40vok7e5br57t3a.apps.googleusercontent.com',
      );

      // 3. Abrir de manera interactiva el selector de cuentas
      final GoogleSignInAccount gUser = await googleSignIn.authenticate();

      // 4. Separar Autenticación de Autorización
      final GoogleSignInAuthentication gAuth = gUser.authentication;
      final String? idToken = gAuth.idToken;

      // 5. create a credential for the user
      final credential = GoogleAuthProvider.credential(idToken: idToken);

      // sign in with these credentials
      UserCredential userCredential = await firebaseAuth.signInWithCredential(
        credential,
      );

      // firebase user
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) return null;

      final String? firebaseToken = await firebaseUser.getIdToken();

      if (firebaseToken == null) {
        throw Exception("No se pudo obtener el token");
      }

      final nameParts = (firebaseUser.displayName ?? '')
          .trim()
          .split(RegExp(r'\s+'))
          .where((part) => part.isNotEmpty)
          .toList();

      final String firstName = nameParts.isNotEmpty ? nameParts[0] : '';
      final String lastName = nameParts.length > 1 ? nameParts[1] : '';

      await userRepo.createCurrentUser(
        firstName: firstName,
        lastName: lastName,
        username: firebaseUser.uid,
      );

      final backendUser = await userRepo.getCurrentUser();

      return AppUser(
        uid: backendUser.uid,
        email: backendUser.email,
        token: firebaseToken,
        firstName: backendUser.firstName,
        lastName: backendUser.lastName,
        username: backendUser.username,
        avatar: backendUser.avatar,
        avatarThumbnail: backendUser.avatarThumbnail,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint("Error de Firebase con Google: ${e.code}");
      throw Exception(_getFirebaseAuthErrorMessage(e));
    } catch (e) {
      debugPrint("Error en signInWithGoogle: $e");
      throw Exception("No se pudo iniciar sesión con Google.");
    }
  }
}
