// 📄 קובץ: lib/home/screens/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static Future<void> saveMessage(String userId, String sender, String text) async {
    try {
      await FirebaseFirestore.instance.collection('messages').add({
        'userId': userId,
        'sender': sender,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("✅ Message saved to Firestore");
    } catch (e) {
      print("❌ Firestore save failed: $e");
    }
  }
}
