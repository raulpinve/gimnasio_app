import 'package:flutter/material.dart';

class MyAppbarButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;

  const MyAppbarButton({
    super.key,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        SizedBox(
          width: 35,
          height: 35,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.surface,
              foregroundColor: colorScheme.onSurface,
              elevation: 0,
              padding: EdgeInsets.zero,
              shape: const CircleBorder(),
            ),
            child: icon,
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}
