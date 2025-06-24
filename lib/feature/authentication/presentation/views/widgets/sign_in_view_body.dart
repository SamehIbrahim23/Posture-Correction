import 'dart:async';

import 'package:camera_stream/feature/authentication/presentation/views/widgets/custom_sub_middle_section.dart';
import 'package:camera_stream/feature/authentication/presentation/views/widgets/sign_in_bottom_section.dart';
import 'package:camera_stream/feature/authentication/presentation/views/widgets/sign_in_top_section.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../../../../core/utils/app_colors.dart';

class SignInViewBody extends StatefulWidget {
  const SignInViewBody({super.key});

  @override
  State<SignInViewBody> createState() => _SignInViewBodyState();
}

class _SignInViewBodyState extends State<SignInViewBody> {
  int _currentIndex = 0;
  Timer? _timer;
  bool isAsync = false;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % 3; // Loop through the dots
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      opacity: 0.4,
      inAsyncCall: isAsync,
      progressIndicator: const CircularProgressIndicator(
        color: AppColors.primaryColor,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width,
            child: const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 26.0,
              ),
              child: CustomScrollView(
                physics: BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: SignInTopSection(),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 32,
                          ),
                        ),
                        Expanded(
                          child: CustomSubMiddleSection(),
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          flex: 4,
                          child: SignInBottomSection(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
