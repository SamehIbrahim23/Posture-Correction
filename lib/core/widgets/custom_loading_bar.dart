import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../utils/app_colors.dart';

class CustomLoadingBar extends StatefulWidget {
  const CustomLoadingBar({
    super.key,
  });

  @override
  State<CustomLoadingBar> createState() => _CustomLoadingBarState();
}

class _CustomLoadingBarState extends State<CustomLoadingBar> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Start the timer to simulate loading animation
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % 3; // Loop through the dots
      });
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: true,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          overlayColor: AppColors.white,
          minimumSize: Size(
            MediaQuery.of(context).size.width,
            56,
          ),
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              32,
            ),
          ),
        ),
        onPressed: () {},
        child: Transform.translate(
          offset: const Offset(-20, 0),
          child: SmoothIndicator(
            offset: _currentIndex.toDouble(),
            count: 3, // Number of dots
            effect: const ScrollingDotsEffect(
              activeDotColor: Color.fromARGB(255, 255, 255, 255),
              dotColor: Colors.grey,
              dotHeight: 8,
              dotWidth: 8,
              spacing: 8,
            ),
            size: const Size(8, 8),
          ),
        ),
      ),
    );
  }
}
