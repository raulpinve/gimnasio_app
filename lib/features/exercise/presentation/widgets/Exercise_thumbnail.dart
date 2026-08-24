import 'package:flutter/material.dart';

class ExerciseThumbnail extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double size;
  final double borderRadius;

  const ExerciseThumbnail({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 72,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl?.trim().isNotEmpty == true;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: hasImage
          ? Image.network(
              imageUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return _buildInitials(context);
              },
            )
          : _buildInitials(context),
    );
  }

  Widget _buildInitials(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      color: colorScheme.primary.withValues(alpha: 0.08),
      alignment: Alignment.center,
      child: Text(
        _getInitials(),
        style: TextStyle(
          fontSize: size * 0.25,
          fontWeight: FontWeight.w700,
          color: colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String _getInitials() {
    final cleanName = name.trim();

    if (cleanName.isEmpty) {
      return '?';
    }

    final words = cleanName
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }

    if (cleanName.length >= 2) {
      return cleanName.substring(0, 2).toUpperCase();
    }

    return cleanName.toUpperCase();
  }
}
