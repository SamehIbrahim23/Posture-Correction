import 'package:camera_stream/feature/profile/presentation/views/widgets/custom_logout_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/helper/show_snack_bar.dart';
import '../../../../../core/routing/routes.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_styles.dart';

class CustomBottomModalSheet extends StatelessWidget {
  const CustomBottomModalSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 11.0,
        vertical: 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 12,
          ),
          Divider(
            thickness: 3,
            color: Colors.grey.shade400,
            indent: MediaQuery.sizeOf(context).width * 0.35,
            endIndent: MediaQuery.sizeOf(context).width * 0.35,
          ),
          const SizedBox(
            height: 32,
          ),
          Text(
            'Logout',
            style: AppStyles.semiBoldPoppins28(context).copyWith(
              fontSize: getResponsiveText(context: context, base: 24),
              color: Colors.grey,
            ),
          ),
          Divider(
            height: 38,
            thickness: 1,
            color: Colors.grey.shade400,
          ),
          Text(
            'Are you sure you want to log out?',
            style: AppStyles.semiBoldPoppins28(context).copyWith(
              fontSize: getResponsiveText(context: context, base: 18),
              color: Colors.grey,
            ),
          ),
          const SizedBox(
            height: 32,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomLogOutButton(
                onPressed: () {
                  GoRouter.of(context).pop();
                },
                text: 'Cancel',
                edgeColor: AppColors.primaryColor,
                backgroundColor: AppColors.white,
                textColor: AppColors.primaryColor,
                overlayColor: AppColors.primaryColor,
              ),
              const SizedBox(
                width: 20,
              ),
              CustomLogOutButton(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      showSnackBar(
                        context: context,
                        e: 'You have been logged out',
                        flag: true,
                        delay: 1500,
                      );
                      context.pop();
                      context.go(Routes.streaming);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      showSnackBar(
                          context: context, e: 'Oops, there something wrong');
                      context.pop();
                    }
                  }
                },
                text: 'Yes, Logout',
                edgeColor: AppColors.primaryColor,
                backgroundColor: AppColors.primaryColor,
                textColor: AppColors.white,
                overlayColor: AppColors.white,
              ),
            ],
          ),
          const SafeArea(
            top: false,
            left: false,
            right: false,
            child: SizedBox(
              height: 12,
            ),
          ),
        ],
      ),
    );
  }
}
