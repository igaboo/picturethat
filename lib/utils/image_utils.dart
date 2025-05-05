import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

const options = [
  (name: "Camera", icon: Icons.camera_alt, source: ImageSource.camera),
  (name: "Gallery", icon: Icons.photo, source: ImageSource.gallery),
];

class ImageUtils {
  static final ImagePicker _imagePicker = ImagePicker();

  static Future<XFile?> pickImage(BuildContext context) async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (_) {
        return AlertDialog(
          icon: Icon(Icons.image_outlined),
          title: Text("Select Image Source"),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              spacing: 4.0,
              mainAxisSize: MainAxisSize.min,
              children: [
                ...options.map((option) {
                  return SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(option.source),
                      style: FilledButton.styleFrom(
                        minimumSize: Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: option.name == "Camera"
                              ? BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(4),
                                  bottomRight: Radius.circular(4),
                                )
                              : BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                ),
                        ),
                      ),
                      child: Text(option.name),
                    ),
                  );
                })
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return null;

    try {
      return await _imagePicker.pickImage(source: source);
    } catch (e) {
      rethrow;
    }
  }
}
