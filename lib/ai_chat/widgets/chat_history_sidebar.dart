// 📄 קובץ: lib/ai_chat/widgets/chat_history_sidebar.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatHistorySidebar extends StatelessWidget {
  final Function(String sessionId) onSessionSelected;

  const ChatHistorySidebar({Key? key, required this.onSessionSelected}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchChatSessions(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('chat_sessions')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => {
      'id': doc.id,
      'title': doc['title'] ?? 'שיחה ללא כותרת'
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(child: Text('לא מחובר'));  
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchChatSessions(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('שגיאה בטעינת היסטוריית השיחות'));
        }

        final sessions = snapshot.data ?? [];

        return ListView.builder(
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[index];
            return ListTile(
              leading: Icon(Icons.chat_bubble_outline),
              title: Text(
                session['title'],
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => onSessionSelected(session['id']),
            );
          },
        );
      },
    );
  }
}
