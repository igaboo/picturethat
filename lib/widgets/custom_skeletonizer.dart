import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CustomSkeletonizer extends StatelessWidget {
  final Widget child;

  const CustomSkeletonizer({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Skeletonizer(
      ignoreContainers: true,
      effect: ShimmerEffect(
        baseColor: colorScheme.surfaceContainer,
        highlightColor: colorScheme.surfaceBright,
      ),
      child: child,
    );
  }
}
