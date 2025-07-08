import 'dart:html' as html;
import 'dart:convert';
import 'dart:async';

class AudioHandler {
  html.MediaRecorder? _mediaRecorder;
  late html.MediaStream _stream;
  final List<html.Blob> _audioChunks = [];

  Future<void> startRecording() async {
    _stream = await html.window.navigator.mediaDevices!.getUserMedia({'audio': true});
    _mediaRecorder = html.MediaRecorder(_stream);
    _audioChunks.clear();

    _mediaRecorder!.addEventListener('dataavailable', (event) {
      final blob = (event as html.BlobEvent).data;
      if (blob != null) _audioChunks.add(blob);
    });

    _mediaRecorder!.start();
  }

  Future<String> stopAndTranscribe(bool isWeb) async {
    final completer = Completer<html.Blob>();

    _mediaRecorder!.addEventListener('stop', (_) {
      completer.complete(html.Blob(_audioChunks));
    });

    _mediaRecorder!.stop();
    _stream.getTracks().forEach((track) => track.stop());

    final blob = await completer.future;
    final reader = html.FileReader();
    reader.readAsArrayBuffer(blob);
    await reader.onLoad.first;

    final bytes = reader.result as List<int>;
    return await _transcribeAudio(base64Encode(bytes));
  }

  Future<String> _transcribeAudio(String base64Audio) async {
    // הכניסי כאן את הקוד שלך לשליחת הבקשה ל־Google Speech-to-Text
    return "Transcribed text from Web";
  }
}
