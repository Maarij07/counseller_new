// lib/home/screens/browser_speech_service_mobile.dart

import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Mobile implementation of browser speech service using native speech recognition
class BrowserSpeechService {
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _isRecording = false;
  String _lastRecognizedText = '';
  
  Future<void> initialize() async {
    try {
      bool available = await _speech.initialize(
        onStatus: (val) => print('Speech status: $val'),
        onError: (val) => print('Speech error: $val'),
      );
      
      if (available) {
        _isInitialized = true;
        print("✅ Mobile Speech Service initialized");
      } else {
        print("❌ Mobile Speech Service not available");
      }
    } catch (e) {
      print("❌ Error initializing Mobile Speech Service: $e");
    }
  }
  
  Future<bool> startRecording() async {
    if (!_isInitialized) {
      print("❌ Mobile Speech Service not initialized");
      return false;
    }
    
    try {
      _lastRecognizedText = '';
      await _speech.listen(
        onResult: (val) {
          _lastRecognizedText = val.recognizedWords;
          print("📝 Mobile speech result: $_lastRecognizedText");
        },
        listenFor: Duration(seconds: 10),
        pauseFor: Duration(seconds: 3),
        partialResults: false,
        localeId: 'en-US',
      );
      
      _isRecording = true;
      print("🎤 Mobile speech recording started");
      return true;
    } catch (e) {
      print("❌ Error starting mobile speech recording: $e");
      return false;
    }
  }
  
  Future<String?> stopRecordingAndTranscribe() async {
    if (!_isInitialized) {
      print("❌ Mobile Speech Service not initialized");
      return null;
    }
    
    try {
      await _speech.stop();
      _isRecording = false;
      
      if (_lastRecognizedText.trim().isNotEmpty) {
        print("✅ Mobile speech transcription: $_lastRecognizedText");
        return _lastRecognizedText.trim();
      } else {
        print("⚠️ No speech detected by mobile service");
        return "";
      }
    } catch (e) {
      print("❌ Error stopping mobile speech recording: $e");
      return null;
    }
  }
  
  bool get isRecording => _isRecording;
  bool get isInitialized => _isInitialized;
  
  void dispose() {
    _speech.stop();
    _isRecording = false;
    print("🗑️ Mobile Speech Service disposed");
  }
}
