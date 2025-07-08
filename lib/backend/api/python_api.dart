// 📄 lib/services/python_api.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class PythonAPI {
  static const String _baseUrl = 'http://127.0.0.1:5000';

  static Future<String> sendEcho(String message) async {
    final url = Uri.parse('$_baseUrl/echo');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"text": message}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["response"];
    } else {
      throw Exception("❌ Failed to connect to Flask server");
    }
  }
}
