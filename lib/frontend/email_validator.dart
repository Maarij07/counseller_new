import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

Future<bool> isExistingEmailMailboxlayer(String email) async {
  const accessKey = 'b5365a087f675230c0190a8cb9f9282a';

  // שים לב: smtp=1 ו־format=1 הם הפרמטרים הנחוצים לבדיקה מלאה ולקבלת JSON
  final url = Uri.parse(
    'http://apilayer.net/api/check'
    '?access_key=$accessKey'
    '&email=$email'
    '&smtp=1'
    '&format=1'
  );

  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final formatValid = data['format_valid'] == true;
    final smtpValid = data['smtp_check'] == true;
    return formatValid && smtpValid;
  } else {
    throw Exception('Mailboxlayer API error: HTTP ${response.statusCode}');
  }
}

Future<bool> isRealEmail(String email) async {
  final apiKey = 'b5365a087f675230c0190a8cb9f9282a';
  final url = Uri.parse('https://emailvalidation.abstractapi.com/v1/?api_key=$apiKey&email=$email');

  final response = await http.get(url);
  debugPrint('🔍 AbstractAPI respond status: ${response.statusCode}');
  debugPrint('🔍 AbstractAPI respond body: ${response.body}');

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print("Response: $data");

    return data['deliverability'] == 'DELIVERABLE' &&
           data['is_valid_format']['value'] == true &&
           data['is_disposable_email']['value'] == false &&
           data['is_smtp_valid']['value'] == true;
  } else {
    throw Exception('Failed to validate email');
  }
}
