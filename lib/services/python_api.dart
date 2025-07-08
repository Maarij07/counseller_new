import 'package:http/http.dart' as http;

class PythonAPI {
  static const String baseUrl = 'http://127.0.0.1:5000';

  static Future<String> sendEcho(String message) async {
    final url = Uri.parse('$baseUrl/echo');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: '{"message": "$message"}',
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('❌ Failed to connect to Python server');
    }
  }
}
