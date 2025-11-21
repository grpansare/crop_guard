import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  /// Opens the device's image gallery to select an image
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );
      return image != null ? File(image.path) : null;
    } on Exception catch (e) {
      debugPrint('Error picking image from gallery: $e');
      rethrow;
    }
  }

  /// Opens the device's camera to take a new photo
  static Future<File?> takePhotoWithCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        preferredCameraDevice: CameraDevice.rear,
      );
      return photo != null ? File(photo.path) : null;
    } on Exception catch (e) {
      debugPrint('Error taking photo with camera: $e');
      rethrow;
    }
  }

  /// Shows a bottom sheet to choose between camera and gallery
  static Future<File?> showImageSourceSelection(BuildContext context) async {
    try {
      final File? image = await showModalBottomSheet<File?>(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Take Photo'),
                  onTap: () async {
                    try {
                      final image = await takePhotoWithCamera();
                      if (context.mounted) {
                        Navigator.of(context).pop(image);
                      }
                    } on Exception catch (e) {
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        _showErrorSnackBar(context, 'Camera error: ${e.toString()}');
                      }
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () async {
                    try {
                      final image = await pickImageFromGallery();
                      if (context.mounted) {
                        Navigator.of(context).pop(image);
                      }
                    } on Exception catch (e) {
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        _showErrorSnackBar(context, 'Gallery error: ${e.toString()}');
                      }
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cancel),
                  title: const Text('Cancel'),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
        },
      );
      return image;
    } on Exception catch (e) {
      debugPrint('Error showing image source selection: $e');
      return null;
    }
  }

  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
