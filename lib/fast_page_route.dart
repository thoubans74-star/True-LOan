import 'package:flutter/material.dart';

class FastPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  FastPageRoute({required this.child}) : super(
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionDuration: const Duration(milliseconds: 120),
    reverseTransitionDuration: const Duration(milliseconds: 90),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}
