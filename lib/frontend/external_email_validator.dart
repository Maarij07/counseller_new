import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ExternalEmailValidator {
  /// מחזיר true אם הפורמט תקין ויש שרת SMTP תקין.
  static Future<bool> validate(String email) async {
    // קבלת המפתח מתוך ה-.env
const apiKey = String.fromEnvironment('ABSTRACTAPI_KEY');
if (apiKey.isEmpty) {
  throw Exception('Missing API key! Pass it via --dart-define.');
}
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
        'API key not found! Make sure .env loaded and contains ABSTRACTAPI_KEY.'
      );
    }

    final uri = Uri.https(
      'emailvalidation.abstractapi.com',
      '/v1/',
      {
        'api_key': apiKey,
        'email': email.trim(),
      },
    );

    try {
      final response = await http
        .get(uri)
        .timeout(const Duration(seconds: 5), onTimeout: () => throw Exception('Timeout'));

      if (response.statusCode != 200) return false;

      final data = json.decode(response.body);
      final formatOk = data['is_valid_format']['value'] as bool? ?? false;
      final smtpOk   = data['is_smtp_valid']['value']   as bool? ?? false;
      return formatOk && smtpOk;
    } catch (_) {
      return false;
    }
  }
}
