import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecorder {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String? _filePath;

  Future<void> initialize() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
  }

  Future<void> startRecording() async {
    _filePath = 'path_to_save_the_recording.aac';
    await _recorder.startRecorder(toFile: _filePath);
    _isRecording = true;
  }

  Future<void> stopRecording() async {
    await _recorder.stopRecorder();
    _isRecording = false;
  }

  bool get isRecording => _isRecording;
}
