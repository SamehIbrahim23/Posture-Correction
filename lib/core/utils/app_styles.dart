import 'package:flutter/material.dart';

abstract class AppStyles {
  static TextStyle semiBold24(context) => TextStyle(
        fontSize: getResponsiveText(context: context, base: 24),
        fontFamily: 'Matemasie',
      );
  static TextStyle regular24(context) => TextStyle(
        fontSize: getResponsiveText(context: context, base: 24),
        fontFamily: 'Poppins',
      );
  static TextStyle semiBoldPoppins28(context) => TextStyle(
        fontSize: getResponsiveText(context: context, base: 28),
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
      );
  static TextStyle semiBold58(context) => TextStyle(
        fontSize: getResponsiveText(context: context, base: 58),
        fontFamily: 'Inter',
      );
  static TextStyle semiBoldInter16(context) => TextStyle(
        fontSize: getResponsiveText(
          context: context,
          base: 16,
        ),
        fontFamily: 'Inter',
      );
}

double getResponsiveText(
    {required BuildContext context, required double base}) {
  double scaleFactor = getScaleFactor(
    context: context,
  );
  double responsiveText = scaleFactor * base;
  double lowerLimit = responsiveText * 0.8;
  double upperLimit = responsiveText * 1.2;
  return responsiveText.clamp(lowerLimit, upperLimit);
}

double getScaleFactor({required BuildContext context}) {
  double widthOfScreen = MediaQuery.of(context).size.width;
  return widthOfScreen / 500;
}
