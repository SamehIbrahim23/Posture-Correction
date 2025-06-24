import 'package:flutter/material.dart';

import '../../../../../core/utils/app_styles.dart';

class WordOfTextfield extends StatelessWidget {
  const WordOfTextfield({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: AppStyles.regular24(context).copyWith(
          fontSize: getResponsiveText(context: context, base: 16),
        ),
      ),
    );
  }
}
