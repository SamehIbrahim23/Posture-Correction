import 'package:camera_stream/core/utils/app_styles.dart' show AppStyles;
import 'package:flutter/material.dart';

class RowOfDividers extends StatelessWidget {
  const RowOfDividers({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Row(
        children: [
          const SizedBox(
            width: 32,
          ),
          const Expanded(
            child: Divider(
              thickness: 1,
              color: Colors.grey,
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Text(
            text,
            style: AppStyles.semiBoldInter16(context).copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          const Expanded(
            child: Divider(
              thickness: 1,
              color: Colors.grey,
            ),
          ),
          const SizedBox(
            width: 32,
          ),
        ],
      ),
    );
  }
}
