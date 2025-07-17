// 📄 קובץ: lib/home/screens/tts_service.dart

import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  Future<void> _initializeTts() async {
    if (_isInitialized) return;
    
    try {
      // Set language
      await _flutterTts.setLanguage("en-US");
      
      // Platform-specific settings
      if (Platform.isAndroid) {
        // Android-specific settings for better speech quality
        await _flutterTts.setSpeechRate(0.4); // Slower speech rate for Android
        await _flutterTts.setPitch(0.9);
        await _flutterTts.setVolume(0.8);
        
        // Set Android-specific TTS engine settings
        await _flutterTts.awaitSpeakCompletion(true);
      } else if (Platform.isIOS) {
        // iOS-specific settings
        await _flutterTts.setSpeechRate(0.5);
        await _flutterTts.setPitch(1.0);
        await _flutterTts.setVolume(0.8);
      } else {
        // Web and other platforms
        await _flutterTts.setSpeechRate(0.5);
        await _flutterTts.setPitch(1.0);
        await _flutterTts.setVolume(0.8);
      }
      
      _isInitialized = true;
      print("✅ TTS Service initialized for ${Platform.operatingSystem}");
    } catch (e) {
      print("❌ Error initializing TTS: $e");
    }
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    
    await _initializeTts();
    
    try {
      // Stop any current speech
      await _flutterTts.stop();
      
      // Wait a moment before starting new speech
      await Future.delayed(const Duration(milliseconds: 200));
      
      print("🗣️ TTS Speaking: ${text.length} characters");
      await _flutterTts.speak(text);
    } catch (e) {
      print("❌ Error in TTS speak: $e");
    }
  }
  
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      print("❌ Error stopping TTS: $e");
    }
  }
  
  Future<void> pause() async {
    try {
      await _flutterTts.pause();
    } catch (e) {
      print("❌ Error pausing TTS: $e");
    }
  }
  
  void dispose() {
    _flutterTts.stop();
  }
}
