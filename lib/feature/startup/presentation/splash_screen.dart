import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:camera_stream/core/utils/app_colors.dart';
import 'package:camera_stream/feature/startup/presentation/on_boarding_view.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/LOGO.png',
            height: 170,
            color: AppColors.primaryButtonColor,
          ),
          Column(
            children: [
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
          )
        ],
      ),
      backgroundColor: AppColors.primaryBackgroundColor,
      splashIconSize: 400,
      duration: 3000,
      splashTransition: SplashTransition.fadeTransition,
      animationDuration: const Duration(milliseconds: 1500),
      nextScreen: Onboarding(),
    );
  }
}
