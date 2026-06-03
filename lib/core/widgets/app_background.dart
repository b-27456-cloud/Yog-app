import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const AppBackground({
    Key? key,
    required this.child,
    this.isDark = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? null : AppColors.kSteelBlue,
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.kNavy,
                  AppColors.kNavyDark,
                  AppColors.kNavy,
                ],
              )
            : null,
      ),
      child: child,
    );
  }
}
