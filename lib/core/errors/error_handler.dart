import 'package:flutter/material.dart';

class ErrorHandler {
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();

  static void showError(String message) {
    messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  static void showSuccess(String message) {
    messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}
