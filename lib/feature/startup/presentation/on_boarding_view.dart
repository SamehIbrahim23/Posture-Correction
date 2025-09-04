import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/routes.dart';
import '../../../core/utils/app_colors.dart';
import 'widget/on_boarding_page.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  _OnboardingViewState createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackgroundColor,
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (int page) => setState(() => _currentPage = page),
              children: const [
                OnboardingPage(
                    image: 'assets/images/1.jpg',
                    title: "Welcome to Posture App",
                    description:
                        "Sit smarter, not harder. Our app helps you stay aligned throughout your day with real-time posture feedback."),
                OnboardingPage(
                    image: 'assets/images/2.jpg',
                    title: "How Does the App Work?",
                    description:
                        "Using your phone and smart AI, we analyze your posture and gently alert you when you start to slouch."),
                OnboardingPage(
                    image: 'assets/images/3.jpg',
                    title: "Track Your Progress!",
                    description:
                        "View your daily improvements and build healthier habits with posture statistics ."),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(
                    3,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: _currentPage == index
                            ? const Color(0xff704F38)
                            : Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (_currentPage < 2) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    } else {
                      context.go(Routes.streaming);
                    }
                  },
                  child: Text(_currentPage == 2 ? "FINISH" : "NEXT",
                      style: const TextStyle(
                        color: Color(0xff704F38),
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
