// lib/home/screens/working_speech_service.dart

// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class WorkingSpeechService {
  static const String _apiKey = 'AIzaSyAYsKJxeVTFAQabU_suLlcJRVZ7Zbvirvg';
  static const String _apiUrl = 'https://speech.googleapis.com/v1/speech:recognize';
  
  bool _isRecording = false;
  bool _isInitialized = false;
  bool _useBrowserSpeech = true; // Primary: Browser speech, Fallback: Google API

  Future<void> initialize() async {
    if (!kIsWeb) {
      print("❌ Speech Service only works on web");
      return;
    }

    try {
      await _setupSpeechRecognition();
      _isInitialized = true;
      print("✅ Working Speech Service initialized");
    } catch (e) {
      print("❌ Failed to initialize Speech Service: $e");
    }
  }

  Future<void> _setupSpeechRecognition() async {
    final script = html.ScriptElement();
    script.text = '''
      window.workingSpeech = {
        recognition: null,
        isRecording: false,
        finalTranscript: '',
        interimTranscript: '',
        
        // Browser Speech Recognition (Primary)
        initBrowserSpeech() {
          const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
          
          if (!SpeechRecognition) {
            console.error('❌ Browser speech recognition not supported');
            return false;
          }
          
          this.recognition = new SpeechRecognition();
          this.recognition.continuous = true;
          this.recognition.interimResults = true;
          this.recognition.lang = 'en-US';
          this.recognition.maxAlternatives = 1;
          
          this.recognition.onstart = () => {
            console.log('🎤 Browser speech recognition started');
            this.isRecording = true;
            this.finalTranscript = '';
            this.interimTranscript = '';
          };
          
          this.recognition.onresult = (event) => {
            let interim = '';
            let final = '';
            
            for (let i = event.resultIndex; i < event.results.length; i++) {
              const transcript = event.results[i][0].transcript;
              if (event.results[i].isFinal) {
                final += transcript;
              } else {
                interim += transcript;
              }
            }
            
            this.finalTranscript += final;
            this.interimTranscript = interim;
            
            console.log('📝 Speech result - Final:', this.finalTranscript, 'Interim:', interim);
          };
          
          this.recognition.onerror = (event) => {
            console.error('❌ Speech recognition error:', event.error);
            this.isRecording = false;
          };
          
          this.recognition.onend = () => {
            console.log('🛑 Speech recognition ended');
            this.isRecording = false;
          };
          
          return true;
        },
        
        startBrowserRecording() {
          if (!this.recognition) {
            if (!this.initBrowserSpeech()) {
              return false;
            }
          }
          
          try {
            this.recognition.start();
            return true;
          } catch (error) {
            console.error('❌ Failed to start browser recording:', error);
            return false;
          }
        },
        
        stopBrowserRecording() {
          if (this.recognition && this.isRecording) {
            this.recognition.stop();
          }
          return this.finalTranscript.trim();
        },
        
        getRecordingStatus() {
          return this.isRecording;
        },
        
        // Audio Recording (Fallback for Google API)
        mediaRecorder: null,
        audioChunks: [],
        stream: null,
        audioBlob: null,
        
        async startAudioRecording() {
          console.log('🎤 Starting audio recording for Google API...');
          try {
            this.stream = await navigator.mediaDevices.getUserMedia({
              audio: {
                sampleRate: 16000,
                channelCount: 1,
                echoCancellation: true,
                noiseSuppression: true,
                autoGainControl: true,
                volume: 1.0
              }
            });
            
            // Use the most compatible format
            let mimeType = '';
            const types = [
              'audio/webm;codecs=opus',
              'audio/webm',
              'audio/mp4',
              'audio/wav'
            ];
            
            for (const type of types) {
              if (MediaRecorder.isTypeSupported(type)) {
                mimeType = type;
                break;
              }
            }
            
            console.log('🎵 Using MIME type:', mimeType);
            
            this.mediaRecorder = new MediaRecorder(this.stream, {
              mimeType: mimeType,
              audioBitsPerSecond: 16000
            });
            
            this.audioChunks = [];
            this.audioBlob = null;
            
            this.mediaRecorder.ondataavailable = (event) => {
              if (event.data.size > 0) {
                this.audioChunks.push(event.data);
              }
            };
            
            this.mediaRecorder.onstop = () => {
              this.audioBlob = new Blob(this.audioChunks, { type: mimeType });
              console.log('🛑 Audio recording stopped, blob size:', this.audioBlob.size);
            };
            
            this.mediaRecorder.start(100);
            return true;
          } catch (error) {
            console.error('❌ Audio recording failed:', error);
            return false;
          }
        },
        
        stopAudioRecording() {
          console.log('🛑 Stopping audio recording...');
          if (this.mediaRecorder && this.mediaRecorder.state === 'recording') {
            this.mediaRecorder.stop();
          }
          
          if (this.stream) {
            this.stream.getTracks().forEach(track => track.stop());
          }
        },
        
        async getBase64Audio() {
          if (!this.audioBlob || this.audioBlob.size === 0) {
            console.error('❌ No audio blob available');
            return null;
          }
          
          return new Promise((resolve) => {
            const reader = new FileReader();
            reader.onloadend = () => {
              const base64 = reader.result.split(',')[1];
              console.log('✅ Audio converted to base64, length:', base64.length);
              resolve(base64);
            };
            reader.onerror = () => {
              console.error('❌ FileReader error');
              resolve(null);
            };
            reader.readAsDataURL(this.audioBlob);
          });
        }
      };
      
      console.log('📝 Working speech script loaded');
    ''';
    
    html.document.head!.children.add(script);
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<bool> startRecording() async {
    if (!_isInitialized || _isRecording) {
      print("❌ Cannot start recording");
      return false;
    }

    try {
      if (_useBrowserSpeech) {
        // Try browser speech recognition first
        print("🎤 Starting browser speech recognition...");
        final result = js.context.callMethod('eval', ['window.workingSpeech.startBrowserRecording()']);
        
        if (result == true) {
          _isRecording = true;
          print("✅ Browser speech recognition started");
          return true;
        } else {
          print("⚠️ Browser speech failed, falling back to audio recording");
          _useBrowserSpeech = false;
        }
      }
      
      // Fallback to audio recording for Google API
      print("🎤 Starting audio recording for Google API...");
      final result = js.context.callMethod('eval', ['window.workingSpeech.startAudioRecording()']);
      
      await Future.delayed(const Duration(milliseconds: 500));
      _isRecording = result == true;
      
      if (_isRecording) {
        print("✅ Audio recording started");
      } else {
        print("❌ All recording methods failed");
      }
      
      return _isRecording;
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
      _isRecording = false;
      
      if (_useBrowserSpeech) {
        // Use browser speech recognition result
        print("🛑 Getting browser speech result...");
        final result = js.context.callMethod('eval', ['window.workingSpeech.stopBrowserRecording()']);
        
        if (result != null && result.toString().trim().isNotEmpty) {
          final transcript = result.toString().trim();
          print("✅ Browser speech result: $transcript");
          return transcript;
        } else {
          print("⚠️ Browser speech returned empty, trying Google API...");
        }
      }
      
      // Fallback to Google API
      print("🛑 Stopping audio recording for Google API...");
      js.context.callMethod('eval', ['window.workingSpeech.stopAudioRecording()']);
      
      await Future.delayed(const Duration(milliseconds: 1500));
      
      final base64Audio = await _getBase64FromJS();
      
      if (base64Audio == null || base64Audio.isEmpty) {
        print("❌ Failed to get audio data");
        return null;
      }

      print("📡 Sending to Google API...");
      final transcript = await _transcribeWithGoogleAPI(base64Audio);
      
      if (transcript != null && transcript.isNotEmpty) {
        print("✅ Google API result: $transcript");
        return transcript;
      } else {
        print("❌ Google API failed");
        return null;
      }
      
    } catch (e) {
      print("❌ Error during transcription: $e");
      return null;
    }
  }

  Future<String?> _getBase64FromJS() async {
    try {
      js.context['_audioResult'] = null;
      
      final script = '''
        window.workingSpeech.getBase64Audio().then(function(base64) {
          window._audioResult = base64;
        }).catch(function(error) {
          window._audioResult = 'ERROR';
          console.error('Audio conversion error:', error);
        });
      ''';
      
      js.context.callMethod('eval', [script]);
      
      for (int i = 0; i < 30; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        
        final result = js.context['_audioResult'];
        if (result != null) {
          if (result.toString() == 'ERROR') {
            return null;
          }
          return result.toString();
        }
      }
      
      return null;
    } catch (e) {
      print("❌ Error getting base64: $e");
      return null;
    }
  }

  Future<String?> _transcribeWithGoogleAPI(String base64Audio) async {
    try {
      final requestBody = {
        "config": {
          "encoding": "WEBM_OPUS", // Keep original format for now
          "sampleRateHertz": 16000,
          "languageCode": "en-US",
          "enableAutomaticPunctuation": true,
          "model": "latest_short",
          "useEnhanced": true
        },
        "audio": {
          "content": base64Audio
        }
      };

      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['results'] != null && data['results'].isNotEmpty) {
          final transcript = data['results'][0]['alternatives'][0]['transcript'];
          return transcript?.toString().trim();
        }
      }
      
      return null;
    } catch (e) {
      print("❌ Google API error: $e");
      return null;
    }
  }

  bool get isRecording => _isRecording;
  bool get isInitialized => _isInitialized;

  void dispose() {
    if (_isRecording) {
      try {
        if (_useBrowserSpeech) {
          js.context.callMethod('eval', ['window.workingSpeech.stopBrowserRecording()']);
        } else {
          js.context.callMethod('eval', ['window.workingSpeech.stopAudioRecording()']);
        }
      } catch (e) {
        print("❌ Error during dispose: $e");
      }
    }
    _isRecording = false;
  }
}