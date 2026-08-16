import 'package:flutter/material.dart';

enum MyButtonType {
  primary,
  secondary,
  warning,
  danger,
}

class MyButton extends StatelessWidget {
  final void Function()? onTap;
  final String text;
  final MyButtonType type;
  final bool isLoading;

  const MyButton({
    super.key,
    required this.onTap,
    required this.text,
    this.type = MyButtonType.secondary,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    Color buttonColor;
    Color borderColor;
    Color textColor;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (type) {
      case MyButtonType.primary:
        buttonColor = isDark
            ? const Color(0xFF4F7CFF)
            : const Color(0xFF2563EB);
        borderColor = isDark
            ? const Color(0xFF6B91FF)
            : const Color(0xFF2563EB);
        textColor = Colors.white;
        break;

      case MyButtonType.secondary:
        buttonColor = isDark
            ? const Color(0xFF374151)
            : const Color(0xFFE5E7EB);
        borderColor = isDark
            ? const Color(0xFF4B5563)
            : const Color(0xFFD1D5DB);
        textColor = isDark ? Colors.white : const Color(0xFF1F2937);
        break;

      case MyButtonType.warning:
        buttonColor = isDark
            ? const Color(0xFFD97706)
            : const Color(0xFFF59E0B);
        borderColor = isDark
            ? const Color(0xFFF59E0B)
            : const Color(0xFFD97706);
        textColor = Colors.white;
        break;

      case MyButtonType.danger:
        buttonColor = isDark
            ? const Color(0xFFDC2626)
            : const Color(0xFFEF4444);
        borderColor = isDark
            ? const Color(0xFFEF4444)
            : const Color(0xFFDC2626);
        textColor = Colors.white;
        break;
    }

    return SizedBox(
      height: 56,
      child: GestureDetector(
        onTap: isLoading ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: textColor,
                    ),
                  )
                : Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
