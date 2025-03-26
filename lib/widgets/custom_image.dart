import 'dart:io';
import 'package:flutter/material.dart';

class _CustomImageContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;

  const _CustomImageContainer({
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - 1),
        child: child,
      ),
    );
  }
}

class CustomNetworkImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final double borderRadius;

  const CustomNetworkImage({
    required this.url,
    this.width,
    this.height,
    this.borderRadius = 20.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return _CustomImageContainer(
      width: width,
      height: height,
      borderRadius: borderRadius,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
              color: Theme.of(context).colorScheme.surfaceContainer);
        },
      ),
    );
  }
}

class CustomLocalImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final double borderRadius;

  const CustomLocalImage({
    required this.path,
    this.width,
    this.height,
    this.borderRadius = 20.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return _CustomImageContainer(
      width: width,
      height: height,
      borderRadius: borderRadius,
      child: Image.file(
        File(path),
        fit: BoxFit.cover,
      ),
    );
  }
}
