import 'package:flutter/material.dart';

class MyAppbarButton extends StatelessWidget {
  final Function()? onPressed;

  const MyAppbarButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          child: const Text("+"),
        ),
        SizedBox(
          width: 12,
        ),
      ],
    );
  }
}
