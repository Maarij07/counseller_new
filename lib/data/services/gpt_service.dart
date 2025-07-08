import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// 1) Base system prompt to enforce psychiatry domain
final String _systemPrompt = '''
Hello {NAME},  
I'm Hewar, I'm Hewar, I'm Hewar, an AI-based chatbot designed to help you deeply understand and process negative events and situations in your daily life.  
We’ll explore what happened, why it triggered certain emotions, and uncover patterns in your thinking, to help you view things from new perspectives and feel differently.
Please your name
Please try to keep your answers short and focused, ask just one question every reply, just a few sentences are enough. This will help us move through the conversation smoothly and effectively.
First Conversation, Getting Started  
What event would you like to talk about today?  
Please describe a real, recent, personal event that keeps coming to your mind, not something general or you read about.  
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

final List<Map<String, String>> baseSystemPrompt = [
  {
    'role': 'system',
    'content': _systemPrompt
  }
];

final Map<String, List<Map<String, String>>> conversationMap = {};

void initializeThread(String threadId, [List<Map<String, String>>? previousMessages]) {
  if (!conversationMap.containsKey(threadId)) {
    conversationMap[threadId] = List<Map<String, String>>.from(baseSystemPrompt);

    if (previousMessages != null && previousMessages.isNotEmpty) {
      conversationMap[threadId]!.addAll(previousMessages);
    }
  }
}

Future<String?> getGPTResponse(String userMessage, String threadId) async {
  final apiKey = dotenv.env['API_KEY'];
  final url = Uri.parse("https://api.openai.com/v1/chat/completions");

  if (!conversationMap.containsKey(threadId)) {
    initializeThread(threadId);
  }

  conversationMap[threadId]!.add({'role': 'user', 'content': userMessage});
  trimMessageHistory(conversationMap[threadId]!);

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4',
        'messages': conversationMap[threadId],
        'max_tokens': 1500,
        'temperature': 0.3,
        'top_p': 0.9,
      }),
    );

    // ✅ הדפסות לזיהוי תקשורת עם OpenAI
    print("📱 Response status: \${response.statusCode}");
    print("📩 Response body: \${response.body}");

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final gptResponse = cleanText(
        jsonResponse['choices'][0]['message']['content'].trim(),
      );
// print("📤 שולח שאלה ל-GPT...");
// print("🧵 מזהה thread: $threadId");
// print("📝 תוכן ההודעה: $userMessage");

      conversationMap[threadId]!.add({'role': 'assistant', 'content': gptResponse});

      return gptResponse;
    } else {

      if (response.statusCode == 403) {
        return "Access to the requested model is restricted. Please check your account.";
      }
      return "I'm having trouble responding right now.";
    }
  } catch (error) {
    print("❌ Error: \$error");
    return "An error occurred. Please try again.";
  }
}

// Limits stored messages to avoid exceeding token limits
void trimMessageHistory(List<Map<String, String>> messageHistory) {
  const maxMessages = 10;
  if (messageHistory.length > maxMessages) {
    messageHistory.removeRange(1, messageHistory.length - (maxMessages - 1));
  }
}

// Utility to clean text (handle any encoding issues)
String cleanText(String text) {
  return utf8.decode(text.runes.toList());
}
