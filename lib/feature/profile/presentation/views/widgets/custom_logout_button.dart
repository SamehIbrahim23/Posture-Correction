import 'package:flutter/material.dart';

import '../../../../../core/utils/app_styles.dart';

class CustomLogOutButton extends StatelessWidget {
  const CustomLogOutButton({
    super.key,
    required this.onPressed,
    required this.edgeColor,
    required this.backgroundColor,
    required this.textColor,
    required this.text,
    required this.overlayColor,
  });
  final Color edgeColor;
  final Color backgroundColor;
  final Color textColor;
  final String text;
  final Color overlayColor;
  final Function() onPressed;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width / 2 - 32,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          overlayColor: overlayColor,
          side: BorderSide(
            width: 1.0, // Border width
            color: edgeColor, // Border color
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: AppStyles.regular24(context).copyWith(
            color: textColor,
            fontSize: getResponsiveText(context: context, base: 20),
          ),
        ),
      ),
    );
  }
}
