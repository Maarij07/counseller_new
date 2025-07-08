// lib/home/screens/browser_speech_service.dart

import 'dart:html' as html;
import 'dart:js' as js;
import 'package:flutter/foundation.dart';

class BrowserSpeechService {
  bool _isRecording = false;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (!kIsWeb) {
      print("❌ Browser Speech Service only works on web");
      return;
    }

    try {
      await _setupSpeechRecognition();
      _isInitialized = true;
      print("✅ Browser Speech Service initialized");
    } catch (e) {
      print("❌ Failed to initialize Browser Speech Service: $e");
    }
  }

  Future<void> _setupSpeechRecognition() async {
    final script = html.ScriptElement();
    script.text = '''
      window.browserSpeech = {
        recognition: null,
        isRecording: false,
        finalTranscript: '',
        isSupported: false,
        
        init() {
          const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
          
          if (!SpeechRecognition) {
            console.error('❌ Browser speech recognition not supported');
            this.isSupported = false;
            return false;
          }
          
          this.recognition = new SpeechRecognition();
          this.recognition.continuous = false;  // Changed to false for better results
          this.recognition.interimResults = false;  // Only final results
          this.recognition.lang = 'en-US';
          this.recognition.maxAlternatives = 1;
          
          this.recognition.onstart = () => {
            console.log('🎤 Browser speech recognition started');
            this.isRecording = true;
            this.finalTranscript = '';
          };
          
          this.recognition.onresult = (event) => {
            console.log('📝 Speech recognition results:', event.results);
            
            for (let i = 0; i < event.results.length; i++) {
              if (event.results[i].isFinal) {
                this.finalTranscript += event.results[i][0].transcript;
                console.log('✅ Final transcript:', this.finalTranscript);
              }
            }
          };
          
          this.recognition.onerror = (event) => {
            console.error('❌ Speech recognition error:', event.error);
            this.isRecording = false;
          };
          
          this.recognition.onend = () => {
            console.log('🛑 Speech recognition ended');
            this.isRecording = false;
          };
          
          this.isSupported = true;
          return true;
        },
        
        startRecording() {
          if (!this.isSupported) {
            console.error('❌ Speech recognition not supported');
            return false;
          }
          
          if (!this.recognition) {
            if (!this.init()) {
              return false;
            }
          }
          
          try {
            // Reset transcript
            this.finalTranscript = '';
            this.recognition.start();
            console.log('🎤 Starting speech recognition...');
            return true;
          } catch (error) {
            console.error('❌ Failed to start speech recognition:', error);
            return false;
          }
        },
        
        stopRecording() {
          if (this.recognition && this.isRecording) {
            this.recognition.stop();
            console.log('🛑 Stopping speech recognition...');
          }
          
          // Return current transcript
          return this.finalTranscript.trim();
        },
        
        getRecordingStatus() {
          return this.isRecording;
        },
        
        isSupported() {
          return this.isSupported;
        },
        
        getTranscript() {
          return this.finalTranscript.trim();
        }
      };
      
      // Initialize immediately
      window.browserSpeech.init();
      console.log('📝 Browser speech script loaded. Supported:', window.browserSpeech.isSupported);
    ''';
    
    html.document.head!.children.add(script);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<bool> startRecording() async {
    if (!_isInitialized) {
      print("❌ Service not initialized");
      return false;
    }

    if (_isRecording) {
      print("⚠️ Already recording");
      return false;
    }

    try {
      print("🎤 Starting browser speech recognition...");
      
      final result = js.context.callMethod('eval', ['window.browserSpeech.startRecording()']);
      
      if (result == true) {
        _isRecording = true;
        print("✅ Browser speech recognition started successfully");
        return true;
      } else {
        print("❌ Browser speech recognition failed to start");
        return false;
      }
    } catch (e) {
      print("❌ Failed to start recording: $e");
      return false;
    }
  }

  Future<String?> stopRecordingAndTranscribe() async {
    if (!_isRecording) {
      print("❌ Not currently recording");
      return null;
    }

    try {
      print("🛑 Stopping speech recognition...");
      
      // Stop recording
      final result = js.context.callMethod('eval', ['window.browserSpeech.stopRecording()']);
      _isRecording = false;
      
      // Wait a moment for final results
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Get final transcript
      final transcript = js.context.callMethod('eval', ['window.browserSpeech.getTranscript()']);
      
      if (transcript != null && transcript.toString().trim().isNotEmpty) {
        final result = transcript.toString().trim();
        print("✅ Browser speech result: '$result'");
        return result;
      } else {
        print("⚠️ No speech detected by browser");
        return "";
      }
      
    } catch (e) {
      print("❌ Error during transcription: $e");
      _isRecording = false;
      return null;
    }
  }

  bool get isRecording => _isRecording;
  bool get isInitialized => _isInitialized;

  void dispose() {
    if (_isRecording) {
      try {
        js.context.callMethod('eval', ['window.browserSpeech.stopRecording()']);
      } catch (e) {
        print("❌ Error during dispose: $e");
      }
    }
    _isRecording = false;
  }
}