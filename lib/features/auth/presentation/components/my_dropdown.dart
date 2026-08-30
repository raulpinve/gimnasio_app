import 'package:flutter/material.dart';

class MyDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final String hintText;
  final ValueChanged<T?>? onChanged;
  final String? errorText;

  const MyDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.hintText,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final hasError = errorText != null && errorText!.isNotEmpty;

    final secondaryTextColor = colorScheme.onSurface.withValues(alpha: 0.5);

    final borderColor = colorScheme.onSurface.withValues(alpha: 0.15);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 56,
          child: DropdownButtonFormField<T>(
            initialValue: value,
            items: items,
            onChanged: onChanged,
            isExpanded: true,
            isDense: true,

            // Texto seleccionado
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 16,
            ),

            // Fondo del menú desplegable
            dropdownColor: colorScheme.surface,

            // Flecha
            icon: Icon(
              Icons.arrow_drop_down_rounded,
              color: hasError ? colorScheme.error : secondaryTextColor,
              size: 28,
            ),

            decoration: InputDecoration(
              hintText: hintText,

              hintStyle: TextStyle(
                color: hasError ? colorScheme.error : secondaryTextColor,
              ),

              filled: true,

              // Fondo del campo
              fillColor: hasError
                  ? colorScheme.error.withValues(alpha: 0.05)
                  : colorScheme.surface,

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError ? colorScheme.error : borderColor,
                  width: 1,
                ),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError ? colorScheme.error : colorScheme.primary,
                  width: 1.5,
                ),
              ),

              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.error,
                  width: 1,
                ),
              ),

              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.error,
                  width: 1.5,
                ),
              ),

              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),

        if (hasError) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              errorText!,
              style: TextStyle(
                color: colorScheme.error,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
