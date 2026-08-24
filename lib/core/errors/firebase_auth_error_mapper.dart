import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthErrorMapper {
  static String getMessage(FirebaseAuthException e) {
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
}
