import 'package:flutter/material.dart';

class MyDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final String hintText;
  final ValueChanged<T?>? onChanged;

  const MyDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,

      style: TextStyle(
        color: colorScheme.inversePrimary,
        fontSize: 16,
      ),

      dropdownColor: colorScheme.secondary,

      icon: Icon(
        Icons.arrow_drop_down_rounded,
        color: colorScheme.primary,
        size: 28,
      ),

      isDense: true,

      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 12.0,
        ),

        // Borde normal
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),

        // Borde cuando está seleccionado
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),

        // Borde por defecto
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),

        hintText: hintText,

        hintStyle: TextStyle(
          color: colorScheme.primary,
        ),

        fillColor: colorScheme.secondary,
        filled: true,
      ),
    );
  }
}
