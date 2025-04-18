import 'package:flutter/material.dart';
import 'package:picturethat/screens/authenticated/image_viewer_screen.dart';

enum CustomImageShape { squircle, circle }

class CustomImage extends StatelessWidget {
  final ImageProvider imageProvider;
  final double width;
  final double height;
  final CustomImageShape shape;
  final double? maxWidth;
  final double? maxHeight;

  const CustomImage({
    required this.imageProvider,
    required this.width,
    required this.height,
    this.shape = CustomImageShape.squircle,
    this.maxWidth,
    this.maxHeight,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.surfaceContainerHighest;
    final placeholderColor = theme.colorScheme.surfaceContainerLow;
    final borderRadius = (shape == CustomImageShape.squircle)
        ? BorderRadius.circular(20.0)
        : null;

    double scaledWidth = width;
    double scaledHeight = height;
    if (maxHeight != null) {
      double scale = maxHeight! / height;
      scaledHeight = height * scale;
      scaledWidth = width * scale;
    }
    if (maxWidth != null && scaledWidth > scaledHeight) {
      double scale = maxWidth! / scaledWidth;
      scaledWidth = maxWidth!;
      scaledHeight = scaledHeight * scale;
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
      clippedImage = ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    Widget borderedContainer = Container(
      foregroundDecoration: BoxDecoration(
        shape: shape == CustomImageShape.circle
            ? BoxShape.circle
            : BoxShape.rectangle,
        borderRadius: borderRadius,
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

  const CustomImageViewer({
    required this.customImage,
    this.heroTag,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (context, animation, secondaryAnimation) {
              return ImageViewerScreen(
                imageProvider: customImage.imageProvider,
                heroTag: heroTag,
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
