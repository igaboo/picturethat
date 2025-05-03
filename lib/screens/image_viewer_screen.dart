import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewerScreen extends StatelessWidget {
  final ImageProvider imageProvider;
  final Object? heroTag;

  const ImageViewerScreen({
    required this.imageProvider,
    required this.heroTag,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context)
            .colorScheme
            .surface
            .withAlpha(0), // fixes toolbar text color
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
          color: Colors.white,
          style: IconButton.styleFrom(
            backgroundColor: Colors.black.withAlpha(155),
          ),
        ),
      ),
      body: ClipRect(
        child: Center(
          child: PhotoView(
            imageProvider: imageProvider,
            heroAttributes:
                heroTag != null ? PhotoViewHeroAttributes(tag: heroTag!) : null,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
            initialScale: PhotoViewComputedScale.contained,
            backgroundDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
        ),
      ),
    );
  }
}
