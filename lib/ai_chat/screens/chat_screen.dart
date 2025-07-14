import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../data/services/gpt_service.dart';
import '../provider/chat_provider.dart';
import '../widgets/build_message.dart';
import '../widgets/chat_text_field.dart';
import '../widgets/scroller.dart';

import '../widgets/send_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildInputField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Column(
        children: [
          SizedBox(height: 5.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ChatTextField(controller: _controller, onSubmitted: _sendMessage,
),
              SizedBox(width: 10.w),
              SendButton(
                path: 'send',
                onTap: () {
                  if (_controller.text.isNotEmpty) {
                    FocusScope.of(context).unfocus();
                    _sendMessage(_controller.text);
                  }
                },
                isLoading: _isLoading,
              ),
            ],
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: chatProvider.messages.length,
              itemBuilder: (context, index) =>
                  buildMessage(chatProvider.messages[index], context),
            ),
          ),
          _buildInputField(),
        ],
      ),
    );
  }

  Future<void> _sendMessage(String message) async {
  if (message.trim().isEmpty) return;

  final chatProvider = Provider.of<ChatProvider>(context, listen: false);
  print("📨 Sending user message: $message");

  chatProvider.addMessage("user", message);
  await saveMessageToFirestore("user", message);

  setState(() {
    _isLoading = true;
  });

  _controller.clear();
  scrollToBottom(_scrollController);

  final response = await getGPTResponse(message, '23');
  print("🤖 GPT responded: $response");

  if (response != null && response.isNotEmpty) {
    chatProvider.addMessage("gpt", response);
    await saveMessageToFirestore("gpt", response);
  } else {
    chatProvider.addMessage("gpt", "⚠️ No response from GPT.");
  }

  setState(() {
    _isLoading = false;
  });

  scrollToBottom(_scrollController);
}
// ✅ שומר את ההודעה ב-Firestore
Future<void> saveMessageToFirestore(String sender, String text) async {
  try {
    print("🟡 Saving message: $sender: $text");

    await FirebaseFirestore.instance.collection('messages').add({
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