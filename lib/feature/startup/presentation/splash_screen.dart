import 'package:camera_stream/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/routing/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingSeen = prefs.getBool('onboardingSeen') ?? false;

    await Future.delayed(const Duration(seconds: 3));

    if (!onboardingSeen) {
      await prefs.setBool('onboardingSeen', true);
      if (context.mounted) context.go(Routes.onBoarding);
    } else {
      if (context.mounted) context.go(Routes.streaming);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/LOGO.png',
              height: 170,
              color: AppColors.primaryButtonColor,
            ),
            const SizedBox(height: 24),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondTextColor,
                  height: 1.1,
                ),
                children: [
                  const TextSpan(text: 'Posture\n'),
                  TextSpan(
                    text: 'Perfect',
                    style: TextStyle(
                      color: Colors.white,
                      background: Paint()
                        ..shader = const LinearGradient(
                          colors: [
                            AppColors.primaryButtonColor,
                            AppColors.secondButtonColor
                          ],
                        ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
