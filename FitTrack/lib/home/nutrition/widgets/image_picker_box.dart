import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fit_track/thems/colors.dart';

class ImagePickerBox extends StatelessWidget {
  final double width;
  final double height;
  final File? selectedImage;

  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;

  const ImagePickerBox({
    super.key,
    required this.width,
    required this.height,
    required this.selectedImage,
    required this.onCameraTap,
    required this.onGalleryTap,
  });

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () {
                Navigator.pop(context);
                onCameraTap();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text("Gallery"),
              onTap: () {
                Navigator.pop(context);
                onGalleryTap();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),

      child: Container(
        height: height * 0.20,
        width: width,
        decoration: BoxDecoration(
          color: const Color(0xFF1C2E05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border,
            width: 1.5,
          ),
        ),

        child: selectedImage == null
            ? Icon(
                Icons.add_a_photo,
                color: Colors.grey,
                size: width * 0.1,
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  selectedImage!,
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }
}