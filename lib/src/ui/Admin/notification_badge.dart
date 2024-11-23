import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:safetynet/src/ui/replies.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    // Check if the user is logged in
    if (currentUser == null) {
      return const Center(child: Text("User not logged in"));
    }

    final currentUserId = currentUser.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Conversations',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0A0933),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF0A0933),
      body: StreamBuilder<DatabaseEvent>(
        stream: FirebaseDatabase.instance.ref('messages').onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.snapshot.value;
          final Map<dynamic, dynamic> castedData = data is Map ? data : {};

          if (castedData.isEmpty) {
            return const Center(child: Text("No data found", style: TextStyle(color: Colors.white)));
          }

          // Process reports and retrieve sender names from the users table
          final reports = castedData.entries.where((entry) {
            final messages = entry.value as Map<dynamic, dynamic>? ?? {};
            return messages.values.any((msg) {
              if (msg is Map<dynamic, dynamic>) {
                return msg['text']?.toString().isNotEmpty ?? false;
              }
              return false;
            });
          }).map((entry) async {
            final reportId = entry.key;
            final messages = entry.value as Map<dynamic, dynamic>? ?? {};

            bool hasUnreadMessages = false;
            bool isAdmin = false;
            String senderName = 'Unknown';

            // Iterate through all messages in the report
            for (var message in messages.values) {
              if (message is Map<dynamic, dynamic>) {
                final senderId = message['senderId']; // Assuming senderId is stored in message

                // Get the sender's display name from the users table
                senderName = await _getUserName(senderId);

                // Track if the current logged-in user is the sender and message is unread
                if (senderId == currentUserId) {
                  hasUnreadMessages = message['hasUnreadMessages']?.toString().toLowerCase() == 'true';
                }

                // Check if the message is from the admin
                if (message['senderRole'] == 'admin') {
                  isAdmin = true;
                }
              }
            }

            return {
              'reportId': reportId,
              'senderName': senderName,  // Use the fetched displayName
              'hasUnreadMessages': hasUnreadMessages,
              'isAdmin': isAdmin,
            };
          }).toList();

          return FutureBuilder(
            future: Future.wait(reports), // Wait for all reports to finish fetching usernames
            builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text("Error loading data"));
              }

              final reportsData = snapshot.data ?? [];

              return ListView.builder(
                itemCount: reportsData.length,
                itemBuilder: (context, index) {
                  final report = reportsData[index];
                  return Card(
                    color: report['isAdmin'] ? Color(0xFFeb6958) : null,
                    child: ListTile(
                      title: Text(
                        'Sender: ${report['senderName']}',
                        style: const TextStyle(color: Colors.black),
                      ),
                      trailing: report['hasUnreadMessages']
                          ? const Icon(Icons.mark_chat_unread, color: Colors.red)
                          : null,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConversationScreen(
                              name: 'Report ${report['reportId']}',
                              reportId: report['reportId'],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // Helper method to fetch the user's username
  Future<String> _getUserName(String userId) async {
    try {
      final snapshot = await FirebaseDatabase.instance.ref('users/$userId').get();

      if (snapshot.exists) {
        final userData = snapshot.value as Map<dynamic, dynamic>;
        return userData['username'] ?? 'Unknown';
      } else {
        return 'Unknown';
      }
    } catch (e) {
      print('Error fetching username: $e');
      return 'Unknown';
    }
  }
}
