import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatelessWidget {
  final File? selectedImage;
  final Function(File) onImagePicked;

  const ImagePickerWidget({required this.onImagePicked, this.selectedImage});

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      onImagePicked(File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _pickImage,
          child: const Text("Upload Image"),
        ),
        if (selectedImage != null)
          Image.file(
            selectedImage!,
            height: 200,
            fit: BoxFit.cover,
          ),
      ],
    );
  }
}
