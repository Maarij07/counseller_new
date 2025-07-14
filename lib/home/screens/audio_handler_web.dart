// lib/home/screens/audio_handler_web.dart
// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:http/http.dart' as http;

/// Web implementation of AudioHandler using MediaRecorder API
class AudioHandler {
  html.MediaRecorder? _mediaRecorder;
  html.MediaStream? _stream;
  List<html.Blob> _audioChunks = [];

  Future<void> startRecording() async {
    try {
      _stream = await html.window.navigator.mediaDevices!
          .getUserMedia({'audio': true});
      _mediaRecorder = html.MediaRecorder(_stream!);
      _audioChunks = [];

      _mediaRecorder!.addEventListener('dataavailable', (event) {
        final blob = (event as html.BlobEvent).data;
        if (blob != null) _audioChunks.add(blob);
      });

      _mediaRecorder!.start();
      print('✅ Web recording started');
    } catch (e) {
      print('❌ Error starting web recording: $e');
    }
  }

  Future<String> stopAndTranscribe(bool isWeb) async {
    try {
      final completer = Completer<html.Blob>();

      _mediaRecorder!.addEventListener('stop', (_) {
        completer.complete(html.Blob(_audioChunks));
      });

      _mediaRecorder!.stop();
      _stream?.getTracks().forEach((track) => track.stop());

      final blob = await completer.future;
      final reader = html.FileReader();
      reader.readAsArrayBuffer(blob);
      await reader.onLoad.first;
      final bytes = reader.result as List<int>;
      
      print('✅ Web recording stopped, transcribing...');
      return await _transcribeAudio(base64Encode(bytes));
    } catch (e) {
      print('❌ Error stopping web recording: $e');
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
          final transcript = data['results'][0]['alternatives'][0]['transcript'];
          print('✅ Web transcription: $transcript');
          return transcript;
        } else {
          print('⚠️ No speech detected in web recording');
          return '';
        }
      } else {
        print('❌ Speech API error: ${response.statusCode}');
        return '';
      }
    } catch (e) {
      print('❌ Error transcribing web audio: $e');
      return '';
    }
  }
}
