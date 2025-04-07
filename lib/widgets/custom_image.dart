import 'package:flutter/material.dart';
import 'package:picturethat/screens/authenticated/image_viewer_screen.dart';

enum CustomImageShape { squircle, circle }

class CustomImage extends StatelessWidget {
  final ImageProvider imageProvider;
  final CustomImageShape shape;
  final double? width;
  final double? height;
  final double? maxWidth;
  final double? maxHeight;
  final double? aspectRatio;

  const CustomImage({
    required this.imageProvider,
    this.shape = CustomImageShape.squircle,
    this.width,
    this.height,
    this.maxWidth,
    this.maxHeight,
    this.aspectRatio,
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

    Widget imageWidget = Image(
      image: imageProvider,
      fit: BoxFit.cover,
      width: width,
      height: height,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        Widget placeholder = Container(color: placeholderColor);

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

    Widget sizedWidget = borderedContainer;
    if (aspectRatio != null) {
      sizedWidget = AspectRatio(
        aspectRatio: aspectRatio!,
        child: borderedContainer,
      );
    }
    if (aspectRatio == null && (width != null || height != null)) {
      sizedWidget = SizedBox(
        width: width,
        height: height,
        child: borderedContainer,
      );
    }

    Widget constrainedWidget = sizedWidget;
    if (maxWidth != null || maxHeight != null) {
      constrainedWidget = ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? double.infinity,
          maxHeight: maxHeight ?? double.infinity,
        ),
        child: sizedWidget,
      );
    }

    return constrainedWidget;
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
