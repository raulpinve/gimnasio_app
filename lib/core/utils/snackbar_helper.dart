import 'package:flutter/material.dart';

enum MessageType { success, error, info, warning }

void showMessage(
  BuildContext context,
  String message, {
  MessageType type = MessageType.info,
}) {
  final scheme = Theme.of(context).colorScheme;
  final config = _configFor(type, scheme);

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 3,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: config.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        duration: config.duration,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        content: Row(
          children: [
            Icon(config.icon, color: config.foreground),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: config.foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 4),
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: config.foreground.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
}

class _MessageConfig {
  final Color background;
  final Color foreground;
  final IconData icon;
  final Duration duration;
  const _MessageConfig(
    this.background,
    this.foreground,
    this.icon,
    this.duration,
  );
}

_MessageConfig _configFor(MessageType type, ColorScheme scheme) {
  switch (type) {
    case MessageType.success:
      return _MessageConfig(
        Colors.green.shade600,
        Colors.white,
        Icons.check_circle_outline,
        const Duration(seconds: 2),
      );
    case MessageType.error:
      return _MessageConfig(
        scheme.error,
        scheme.onError,
        Icons.error_outline,
        const Duration(seconds: 4),
      );
    case MessageType.warning:
      return _MessageConfig(
        Colors.amber.shade700,
        Colors.white,
        Icons.warning_amber_outlined,
        const Duration(seconds: 4),
      );
    case MessageType.info:
      return _MessageConfig(
        scheme.primary,
        scheme.onPrimary,
        Icons.info_outline,
        const Duration(seconds: 2),
      );
  }
}
