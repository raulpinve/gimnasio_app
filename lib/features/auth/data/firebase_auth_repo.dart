import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gym_app/features/auth/domain/entities/app_user.dart';
import 'package:gym_app/features/auth/domain/repos/auth_repo.dart';

class FirebaseAuthRepo implements AuthRepo {
  // Access to firebase
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // LOGIN: Email && password
  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try {
      // 1. Autenticación inicial
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) throw Exception("Usuario no existe");

      // 2. Solicitamos el token JWT asíncronamente
      String? token = await firebaseUser.getIdToken();

      // 3. Creamos y retornamos el AppUser
      return AppUser(
        uid: userCredential.user!.uid,
        email: email,
        token: token ?? "",
      );
    } catch (e) {
      debugPrint("Error al iniciar sesión: $e");
      throw Exception("Error al iniciar sesión");
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
      // 1. Intentamos el registro en Firebase Auth
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception("Error al crear el usuario en Firebase");
      }

      // 2. Obtenemos el token
      String? token = await firebaseUser.getIdToken();

      // 3. Creamos y retornamos el AppUser
      return AppUser(uid: firebaseUser.uid, email: email, token: token ?? "");
    } catch (e) {
      debugPrint("Error al registrarse: $e");
      throw Exception("Error al registrarse.");
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
    // Get current logged in user from firebase
    final firebaseUser = firebaseAuth.currentUser;

    // No logged in user
    if (firebaseUser == null) return null;

    final String? tokenActualizado = await firebaseUser.getIdToken(true);
    // developer.log("TokenActualizado: $tokenActualizado");

    // Logged in user exists
    return AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email!,
      token: tokenActualizado ?? '',
    );
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

      return AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        token: firebaseToken ?? '',
      );
    } catch (e) {
      debugPrint("Error en signInWithGoogle: $e");
      return null;
    }
  }
}
