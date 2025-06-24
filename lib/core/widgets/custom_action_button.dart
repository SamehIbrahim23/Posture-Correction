import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_styles.dart';

class CustomActionButton extends StatelessWidget {
  const CustomActionButton({
    super.key,
    required this.onPressed,
    required this.text,
  });
  final void Function() onPressed;
  final String text;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        overlayColor: AppColors.white,
        minimumSize: Size(
          MediaQuery.of(context).size.width,
          56,
        ),
        backgroundColor: AppColors.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            32,
          ),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: AppStyles.regular24(context).copyWith(
          fontSize: getResponsiveText(context: context, base: 18),
          color: AppColors.white,
        ),
      ),
    );
  }
}
