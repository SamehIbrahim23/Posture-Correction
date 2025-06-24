import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomSliderTransition extends CustomTransitionPage<void> {
  CustomSliderTransition(
      {required LocalKey super.key,
      required super.child,
      required int duration})
      : super(
          transitionDuration: Duration(milliseconds: duration),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        );
}
