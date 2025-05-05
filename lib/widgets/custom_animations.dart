import 'package:flutter/material.dart';
import 'dart:math' as math;

class HopRotateTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  final peakScale = 2.5;
  final peakOffsetY = -3.0;
  final maxRotationRadians = math.pi / 30;
  final riseCurve = Curves.easeInOut;
  final fallCurve = Curves.easeInOut;
  final rotationCurve = Curves.easeInOut;

  const HopRotateTransition({
    required this.animation,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final double randomRotationAngle =
        (math.Random().nextDouble() * 2 - 1) * maxRotationRadians;
    // --- Scale Tween (Rise & Fall) ---
    final scaleTween = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: peakScale)
            .chain(CurveTween(curve: riseCurve)),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween(begin: peakScale, end: 1.0)
            .chain(CurveTween(curve: fallCurve)),
        weight: 50.0,
      ),
    ]);

    final positionTween = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: Offset.zero, end: Offset(0.0, peakOffsetY))
            .chain(CurveTween(curve: riseCurve)),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Offset(0.0, peakOffsetY), end: Offset.zero)
            .chain(CurveTween(curve: fallCurve)),
        weight: 50.0,
      ),
    ]);

    final rotationTween = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: randomRotationAngle),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween(begin: randomRotationAngle, end: 0.0),
        weight: 50.0,
      ),
    ]).chain(CurveTween(curve: rotationCurve));

    return SlideTransition(
      position: positionTween.animate(animation),
      child: ScaleTransition(
        scale: scaleTween.animate(animation),
        child: RotationTransition(
          turns: rotationTween.animate(animation),
          child: child,
        ),
      ),
    );
  }
}
