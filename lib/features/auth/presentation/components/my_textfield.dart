import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final String? errorText;

  const MyTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasError = errorText != null && errorText!.isNotEmpty;

    return SizedBox(
      height: 56,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,

          hintStyle: TextStyle(
            color: hasError ? colorScheme.error : colorScheme.primary,
          ),

          errorText: errorText,

          filled: true,

          // Fondo rojo suave cuando hay error
          fillColor: hasError
              ? colorScheme.error.withValues(alpha: 0.08)
              : colorScheme.secondary,

          // Borde normal
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: hasError
                  ? colorScheme.error
                  : colorScheme.primary.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),

          // Borde seleccionado
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: 2,
            ),
          ),

          // Borde cuando hay error
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: colorScheme.error,
              width: 1.5,
            ),
          ),

          // Borde cuando hay error y está seleccionado
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: colorScheme.error,
              width: 2,
            ),
          ),

          errorStyle: TextStyle(
            color: colorScheme.error,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
