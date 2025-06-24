import 'package:flutter/material.dart';

import '../../../../../core/utils/app_styles.dart';

class SignWord extends StatelessWidget {
  const SignWord(
      {super.key,
      required this.title,
      required this.subTitle,
      required this.height});
  final String title;
  final String subTitle;
  final double height;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: height),
        Text(
          title,
          style: AppStyles.regular24(context),
        ),
        const SizedBox(
          height: 12,
        ),
        Text(
          subTitle,
          style: AppStyles.semiBoldPoppins28(context).copyWith(
            fontSize: getResponsiveText(context: context, base: 14),
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
