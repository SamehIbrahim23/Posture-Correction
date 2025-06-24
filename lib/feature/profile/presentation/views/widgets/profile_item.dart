import 'package:flutter/material.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_styles.dart';

class ProfileItem extends StatelessWidget {
  const ProfileItem({
    super.key,
    required this.leadingIcon,
    required this.title,
    this.bottomDivider = false,
    this.onTap,
  });
  final IconData leadingIcon;
  final String title;
  final bool bottomDivider;
  final Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          splashColor: AppColors.primaryColor.withOpacity(
            0.2,
          ),
          borderRadius: BorderRadius.circular(
            18,
          ),
          onTap: onTap,
          child: ListTile(
            leading: Icon(
              leadingIcon,
              color: AppColors.primaryColor,
              size: 26,
            ),
            title: Text(
              title,
              style: AppStyles.semiBoldPoppins28(context).copyWith(
                fontSize: getResponsiveText(context: context, base: 16),
                fontWeight: FontWeight.w100,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              size: 32,
            ),
          ),
        ),
        (bottomDivider)
            ? Divider(
                height: 16,
                thickness: 1,
                color: Colors.grey.shade300,
              )
            : const SizedBox(),
      ],
    );
  }
}
