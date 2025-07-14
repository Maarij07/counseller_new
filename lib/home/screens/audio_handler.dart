// 📄 קובץ: lib/home/screens/audio_handler.dart

// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:io';
import 'dart:html' as html;
import 'package:record/record.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'dart:async';
// ודא שאתה משתמש בגרסה העדכנית ביותר

class AudioHandler {
final AudioRecorder _recorder = AudioRecorder();
  html.MediaRecorder? _mediaRecorder;
  html.MediaStream? _stream;
  List<html.Blob> _audioChunks = [];

  Future<void> startRecording() async {
    if (kIsWeb) {
      final stream = await html.window.navigator.mediaDevices!.getUserMedia({'audio': true});
      _mediaRecorder = html.MediaRecorder(stream);
      _audioChunks = [];
      _mediaRecorder!.addEventListener('dataavailable', (event) {
        final blob = (event as html.BlobEvent).data;
        if (blob != null) _audioChunks.add(blob);
      });
      _mediaRecorder!.start();
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final path = p.join(dir.path, 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a');
await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc), // חובה
      path: path,
    );    }
  }

  Future<String> stopAndTranscribe(bool isWeb) async {
    if (isWeb) {
      final completer = Completer<html.Blob>();
      _mediaRecorder!.addEventListener('stop', (_) {
        completer.complete(html.Blob(_audioChunks));
      });
      _mediaRecorder!.stop();
      _stream?.getTracks().forEach((track) => track.stop());  // ← תיקון כאן!

      final blob = await completer.future;
      final reader = html.FileReader();
      reader.readAsArrayBuffer(blob);
      await reader.onLoad.first;
      final bytes = reader.result as List<int>;
      return await _transcribeAudio(base64Encode(bytes));
    } else {
      final path = await _recorder.stop();
      final bytes = await File(path!).readAsBytes();
      return await _transcribeAudio(base64Encode(bytes));
    }
  }

  Future<String> _transcribeAudio(String base64Audio) async {
    final response = await http.post(
      Uri.parse('https://speech.googleapis.com/v1/speech:recognize?key=AIzaSyAYsKJxeVTFAQabU_suLlcJRVZ7Zbvirvg'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "config": {
          "encoding": "WEBM_OPUS",
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