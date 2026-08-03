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
    final colorScheme = Theme.of(context).colorScheme;

    Color buttonColor;
    Color borderColor;
    Color textColor;

    switch (type) {
      case MyButtonType.primary:
        buttonColor = colorScheme.primary;
        borderColor = colorScheme.primary.withValues(alpha: 0.4);
        textColor = Colors.white;
        break;

      case MyButtonType.secondary:
        buttonColor = Colors.white;
        borderColor = colorScheme.onSurface.withValues(alpha: 0.2);
        textColor = colorScheme.onSurface;
        break;

      case MyButtonType.warning:
        buttonColor = Colors.orange;
        borderColor = Colors.orange;
        textColor = Colors.white;
        break;

      case MyButtonType.danger:
        buttonColor = colorScheme.error;
        borderColor = colorScheme.error;
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
