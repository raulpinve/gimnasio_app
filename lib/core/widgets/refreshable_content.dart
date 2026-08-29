import 'package:flutter/material.dart';

class RefreshableContent extends StatelessWidget {
  const RefreshableContent({
    super.key,
    required this.child,
    required this.onRefresh,
    this.height,
  });

  final Widget child;
  final Future<void> Function() onRefresh;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            child,
          ],
        ),
      ),
    );
  }
}
