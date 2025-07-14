// lib/home/screens/audio_handler_stub.dart

/// Stub implementation for unsupported platforms
class AudioHandler {
  Future<void> startRecording() async {
    throw UnsupportedError('Audio recording not supported on this platform');
  }

  Future<String> stopAndTranscribe(bool isWeb) async {
    throw UnsupportedError('Audio recording not supported on this platform');
  }
}
