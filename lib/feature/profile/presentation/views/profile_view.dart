import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';
import 'widgets/profile_view_body.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  double opacity = 0.0; // Initial opacity is 0 (invisible)

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.white,
      body: AnimatedOpacity(
        opacity: opacity,
        duration: const Duration(milliseconds: 210),
        child: const ProfileViewBody(),
      ),
    );
  }
}
