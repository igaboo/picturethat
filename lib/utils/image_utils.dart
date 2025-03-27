import 'package:image_picker/image_picker.dart';

class ImageUtils {
  static final ImagePicker _imagePicker = ImagePicker();

  static Future<XFile?> pickImage() async {
    try {
      return await _imagePicker.pickImage(source: ImageSource.gallery);
    } catch (e) {
      rethrow;
    }
  }
}
