import 'package:flutter/material.dart';

class MyAppbarButton extends StatelessWidget {
  final Function()? onPressed;
  final Widget icon;

  const MyAppbarButton({
    super.key,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 35,
          height: 35,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.zero,
              shape: const CircleBorder(),
            ),
            child: icon,
          ),
        ),
        const SizedBox(
          width: 16,
        ),
      ],
    );
  }
}
