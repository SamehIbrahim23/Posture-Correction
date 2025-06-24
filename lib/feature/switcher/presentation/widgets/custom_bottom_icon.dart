import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';

class CustomBottomIcon extends StatelessWidget {
  const CustomBottomIcon({
    super.key,
    required this.color,
    this.onPressed,
    required this.icon,
    required this.isActive,
  });

  final Color color;
  final Function()? onPressed;
  final Icon icon;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      child: CircleAvatar(
        backgroundColor: isActive ? AppColors.white : Colors.transparent,
        radius: 28,
        child: icon,
      ),
    );
  }
}
