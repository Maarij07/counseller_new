// lib/home/screens/browser_speech_service_stub.dart

/// Stub implementation for browser speech service on non-web platforms
class BrowserSpeechService {
  bool _isInitialized = false;
  
  Future<void> initialize() async {
    print("⚠️ Browser Speech Service not available on this platform");
    _isInitialized = false;
  }
  
  Future<bool> startRecording() async {
    print("❌ Browser Speech Service not available on this platform");
    return false;
  }
  
  Future<String?> stopRecordingAndTranscribe() async {
    print("❌ Browser Speech Service not available on this platform");
    return null;
  }
  
  bool get isRecording => false;
  bool get isInitialized => _isInitialized;
  
  void dispose() {
    print("🗑️ Browser Speech Service disposed (stub)");
  }
}
