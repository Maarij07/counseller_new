// lib/home/screens/audio_handler_mobile.dart

import 'dart:io';
import 'dart:convert';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

/// Mobile implementation of AudioHandler using native recording
class AudioHandler {
  final AudioRecorder _recorder = AudioRecorder();
  
  Future<void> startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final path = p.join(dir.path, 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a');
        
        await _recorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path,
        );
        
        print('✅ Mobile recording started: $path');
      } else {
        print('❌ No recording permission');
      }
    } catch (e) {
      print('❌ Error starting mobile recording: $e');
    }
  }

  Future<String> stopAndTranscribe(bool isWeb) async {
    try {
      final path = await _recorder.stop();
      if (path != null) {
        print('✅ Mobile recording stopped: $path');
        
        final bytes = await File(path).readAsBytes();
        final base64Audio = base64Encode(bytes);
        
        return await _transcribeAudio(base64Audio);
      } else {
        print('❌ No recording path received');
        return '';
      }
    } catch (e) {
      print('❌ Error stopping mobile recording: $e');
      return '';
    }
  }

  Future<String> _transcribeAudio(String base64Audio) async {
    try {
      final response = await http.post(
        Uri.parse('https://speech.googleapis.com/v1/speech:recognize?key=AIzaSyAYsKJxeVTFAQabU_suLlcJRVZ7Zbvirvg'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "config": {
            "encoding": "AAC",
            "sampleRateHertz": 44100,
            "languageCode": "he-IL"
          },
          "audio": {"content": base64Audio}
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final transcript = data['results'][0]['alternatives'][0]['transcript'];
          print('✅ Mobile transcription: $transcript');
          return transcript;
        } else {
          print('⚠️ No speech detected in mobile recording');
          return '';
        }
      } else {
        print('❌ Speech API error: ${response.statusCode}');
        return '';
      }
    } catch (e) {
      print('❌ Error transcribing mobile audio: $e');
      return '';
    }
  }
}
