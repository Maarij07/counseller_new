import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createNewChatSession(String userId, String? title) async {
    final newChatRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc();

    await newChatRef.set({
      'title': title ?? 'שיחה חדשה',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return newChatRef.id;
  }

  Future<void> saveMessageToChat(
      String userId, String chatId, String sender, String text) async {
    final messagesRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(chatId)
        .collection('messages');

    await messagesRef.add({
      'sender': sender,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> getUserChats(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return {
                'chatId': doc.id,
                'title': doc['title'],
                'createdAt': doc['createdAt'],
              };
            }).toList());
  }

  Stream<List<Map<String, dynamic>>> getChatMessages(String userId, String chatId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return {
                'text': doc['text'],
                'sender': doc['sender'],
                'timestamp': doc['timestamp'],
              };
            }).toList());
  }
}
