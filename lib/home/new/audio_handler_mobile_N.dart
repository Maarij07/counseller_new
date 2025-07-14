// ignore_for_file: file_names, avoid_renaming_method_parameters

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:phychological_counselor/home/screens/audio_handler_web.dart';
import 'package:record/record.dart';
import 'package:http/http.dart' as http;

class AudioHandlerMobile extends AudioHandler {
  final AudioRecorder _recorder = AudioRecorder();
  String? _filePath;

  @override
  Future<void> startRecording() async {
    final dir = await getApplicationDocumentsDirectory();
    _filePath =
        p.join(dir.path, 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a');

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: _filePath!,
    );
  }

  @override
  Future<String> stopAndTranscribe(bool someFlag) async {
    final path = await _recorder.stop();
    final bytes = await File(path!).readAsBytes();
    return await _transcribeAudio(base64Encode(bytes));
  }

  Future<String> _transcribeAudio(String base64Audio) async {
    final response = await http.post(
      Uri.parse(
          'https://speech.googleapis.com/v1/speech:recognize?key=AIzaSyAYsKJxeVTFAQabU_suLlcJRVZ7Zbvirvg'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "config": {
          "encoding": "WEBM_OPUS", // ← You may want to change this to "AAC" for mobile
          "sampleRateHertz": 48000,
          "languageCode": "he-IL"
        },
        "audio": {"content": base64Audio}
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        return data['results'][0]['alternatives'][0]['transcript'];
      } else {
        return "לא זוהתה הודעה קולית.";
      }
    } else {
      return "שגיאה בהמרת קול לטקסט.";
    }
  }
}
