// import 'dart:convert';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/foundation.dart';

// class SpeechService {
//   final FlutterTts _flutterTts = FlutterTts();

//   Future<void> speak(String text) async {
//     await _flutterTts.setLanguage("he-IL");
//     await _flutterTts.setPitch(1.0);
//     await _flutterTts.speak(text);
//   }

//   Future<String?> getGPTResponse(String userMessage, String threadId) async {
//     final apiKey = kIsWeb ? "your-api-key-here" : dotenv.env['API_KEY'];
//     final url = Uri.parse("https://api.openai.com/v1/chat/completions");

//     if (!_conversationMap.containsKey(threadId)) {
//       _initializeThread(threadId);
//     }

//     // Optional: call Python backend first
//     String score = "N/A";
//     try {
//       final backendResponse = await http.post(
//         Uri.parse("http://127.0.0.1:5000/predict"),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({"userId": threadId, "statement": userMessage}),
//       );
//       if (backendResponse.statusCode == 200) {
//         final decoded = jsonDecode(backendResponse.body);
//         score = decoded['meanCAVE'].toString();
//       }
//     } catch (e) {
//       print("⚠️ Error calling Python backend: $e");
//     }

//     _conversationMap[threadId]!.add({
//       'role': 'user',
//       'content': "Statement: $userMessage\nPredicted meanCAVE: $score"
//     });

//     _trimMessageHistory(_conversationMap[threadId]!);

//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $apiKey',
//         },
//         body: jsonEncode({
//           'model': 'gpt-3.5-turbo',
//           'messages': _conversationMap[threadId],
//           'max_tokens': 1500,
//           'temperature': 0.3,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final jsonResponse = jsonDecode(response.body);
//         final gptResponse = _cleanText(
//           jsonResponse['choices'][0]['message']['content'].trim(),
//         );
//         _conversationMap[threadId]!.add({'role': 'assistant', 'content': gptResponse});
//         return gptResponse;
//       } else {
//         return "⚠️ GPT error: ${response.statusCode}";
//       }
//     } catch (error) {
//       print("❌ Exception in getGPTResponse: $error");
//       return "An error occurred.";
//     }
//   }
//   final String systemPrompt = "👋 Hi {NAME}, I'm Hewar, an AI-based assistant designed to help you deeply understand and process the negative events and situations you encounter in daily life. In our conversations, we'll try to break down and analyze these situations and identify thinking patterns in a way that helps you expand your perspective on negative life experiences.";
  
//   SpeechService(this.systemPrompt);
  
//   final List<Map<String, String>> _baseSystemPrompt = [
//     {
//       'role': 'system',
//       'content': systemPrompt,
//     }
//   ];

//   final Map<String, List<Map<String, String>>> _conversationMap = {};

//   void _initializeThread(String threadId, [List<Map<String, String>>? previousMessages]) {
//     _conversationMap[threadId] = List<Map<String, String>>.from(_baseSystemPrompt);
//     if (previousMessages != null) {
//       _conversationMap[threadId]!.addAll(previousMessages);
//     }
//   }

//   void _trimMessageHistory(List<Map<String, String>> history) {
//     const maxMessages = 10;
//     if (history.length > maxMessages) {
//       history.removeRange(1, history.length - (maxMessages - 1));
//     }
//   }

//   String _cleanText(String text) {
//     return utf8.decode(text.runes.toList());
//   }
// }

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class SpeechService {
  final FlutterTts _flutterTts = FlutterTts();

  final String _systemPrompt = '''
Hello {NAME},  
I'm Hewar, I'm Hewar, I'm Hewar, an AI-based chatbot designed to help you deeply understand and process negative events and situations in your daily life.  
We’ll explore what happened, why it triggered certain emotions, and uncover patterns in your thinking, to help you view things from new perspectives and feel differently.
Please your name
Please try to keep your answers short and focused, ask just one question every reply, just a few sentences are enough. This will help us move through the conversation smoothly and effectively.
First Conversation, Getting Started  
What event would you like to talk about today?  
Please describe a real, recent, personal event that keeps coming to your mind, not something general or you read about, the answers should be short and focused, ask just one question every reply.  
It can be a conflict, a sense of failure, disagreement, or even something small that felt hurtful. If it’s bothering you, it matters.


Let’s reflect with a few more questions:

– Do you keep ruminating about what happened?  
– Do you often ask yourself “Why am I always like this?”  
– Do you find it hard to release past negative events?  
– Have you ever blamed yourself for something that turned out **not** to be your fault?  
– If a friend went through the same thing — what would you tell them?

---

📌 Summary and Insight  
- the answers should be short and focused, ask just one question every reply
– How do you feel now compared to the beginning of our chat?  
– Did anything new come up during this conversation?  
– Is there an insight or thought you’d like to carry forward?

---

🧩 Conversation Structure:  
• small clear replies with just one question
• Gathering event details and interpretation  
• Emotional reflection  
• Evaluating cause and confidence  
• Attribution style (internal/external, stable/temporary, global/specific)  
• Challenging negative thinking  
• Exploring alternatives  
• Encouraging action  
• Checking emotional or cognitive change  
''';


  final Map<String, List<Map<String, String>>> _conversationMap = {};

  List<Map<String, String>> get _baseSystemPrompt => [
        {
          'role': 'system',
          'content': _systemPrompt,
        }
      ];

  Future<void> speak(String text) async {
    await _flutterTts.setLanguage("he-IL");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  Future<String?> getGPTResponse(String userMessage, String threadId) async {
    final apiKey = kIsWeb ? "your-api-key-here" : dotenv.env['API_KEY'];
    final url = Uri.parse("https://api.openai.com/v1/chat/completions");

    if (!_conversationMap.containsKey(threadId)) {
      _initializeThread(threadId);
    }

    // Optional: call Python backend first
    String score = "N/A";
    try {
      final backendResponse = await http.post(
        Uri.parse("http://127.0.0.1:5000/predict"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": threadId, "statement": userMessage}),
      );
      if (backendResponse.statusCode == 200) {
        final decoded = jsonDecode(backendResponse.body);
        score = decoded['meanCAVE'].toString();
      }
    } catch (e) {
      print("⚠️ Error calling Python backend: $e");
    }

    _conversationMap[threadId]!.add({
      'role': 'user',
      'content': "Statement: $userMessage\nPredicted meanCAVE: $score"
    });

    _trimMessageHistory(_conversationMap[threadId]!);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': _conversationMap[threadId],
          'max_tokens': 1500,
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final gptResponse = _cleanText(
          jsonResponse['choices'][0]['message']['content'].trim(),
        );
        _conversationMap[threadId]!.add({'role': 'assistant', 'content': gptResponse});
        return gptResponse;
      } else {
        return "⚠️ GPT error: ${response.statusCode}";
      }
    } catch (error) {
      print("❌ Exception in getGPTResponse: $error");
      return "An error occurred.";
    }
  }

  void _initializeThread(String threadId, [List<Map<String, String>>? previousMessages]) {
    _conversationMap[threadId] = List<Map<String, String>>.from(_baseSystemPrompt);
    if (previousMessages != null) {
      _conversationMap[threadId]!.addAll(previousMessages);
    }
  }

  void _trimMessageHistory(List<Map<String, String>> history) {
    const maxMessages = 10;
    if (history.length > maxMessages) {
      history.removeRange(1, history.length - (maxMessages - 1));
    }
  }

  String _cleanText(String text) {
    return utf8.decode(text.runes.toList());
  }
}
