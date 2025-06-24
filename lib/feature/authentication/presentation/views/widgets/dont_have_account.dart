import 'package:flutter/material.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_styles.dart';

class DontHaveAccount extends StatelessWidget {
  const DontHaveAccount({super.key, required this.onTap});
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account? ',
          style: AppStyles.regular24(context).copyWith(
            fontSize: getResponsiveText(context: context, base: 18),
            color: Colors.grey.shade700,
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 6.0,
              vertical: 1,
            ),
            child: Text(
              'Sign Up',
              style: AppStyles.regular24(context).copyWith(
                  fontSize: getResponsiveText(context: context, base: 18),
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primaryColor,
                  color: AppColors.primaryColor),
            ),
          ),
        ),
      ],
    );
  }
}
