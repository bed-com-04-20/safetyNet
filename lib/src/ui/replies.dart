import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';

class ConversationScreen extends StatefulWidget {
  final String name;
  final String reportId;

  const ConversationScreen({
    required this.name,
    required this.reportId,
  });

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
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
        await _database.child('messages').child(messageId).update({
          'imageUrl': downloadURL,
        });
      } catch (e) {
        print("Error uploading image: $e");
      }
    }
  }

  void _sendMessage(String sender) async {
    String message = _messageController.text.trim();
    if (message.isNotEmpty || _imageFile != null) {
      DatabaseReference newMessageRef =
      _database.child('messages/${widget.reportId}').push();
      String messageId = newMessageRef.key!;

      await newMessageRef.set({
        'text': message,
        'sender': sender,
        'timestamp': DateTime
            .now()
            .millisecondsSinceEpoch,
        'imageUrl': null,
        'hasUnreadMessages': sender == 'user',
      });

      if (_imageFile != null) {
        await _uploadImage(newMessageRef.key!);
        setState(() {
          _imageFile = null;
        });
      }

      _messageController.clear();

      // Mark all messages as read
      if (sender == 'admin') {
        _database.child('messages/${widget.reportId}').once().then((snapshot) {
          Map<dynamic, dynamic>? messages = snapshot.snapshot.value as Map<
              dynamic,
              dynamic>?;
          if (messages != null) {
            messages.forEach((key, value) {
              _database.child('messages/${widget.reportId}/$key').update(
                  {'hasUnreadMessages': false});
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversation with ${widget.name}'),
        backgroundColor: const Color(0xFF0A0933),
      ),
      backgroundColor: const Color(0xFF0A0933),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _database
                  .child('messages/${widget.reportId}')
                  .orderByChild('timestamp')
                  .onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                Map<dynamic, dynamic> messages =
                    (snapshot.data!.snapshot.value as Map<dynamic, dynamic>?) ??
                        {};
                List<Map<dynamic, dynamic>> messageList = messages.entries
                    .map((entry) => entry.value as Map<dynamic, dynamic>)
                    .toList()
                  ..sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

                return ListView.builder(
                  itemCount: messageList.length,
                  itemBuilder: (context, index) {
                    var message = messageList[index];
                    bool isAdmin = message['sender'] == 'admin';

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 8.0),
                      child: Align(
                        alignment: isAdmin ? Alignment.centerRight : Alignment
                            .centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isAdmin
                                ? Colors.green.withOpacity(
                                0.3) // Green for Admin
                                : Colors.blueAccent.withOpacity(0.3),
                            // Blue for User
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: isAdmin
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              if (message['text'] != null &&
                                  message['text'].isNotEmpty)
                                Text(
                                  message['text'],
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16.0),
                                ),
                              if (message['imageUrl'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Image.network(
                                    message['imageUrl'],
                                    height: 150,
                                    width: 150,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, progress) {
                                      return progress == null
                                          ? child
                                          : const Center(
                                          child: CircularProgressIndicator());
                                    },
                                    errorBuilder: (context, error,
                                        stackTrace) =>
                                    const Icon(Icons.error, color: Colors.red),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
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
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white70),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
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