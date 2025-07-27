
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: uid == null
          ? const Center(child: Text('Not logged in'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where('toUid', isEqualTo: uid)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No notifications yet.'));
                }
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final type = data['type'] ?? '';
                    final fromUsername = data['fromUsername'] ?? 'Someone';
                    final postId = data['postId'];
                    final time = (data['timestamp'] as Timestamp?)?.toDate();
                    String message = '';
                    if (type == 'like') {
                      message = '$fromUsername liked your post';
                    } else {
                      message = 'You have a new notification';
                    }
                    return ListTile(
                      leading: const Icon(Icons.favorite, color: Colors.red),
                      title: Text(message),
                      subtitle: time != null
                          ? Text('${time.toLocal()}')
                          : null,
                      onTap: postId != null
                          ? () {
                              // Optionally navigate to the post
                            }
                          : null,
                    );
                  },
                );
              },
            ),
    );
  }
}
