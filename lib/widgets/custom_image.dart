import 'package:flutter/material.dart';
import 'package:picture_that/screens/image_viewer_screen.dart';

enum CustomImageShape { squircle, circle }

class CustomImage extends StatelessWidget {
  final ImageProvider imageProvider;
  final double width;
  final double height;
  final CustomImageShape shape;
  final double? maxWidth;
  final double? borderRadius;

  const CustomImage({
    required this.imageProvider,
    required this.width,
    required this.height,
    this.shape = CustomImageShape.squircle,
    this.maxWidth,
    this.borderRadius,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = colorScheme.surfaceContainerHighest;
    final placeholderColor = colorScheme.surfaceContainerLow;
    final adjustedBorderRadius = (shape == CustomImageShape.squircle)
        ? BorderRadius.circular(borderRadius ?? 20.0)
        : null;

    double scaledWidth = width;
    double scaledHeight = height;

    if (maxWidth != null) {
      final aspectRatio = width / height;
      scaledWidth = maxWidth!;
      scaledHeight = scaledWidth / aspectRatio;
    }

    Widget imageWidget = Image(
      image: imageProvider,
      fit: BoxFit.cover,
      width: scaledWidth,
      height: scaledHeight,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        Widget placeholder = Container(
          color: placeholderColor,
          width: scaledWidth,
          height: scaledHeight,
        );

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: frame == null ? placeholder : child,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
      },
    );

    Widget clippedImage;
    if (shape == CustomImageShape.circle) {
      clippedImage = ClipOval(child: imageWidget);
    } else {
      clippedImage =
          ClipRRect(borderRadius: adjustedBorderRadius!, child: imageWidget);
    }

    Widget borderedContainer = Container(
      foregroundDecoration: BoxDecoration(
        shape: shape == CustomImageShape.circle
            ? BoxShape.circle
            : BoxShape.rectangle,
        borderRadius: adjustedBorderRadius,
        border: Border.all(color: borderColor),
      ),
      child: clippedImage,
    );

    return borderedContainer;
  }
}

class CustomImageViewer extends StatelessWidget {
  final CustomImage customImage;
  final Object? heroTag;
  final VoidCallback? onDoubleTap;
  final List<Widget>? actions;

  const CustomImageViewer({
    required this.customImage,
    this.heroTag,
    this.onDoubleTap,
    this.actions,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: onDoubleTap,
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (context, animation, secondaryAnimation) {
              return ImageViewerScreen(
                imageProvider: customImage.imageProvider,
                heroTag: heroTag,
                actions: actions,
              );
            },
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      },
      child: heroTag != null
          ? Hero(tag: heroTag!, child: customImage)
          : customImage,
    );
  }
}
