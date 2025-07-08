import 'dart:async';

Future<Map<String, dynamic>> sendToMLModel(String text) async {
  await Future.delayed(Duration(milliseconds: 500)); // מדמה עיבוד
  return {'result': '✅ קיבלתי את ההודעה: $text'};
}
