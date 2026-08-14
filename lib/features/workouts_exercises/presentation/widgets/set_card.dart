import 'package:flutter/material.dart';

class SetCard extends StatelessWidget {
  const SetCard({
    super.key,
    required this.primaryText,
    required this.secondaryText,
    this.color,
  });

  final String primaryText;
  final String secondaryText;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? Theme.of(context).colorScheme.tertiary;

    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: cardColor,
        border: Border.all(
          color: cardColor,
        ),
      ),
      child: Column(
        children: [
          Text(
            primaryText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            secondaryText,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
