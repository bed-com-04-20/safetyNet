import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'replies.dart'; // Import the Conversation Screen

class DetailScreen extends StatelessWidget {
  final String name;
  final String lastSeen;
  final String location;
  final String details;
  final String imageUrl;

  DetailScreen({
    required this.name,
    required this.lastSeen,
    required this.location,
    required this.details,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Details of $name')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[300],
                child: Icon(
                  Icons.person,
                  size: 100,
                  color: Colors.white,
                ),
              ),
            SizedBox(height: 16.0),
            Text(
              'Name: $name',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 8.0),
            Text('Last Seen: $lastSeen'),
            SizedBox(height: 8.0),
            Text('Location: $location'),
            SizedBox(height: 8.0),
            Text('Details: $details'),
            SizedBox(height: 16.0),
            // Add the Reply Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConversationScreen(),
                    ),
                  );
                },
                child: Text('Reply'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
