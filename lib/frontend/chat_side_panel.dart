// // lib/frontend/chat_side_panel.dart

// import 'package:flutter/material.dart';
// import 'package:phychological_counselor/frontend/chat_history_panel.dart';

// typedef OnNewConversation = void Function();
// typedef OnSearch = void Function();

// class ChatSidePanel extends StatelessWidget {
//   final bool isOpen;
//   final VoidCallback onClose;
//   final OnNewConversation onNewConversation;
//   final OnSearch onSearch;

//   static const double panelWidth = 240.0;

//   const ChatSidePanel({
//     Key? key,
//     required this.isOpen,
//     required this.onClose,
//     required this.onNewConversation,
//     required this.onSearch,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedPositioned(
//       duration: const Duration(milliseconds: 250),
//       curve: Curves.easeInOut,
//       // כאשר isOpen == true, הצמד ל־left=0; אחרת משוך את הכל שמאלה עד הסתרה (-panelWidth)
//       left: isOpen ? 0 : -panelWidth,
//       top: 0,
//       bottom: 0,
//       width: panelWidth,
//       child: Material(
//         elevation: 4,
//         color: Colors.grey[100],
//         child: SafeArea(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // כותרת עליונה עם כפתור לסגירה
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 child: Row(
//                   children: [
//                     // const Text(
//                     //   'Chat Panel',
//                     //   style: TextStyle(
//                     //     fontSize: 18,
//                     //     fontWeight: FontWeight.bold,
//                     //   ),
//                     // ),
//                     const Spacer(),
//                     IconButton(
//                       icon: const Icon(Icons.close),
//                       onPressed: onClose,
//                    //   tooltip: 'Close Panel',
//                     ),
//                   ],
//                 ),
//               ),
//               const Divider(height: 1),

//               const SizedBox(height: 12),

//               // כפתור New Conversation
//               ListTile(
//               //  leading: const Icon(Icons.add_comment_outlined),
//                               leading: const Icon(Icons.search_outlined),

//  title: const Text(
//     'Search',
//     style: TextStyle(
//       fontSize: 14, // גודל קטן יותר; אפשר לשנות לפי הצורך
//     ),
//   ),                onTap: onNewConversation,
//               ),
//               const SizedBox(height: 6),

//               // כפתור Search
//               ListTile(
//                // leading: const Icon(Icons.search_outlined),
//                                 leading: const Icon(Icons.add_comment_outlined),

//  title: const Text(
//     'New Conversation',
//     style: TextStyle(
//       fontSize: 14, // גודל קטן יותר; אפשר לשנות לפי הצורך
//     ),
//   ),                onTap: onSearch,
//               ),
//               const SizedBox(height: 6),

//               const Divider(height: 1),
              
//               // כאן אפשר בעתיד להוסיף את ההיסטוריה, כרגע ריק או טקסט זמני
//              Expanded(
//   child: ChatHistoryPanel(),
// ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
// 📁 lib/frontend/chat_side_panel.dart
import 'package:flutter/material.dart';
import 'package:phychological_counselor/frontend/chat_history_panel.dart';

typedef OnNewConversation = void Function();
typedef OnSearch = void Function();

class ChatSidePanel extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onClose;
  final OnNewConversation onNewConversation;
  final OnSearch onSearch;
  final void Function(String chatId) onChatSelected;

  static const double panelWidth = 240.0;

  const ChatSidePanel({
    super.key,
    required this.isOpen,
    required this.onClose,
    required this.onNewConversation,
    required this.onSearch,
    required this.onChatSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      left: isOpen ? 0 : -panelWidth,
      top: 0,
      bottom: 0,
      width: panelWidth,
      child: Material(
        elevation: 4,
        color: Colors.grey[100],
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: onClose,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.search_outlined),
                title: const Text('Search', style: TextStyle(fontSize: 14)),
                onTap: onSearch,
              ),
              const SizedBox(height: 6),
              ListTile(
                leading: const Icon(Icons.add_comment_outlined),
                title:
                    const Text('New Conversation', style: TextStyle(fontSize: 14)),
                onTap: onNewConversation,
              ),
              const SizedBox(height: 6),
              const Divider(height: 1),
              Expanded(child: ChatHistoryPanel(onChatSelected: onChatSelected)),
            ],
          ),
        ),
      ),
    );
  }
}
