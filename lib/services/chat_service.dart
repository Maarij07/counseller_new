import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import 'ml_service.dart';

class ChatService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MLService _mlService = MLService();

  // ML API endpoint
  static const String apiUrl = 'http://127.0.0.1:8080/predict';

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    final String currentUserId = _auth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();
    // updating it adding chatId  for 
    final String chatId = _auth.currentUser!.uid;

    try {
      // First, store the message in messages collection
      await _firestore.collection('messages').add({
          'chatId': chatId,
        'text': message,
        'sender': 'user',
        'userId': currentUserId,
        'timestamp': timestamp,
      });

      print('Sending prediction request to ML API...');
      // Then, get prediction from ML API
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'statement': message,
          'userId': currentUserId,
        }),
      );

      print('ML API Response Status: ${response.statusCode}');
      print('ML API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final prediction = jsonDecode(response.body);
        print('Prediction score: ${prediction['prediction']}');
        
        // Store prediction in user_predictions collection
        await _firestore.collection('user_predictions').add({
          'userId': currentUserId,
          'statement': message,
          'predictedScore': prediction['prediction'],
          'timestamp': timestamp,
        });

        // Add prediction response to messages collection
        await _firestore.collection('messages').add({
            'chatId': chatId,
          'text': 'Prediction Score: ${prediction['prediction']}',
          'sender': 'system',
          'userId': currentUserId,
          'timestamp': Timestamp.now(),
        });
      } else {
        print('Failed to get prediction: ${response.body}');
        // Add error message to messages collection
        await _firestore.collection('messages').add({
            'chatId': chatId,

          'text': 'Failed to process message. Please try again.',
          'sender': 'system',
          'userId': currentUserId,
          'timestamp': Timestamp.now(),
        });
      }
    } catch (e) {
      print('Error in sendMessage: $e');
      // updating it Adding currentUserId instead of userId
      final prediction = await _mlService.getPrediction(message, currentUserId);
      // final prediction = await _mlService.getPrediction(message, userId);
      // Add error message to messages collection
      await _firestore.collection('messages').add({
        'text': 'An error occurred while processing your message.',
        'sender': 'system',
        'userId': currentUserId,
        'predictedScore': prediction,
        'timestamp': Timestamp.now(),
      });
    }
  }

  Stream<QuerySnapshot> getMessages() {
    final String currentUserId = _auth.currentUser!.uid;
    return _firestore
        .collection('messages')
        .where('userId', isEqualTo: currentUserId)
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> sendMessageToUser({
    required String userId,
    required String message,
  }) async {
    try {
      final timestamp = Timestamp.now();
      final prediction = await _mlService.getPrediction(message, userId);

      await _firestore.collection('user_predictions').add({
        'userId': userId,
        'text': message,
        'predictedScore': prediction,
        'timestamp': timestamp,
        'sender': 'user',
      });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Stream<List<ChatMessage>> getMessagesForUser(String userId) {
    return _firestore
        .collection('user_predictions')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc))
          .toList();
    });
  }
}



// import 'dart:convert';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:http/http.dart' as http;
// import '../models/chat_message.dart';
// import 'ml_service.dart';

// class ChatService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final MLService _mlService = MLService();

//   // ML API endpoint
//   static const String apiUrl = 'http://127.0.0.1:8080/predict';

//   Future<void> sendMessage(String message) async {
//     if (message.trim().isEmpty) return;

//     final String currentUserId = _auth.currentUser!.uid;
//     final Timestamp timestamp = Timestamp.now();

//     try {
//       // First, send message to Firestore
//       await _firestore.collection('messages').add({
//         'text': message,
//         'sender': 'user',
//         'userId': currentUserId,
//         'timestamp': timestamp,
//       });

//       print('Sending prediction request to ML API...');
//       // Then, get prediction from ML API
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: jsonEncode({
//           'statement': message,
//           'userId': currentUserId,
//         }),
//       );

//       print('ML API Response Status: ${response.statusCode}');
//       print('ML API Response Body: ${response.body}');

//       if (response.statusCode == 200) {
//         final prediction = jsonDecode(response.body);
//         print('Prediction score: ${prediction['prediction']}');
        
//         // Add prediction to local messages collection for immediate feedback
//         await _firestore.collection('messages').add({
//           'text': 'Prediction Score: ${prediction['prediction']}',
//           'sender': 'system',
//           'userId': currentUserId,
//           'timestamp': Timestamp.now(),
//         });
//       } else {
//         print('Failed to get prediction: ${response.body}');
//         // Add error message to chat
//         await _firestore.collection('messages').add({
//           'text': 'Failed to process message. Please try again.',
//           'sender': 'system',
//           'userId': currentUserId,
//           'timestamp': Timestamp.now(),
//         });
//       }
//     } catch (e) {
//       print('Error in sendMessage: $e');
//       // Add error message to chat
//       await _firestore.collection('messages').add({
//         'text': 'An error occurred while processing your message.',
//         'sender': 'system',
//         'userId': currentUserId,
//         'timestamp': Timestamp.now(),
//       });
//     }
//   }

//   Stream<QuerySnapshot> getMessages() {
//     return _firestore
//         .collection('messages')
//         .orderBy('timestamp', descending: false)
//         .snapshots();
//   }

//   Future<void> sendMessageToUser({
//     required String userId,
//     required String message,
//   }) async {
//     try {
//       // First, save the message to Firestore
//       final docRef = await _firestore.collection('messages').add({
//         'userId': userId,
//         'message': message,
//         'timestamp': FieldValue.serverTimestamp(),
//       });

//       // Get prediction from ML service
//       final prediction = await _mlService.getPrediction(message, userId);

//       // Update the document with the prediction
//       await docRef.update({
//         'predictionScore': prediction,
//       });
//     } catch (e) {
//       throw Exception('Failed to send message: $e');
//     }
//   }

//   Stream<List<ChatMessage>> getMessagesForUser(String userId) {
//     return _firestore
//         .collection('messages')
//         .where('userId', isEqualTo: userId)
//         .orderBy('timestamp', descending: true)
//         .snapshots()
//         .map((snapshot) {
//       return snapshot.docs
//           .map((doc) => ChatMessage.fromFirestore(doc))
//           .toList();
//     });
//   }
// } 