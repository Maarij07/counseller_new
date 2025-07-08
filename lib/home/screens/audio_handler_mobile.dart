// import 'dart:io';
// import 'dart:convert';
// // import 'package:record/record.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:http/http.dart' as http;
// import 'package:path/path.dart' as p;

// class AudioHandler {
// //  final Record _recorder = Record(); // גרסה 4 משתמשת ב־Record() עדיין אך שונה בתפקוד

//   Future<void> startRecording() async {
//     final dir = await getApplicationDocumentsDirectory();
//     final path = p.join(dir.path, 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a');
//     // await _recorder.start(path: path);
//   }

//   Future<String> stopAndTranscribe(bool isWeb) async {
//     // final path = await _recorder.stop();
//     final bytes = await File(path!).readAsBytes();
//     return await _transcribeAudio(base64Encode(bytes));
//   }

//   Future<String> _transcribeAudio(String base64Audio) async {
//     // הכניסי כאן את הקוד שלך לשליחת הבקשה ל־Google Speech-to-Text
//     return "Transcribed text from Desktop";
//   }
// }
// lib/home/screens/audio_handler_mobile.dart

/// גרסה “דמה” של AudioHandler שמחזירה תמיד מחרוזת ריקה (או הודעת דמה).
class AudioHandler {
  Future<void> startRecording() async {
    // לא עושה כלום
  }

  Future<String> stopAndTranscribe(bool isWeb) async {
    // מחזיר תמיד מחרוזת דמה בלי להתעסק בקובץ
    return "";
  }
}
