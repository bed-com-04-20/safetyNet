import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:safetynet/src/ui/replies.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!.snapshot.value;
          final Map<dynamic, dynamic> castedData = data is Map ? data : {};

          if (castedData.isEmpty) {
            return const Center(child: Text("No data found", style: TextStyle(color: Colors.white)));
          }

          // Extract relevant notifications and get admin names dynamically
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

            // Retrieve admin's name from users node
            final adminMessage = messages.values.firstWhere(
                  (msg) => msg is Map<dynamic, dynamic> && msg['senderRole'] == 'admin',
              orElse: () => null,
            );

            String senderName = 'Unknown Admin';
            if (adminMessage != null) {
              final adminId = adminMessage['senderId']; // Assuming senderId field is available
              final adminDataSnapshot = await FirebaseDatabase.instance.ref('users/$adminId').get();

              if (adminDataSnapshot.exists) {
                final adminData = adminDataSnapshot.value as Map<dynamic, dynamic>?;
                if (adminData != null && adminData.containsKey('name')) {
                  senderName = adminData['name'] ?? 'Unknown Admin';
                }
              }
            }

            final hasUnreadMessages = messages.values.any((msg) {
              if (msg is Map<dynamic, dynamic>) {
                return msg['hasUnreadMessages']?.toString().toLowerCase() == 'true';
              }
              return false;
            });

            return {
              'reportId': reportId,
              'senderName': senderName,
              'hasUnreadMessages': hasUnreadMessages,
            };
          }).toList();

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: Future.wait(reports),
            builder: (context, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!futureSnapshot.hasData || futureSnapshot.data!.isEmpty) {
                return const Center(child: Text("No data found", style: TextStyle(color: Colors.white)));
              }

              final reports = futureSnapshot.data!;

              return ListView.builder(
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
                  return Card(
                    color: const Color(0xFFeb6958), // Admin-specific color
                    child: ListTile(
                      title: Text(
                        'Admin: ${report['senderName']}',
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
                              name: 'Conversation with ${report['senderName']}',
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
}
