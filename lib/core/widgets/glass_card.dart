import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;
  final Color? color;
  final bool isDark;

  const GlassCard({
    Key? key,
    required this.child,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.color,
    this.isDark = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? (isDark ? AppColors.kCardBg : AppColors.kPrimary.withOpacity(0.05)),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isDark ? AppColors.kCardBorder : AppColors.kNavy.withOpacity(0.1),
              width: 1.0,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
