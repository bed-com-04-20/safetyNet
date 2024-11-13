import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';

class ImageManagementPage extends StatefulWidget {
  const ImageManagementPage({super.key});

  @override
  State<ImageManagementPage> createState() => _ImageManagementPageState();
}

class _ImageManagementPageState extends State<ImageManagementPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("images");
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final List<Map<String, String>> _images = [];

  @override
  void initState() {
    super.initState();
    _fetchImagesFromDatabase();
  }

  // Fetch images from Firebase Realtime Database
  Future<void> _fetchImagesFromDatabase() async {
    _dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      setState(() {
        _images.clear();
        data.forEach((key, value) {
          _images.add({"id": key, "url": value["url"]});
        });
      });
    });
  }

  // Upload image to Firebase Storage
  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = _storage.ref().child("images/$fileName");

      try {
        await ref.putFile(file);
        final url = await ref.getDownloadURL();
        final newRef = _dbRef.push();
        await newRef.set({"url": url});
      } catch (e) {
        _showError(e.toString());
      }
    }
  }

  // Update an image in Firebase
  Future<void> _updateImage(String id) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = _storage.ref().child("images/$fileName");

      try {
        await ref.putFile(file);
        final url = await ref.getDownloadURL();
        await _dbRef.child(id).update({"url": url});
      } catch (e) {
        _showError(e.toString());
      }
    }
  }

  // Delete an image from Firebase
  Future<void> _deleteImage(String id, String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
      await _dbRef.child(id).remove();
    } catch (e) {
      _showError(e.toString());
    }
  }

  // Show error messages
  void _showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $error")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Management"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Button to upload a new image
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _uploadImage,
              icon: const Icon(Icons.add_a_photo),
              label: const Text("Upload New Image"),
            ),
          ),
          const Divider(),

          // Display images in a grid
          Expanded(
            child: _images.isNotEmpty
                ? GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                final image = _images[index];
                return Card(
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.network(
                          image["url"]!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: () => _updateImage(image["id"]!),
                            icon: const Icon(Icons.edit),
                            tooltip: "Update Image",
                          ),
                          IconButton(
                            onPressed: () =>
                                _deleteImage(image["id"]!, image["url"]!),
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            tooltip: "Delete Image",
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            )
                : const Center(
              child: Text(
                "No images uploaded yet. Use the button above to add images.",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
