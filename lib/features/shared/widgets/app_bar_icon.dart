import 'package:flutter/material.dart';

/// Reusable circular icon used on top of images / in AppBars to ensure
/// consistent sizing, contrast and touch target across the app.
class AppBarIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double radius;
  final Color backgroundColor;
  final double iconSize;

  /// [backgroundColor] defaults to a soft pink. You can pass a different
  /// color (for example a light green) when you need a variant.
  const AppBarIcon({
    super.key,
    required this.icon,
    this.onPressed,
    this.radius = 18, // unify with other action icons
    this.backgroundColor = const Color(0xFFE8F5E9), // light green (green[50])
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    // Choose an icon color that contrasts with the background color. If the
    // background is light, use a dark icon; otherwise use white.
    final iconColor = backgroundColor.computeLuminance() > 0.5
        ? Colors.black87
        : Colors.white;

    return CircleAvatar(
      backgroundColor: backgroundColor,
      radius: radius,
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: Icon(icon, size: iconSize, color: iconColor),
        onPressed: onPressed,
      ),
    );
  }
}
