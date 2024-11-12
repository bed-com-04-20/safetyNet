import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';

class ConversationScreen extends StatefulWidget {
  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  Future<void> _uploadImage(String messageId) async {
    if (_imageFile != null) {
      FirebaseStorage storage = FirebaseStorage.instance;
      try {
        String fileName = DateTime.now().toString();
        Reference ref = storage.ref().child('uploads/$fileName');
        await ref.putFile(_imageFile!);
        String downloadURL = await ref.getDownloadURL();
        // Update the message with the image URL
        await _database.child('messages').child(messageId).update({
          'imageUrl': downloadURL,
        });
      } catch (e) {
        print("Error uploading image: $e");
      }
    }
  }

  void _sendMessage(String sender) async {
    String message = _messageController.text;
    if (message.isNotEmpty || _imageFile != null) {
      // Create a new message entry in Realtime Database
      DatabaseReference newMessageRef = _database.child('messages').push();
      await newMessageRef.set({
        'text': message,
        'sender': sender,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'imageUrl': null,
      });

      if (_imageFile != null) {
        await _uploadImage(newMessageRef.key!);
        setState(() {
          _imageFile = null;
        });
      }

      _messageController.clear();
    } else {
      print('Please type a message or take a photo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Conversation')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _database.child('messages').orderByChild('timestamp').onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                Map<dynamic, dynamic> messages = (snapshot.data!.snapshot.value as Map<dynamic, dynamic>);
                List<Map<dynamic, dynamic>> messageList = messages.entries
                    .map((entry) => entry.value as Map<dynamic, dynamic>)
                    .toList();

                return ListView.builder(
                  itemCount: messageList.length,
                  itemBuilder: (context, index) {
                    var message = messageList[index];
                    bool isAdmin = message['sender'] == 'admin';
                    return ListTile(
                      title: Text(message['text'] ?? ''),
                      subtitle: message['imageUrl'] != null
                          ? Image.network(message['imageUrl'])
                          : null,
                      trailing: isAdmin ? Icon(Icons.admin_panel_settings) : null,
                      leading: isAdmin ? null : Icon(Icons.person),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.camera_alt),
                  onPressed: _pickImage,
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => _sendMessage('user'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
