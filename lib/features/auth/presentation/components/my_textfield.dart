import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const MyTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.onChanged,
    this.errorText,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 56,
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            onChanged: onChanged,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hintText,

              hintStyle: TextStyle(
                color: hasError ? colorScheme.error : colorScheme.primary,
              ),

              prefixIcon: prefixIcon != null
                  ? IconTheme(
                      data: IconThemeData(
                        color: hasError
                            ? colorScheme.error
                            : colorScheme.primary,
                      ),
                      child: prefixIcon!,
                    )
                  : null,

              suffixIcon: suffixIcon != null
                  ? IconTheme(
                      data: IconThemeData(
                        color: hasError
                            ? colorScheme.error
                            : colorScheme.primary,
                      ),
                      child: suffixIcon!,
                    )
                  : null,

              filled: true,
              fillColor: hasError
                  ? colorScheme.error.withValues(alpha: 0.08)
                  : colorScheme.secondary,

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError
                      ? colorScheme.error
                      : colorScheme.primary.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.primary,
                  width: 2,
                ),
              ),

              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.error,
                  width: 1.5,
                ),
              ),

              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.error,
                  width: 2,
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
