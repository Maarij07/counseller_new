// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';

// // class ChatHistoryPanel extends StatelessWidget {
// //   const ChatHistoryPanel({super.key});

// //   Future<List<String>> fetchChatTitlesForUser() async {
// //     final currentUser = FirebaseAuth.instance.currentUser;
// //     if (currentUser == null) return [];

// //     final querySnapshot = await FirebaseFirestore.instance
// //         .collection('chat_sessions')
// //         .where('userId', isEqualTo: currentUser.uid)
// //         .get();

// //     // שליפה של כל הכותרות
// //     return querySnapshot.docs
// //         .map((doc) => doc['title'] as String? ?? '(ללא כותרת)')
// //         .toList();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return FutureBuilder<List<String>>(
// //       future: fetchChatTitlesForUser(),
// //       builder: (context, snapshot) {
// //         if (snapshot.connectionState == ConnectionState.waiting) {
// //           return const Center(child: CircularProgressIndicator());
// //         }

// //         if (snapshot.hasError) {
// //           return Center(child: Text('שגיאה: ${snapshot.error}'));
// //         }

// //         final titles = snapshot.data ?? [];

// //         if (titles.isEmpty) {
// //           return const Center(
// //             child: Text(
// //               'אין שיחות להצגה עדיין.',
// //               style: TextStyle(color: Colors.grey),
// //             ),
// //           );
// //         }

// //         return ListView.builder(
// //           itemCount: titles.length,
// //           itemBuilder: (context, index) {
// //             return ListTile(
// //               leading: const Icon(Icons.chat_bubble_outline),
// //               title: Text(
// //                 titles[index],
// //                 style: const TextStyle(fontSize: 14),
// //               ),
// //               onTap: () {
// //                 // בעתיד – ניתן להוסיף ניווט לפי chatId וכו'
// //               },
// //             );
// //           },
// //         );
// //       },
// //     );
// //   }
// // }
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class ChatHistoryPanel extends StatelessWidget {
//   const ChatHistoryPanel({super.key});

//   // פונקציה שמביאה רשימת שיחות עם כותרת + ההודעה האחרונה
//   Future<List<Map<String, String>>> fetchChatTitlesWithMessages() async {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) return [];

//     final querySnapshot = await FirebaseFirestore.instance
//         .collection('chat_sessions')
//         .where('userId', isEqualTo: currentUser.uid)
//         .get();

//     List<Map<String, String>> results = [];

//     for (var doc in querySnapshot.docs) {
//       final data = doc.data() as Map<String, dynamic>;
//       final chatId = data['chatId']?.toString() ?? '';
//       final title = data['title']?.toString() ?? '(ללא כותרת)';

//       String messageText = '';

//       if (chatId.isNotEmpty) {
//         // חיפוש הודעה אחרונה באותה שיחה
//         final messageSnapshot = await FirebaseFirestore.instance
//             .collection('messages')
//             .where('chatId', isEqualTo: chatId)
//             .orderBy('timestamp', descending: true) // true = הודעה אחרונה
//             .limit(1)
//             .get();

//         if (messageSnapshot.docs.isNotEmpty) {
//           final messageData = messageSnapshot.docs.first.data() as Map<String, dynamic>;
//           messageText = messageData['text']?.toString() ?? '';
//         }
//       }

//       results.add({
//         'title': title,
//         'message': messageText,
//       });
//     }

//     return results;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<Map<String, String>>>(
//       future: fetchChatTitlesWithMessages(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (snapshot.hasError) {
//           return Center(child: Text('שגיאה: ${snapshot.error}'));
//         }

//         final items = snapshot.data ?? [];

//         if (items.isEmpty) {
//           return const Center(
//             child: Text(
//               'אין שיחות להצגה עדיין.',
//               style: TextStyle(color: Colors.grey),
//             ),
//           );
//         }

//         return ListView.builder(
//           itemCount: items.length,
//           itemBuilder: (context, index) {
//             final title = items[index]['title']!;
//             final message = items[index]['message'] ?? '';

//             return ListTile(
//               leading: const Icon(Icons.chat_bubble_outline),
//               title: Text(
//                 title,
//                 style: const TextStyle(fontSize: 14),
//               ),
//               subtitle: Text(
//                 message,
//                 style: const TextStyle(fontSize: 12, color: Colors.black54),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               onTap: () {
//                 // כאן אפשר לטעון שיחה מחדש לפי chatId אם תוסיפי אותו למפה
//               },
//             );
//           },
//         );
//       },
//     );
//   }
// }
// 📁 lib/frontend/chat_history_panel.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatHistoryPanel extends StatelessWidget {
  final void Function(String chatId) onChatSelected;

  const ChatHistoryPanel({super.key, required this.onChatSelected});

  Future<List<Map<String, String>>> fetchChatTitlesWithMessages() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return [];

    final querySnapshot = await FirebaseFirestore.instance
        .collection('chat_sessions')
        .where('userId', isEqualTo: currentUser.uid)
        .get();

    List<Map<String, String>> results = [];

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final chatId = data['chatId']?.toString() ?? '';
      final title = data['title']?.toString() ?? '(ללא כותרת)';

      String messageText = '';

      if (chatId.isNotEmpty) {
        final messageSnapshot = await FirebaseFirestore.instance
            .collection('messages')
            .where('chatId', isEqualTo: chatId)
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        if (messageSnapshot.docs.isNotEmpty) {
          final messageData =
              messageSnapshot.docs.first.data();
          messageText = messageData['text']?.toString() ?? '';
        }
      }

      results.add({
        'title': title,
        'message': messageText,
        'chatId': chatId,
      });
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, String>>>(
      future: fetchChatTitlesWithMessages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('שגיאה: ${snapshot.error}'));
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return const Center(
            child: Text(
              'אין שיחות להצגה עדיין.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final title = items[index]['title']!;
            final message = items[index]['message'] ?? '';
            final chatId = items[index]['chatId']!;

            return ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: Text(title, style: const TextStyle(fontSize: 14)),
              subtitle: Text(
                message,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => onChatSelected(chatId),
            );
          },
        );
      },
    );
  }
}