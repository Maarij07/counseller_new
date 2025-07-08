// lib/home/screens/google_speech_service.dart

import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class GoogleSpeechService {
  static const String _apiKey = 'AIzaSyAYsKJxeVTFAQabU_suLlcJRVZ7Zbvirvg';
  static const String _apiUrl = 'https://speech.googleapis.com/v1/speech:recognize';
  
  bool _isRecording = false;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (!kIsWeb) {
      print("❌ Google Speech Service only works on web");
      return;
    }

    try {
      await _setupWebAudio();
      _isInitialized = true;
      print("✅ Google Speech Service initialized");
    } catch (e) {
      print("❌ Failed to initialize Google Speech Service: $e");
    }
  }

  Future<void> _setupWebAudio() async {
    final script = html.ScriptElement();
    script.text = '''
      window.speechRecorder = {
        mediaRecorder: null,
        audioChunks: [],
        stream: null,
        isRecording: false,
        audioBlob: null,
        
        async startRecording() {
          console.log('🎤 Starting recording...');
          try {
            this.stream = await navigator.mediaDevices.getUserMedia({
              audio: {
                sampleRate: 16000,
                channelCount: 1,
                echoCancellation: true,
                noiseSuppression: true,
                autoGainControl: true
              }
            });
            
            // Try different MIME types for better compatibility
            let mimeType = 'audio/webm;codecs=opus';
            if (!MediaRecorder.isTypeSupported(mimeType)) {
              mimeType = 'audio/webm';
              if (!MediaRecorder.isTypeSupported(mimeType)) {
                mimeType = 'audio/mp4';
                if (!MediaRecorder.isTypeSupported(mimeType)) {
                  mimeType = ''; // Use default
                }
              }
            }
            
            console.log('🎵 Using MIME type:', mimeType);
            
            this.mediaRecorder = new MediaRecorder(this.stream, {
              mimeType: mimeType
            });
            
            this.audioChunks = [];
            this.isRecording = true;
            this.audioBlob = null;
            
            this.mediaRecorder.ondataavailable = (event) => {
              if (event.data.size > 0) {
                this.audioChunks.push(event.data);
                console.log('📦 Audio chunk received:', event.data.size, 'bytes');
              }
            };
            
            this.mediaRecorder.onstop = () => {
              this.audioBlob = new Blob(this.audioChunks, { type: mimeType });
              console.log('🛑 Recording stopped, blob size:', this.audioBlob.size, 'type:', this.audioBlob.type);
            };
            
            this.mediaRecorder.start(250); // Collect chunks every 250ms
            console.log('🎤 Recording started with type:', mimeType);
            return true;
          } catch (error) {
            console.error('❌ Recording failed:', error);
            this.isRecording = false;
            return false;
          }
        },
        
        stopRecording() {
          console.log('🛑 Stopping recording...');
          if (this.mediaRecorder && this.mediaRecorder.state === 'recording') {
            this.mediaRecorder.stop();
            this.isRecording = false;
          }
          
          if (this.stream) {
            this.stream.getTracks().forEach(track => track.stop());
          }
        },
        
        async convertToWav() {
          if (!this.audioBlob) {
            console.error('❌ No audio blob available');
            return null;
          }
          
          try {
            // Convert to WAV using Web Audio API
            const arrayBuffer = await this.audioBlob.arrayBuffer();
            const audioContext = new (window.AudioContext || window.webkitAudioContext)();
            const audioBuffer = await audioContext.decodeAudioData(arrayBuffer);
            
            // Convert to WAV format
            const wavBlob = this.audioBufferToWav(audioBuffer);
            console.log('🔄 Converted to WAV, size:', wavBlob.size);
            return wavBlob;
          } catch (error) {
            console.error('❌ WAV conversion failed:', error);
            return this.audioBlob; // Return original if conversion fails
          }
        },
        
        audioBufferToWav(buffer) {
          const length = buffer.length;
          const sampleRate = buffer.sampleRate;
          const arrayBuffer = new ArrayBuffer(44 + length * 2);
          const view = new DataView(arrayBuffer);
          
          // WAV header
          const writeString = (offset, string) => {
            for (let i = 0; i < string.length; i++) {
              view.setUint8(offset + i, string.charCodeAt(i));
            }
          };
          
          writeString(0, 'RIFF');
          view.setUint32(4, 36 + length * 2, true);
          writeString(8, 'WAVE');
          writeString(12, 'fmt ');
          view.setUint32(16, 16, true);
          view.setUint16(20, 1, true);
          view.setUint16(22, 1, true);
          view.setUint32(24, sampleRate, true);
          view.setUint32(28, sampleRate * 2, true);
          view.setUint16(32, 2, true);
          view.setUint16(34, 16, true);
          writeString(36, 'data');
          view.setUint32(40, length * 2, true);
          
          // Convert audio data to 16-bit PCM
          const channelData = buffer.getChannelData(0);
          let offset = 44;
          for (let i = 0; i < length; i++) {
            const sample = Math.max(-1, Math.min(1, channelData[i]));
            view.setInt16(offset, sample < 0 ? sample * 0x8000 : sample * 0x7FFF, true);
            offset += 2;
          }
          
          return new Blob([arrayBuffer], { type: 'audio/wav' });
        },
        
        async getBase64Audio() {
          const wavBlob = await this.convertToWav();
          if (!wavBlob) {
            console.error('❌ No WAV blob available');
            return null;
          }
          
          return new Promise((resolve) => {
            const reader = new FileReader();
            reader.onloadend = () => {
              const base64 = reader.result.split(',')[1];
              console.log('✅ Converted to base64, length:', base64.length);
              resolve(base64);
            };
            reader.onerror = () => {
              console.error('❌ FileReader error');
              resolve(null);
            };
            reader.readAsDataURL(wavBlob);
          });
        },
        
        getRecordingStatus() {
          return this.isRecording;
        },
        
        hasAudioBlob() {
          return this.audioBlob !== null && this.audioBlob.size > 0;
        },
        
        getAudioInfo() {
          return {
            hasBlob: this.audioBlob !== null,
            size: this.audioBlob ? this.audioBlob.size : 0,
            type: this.audioBlob ? this.audioBlob.type : 'none',
            chunksCount: this.audioChunks.length
          };
        }
      };
      
      console.log('📝 Enhanced speech recorder script loaded');
    ''';
    
    html.document.head!.children.add(script);
    await Future.delayed(const Duration(milliseconds: 300));
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
      print("🎤 Requesting recording start...");
      
      final result = js.context.callMethod('eval', ['window.speechRecorder.startRecording()']);
      
      // Wait for async operation
      await Future.delayed(const Duration(milliseconds: 500));
      
      final isRecording = js.context.callMethod('eval', ['window.speechRecorder.getRecordingStatus()']);
      
      _isRecording = isRecording == true;
      
      if (_isRecording) {
        print("✅ Google Speech recording started successfully");
      } else {
        print("❌ Recording start failed");
      }
      
      return _isRecording;
    } catch (e) {
      print("❌ Failed to start recording: $e");
      _isRecording = false;
      return false;
    }
  }

  Future<String?> stopRecordingAndTranscribe() async {
    if (!_isRecording) {
      print("❌ Not currently recording");
      return null;
    }

    try {
      print("🛑 Stopping recording and transcribing...");
      
      // Stop recording
      js.context.callMethod('eval', ['window.speechRecorder.stopRecording()']);
      _isRecording = false;
      
      // Wait for stop operation and blob creation
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // Get audio info for debugging
      final audioInfo = js.context.callMethod('eval', ['window.speechRecorder.getAudioInfo()']);
      print("📊 Audio info: $audioInfo");
      
      // Check if we have audio blob
      final hasBlob = js.context.callMethod('eval', ['window.speechRecorder.hasAudioBlob()']);
      
      if (hasBlob != true) {
        print("❌ No audio blob available");
        return null;
      }

      print("📦 Getting WAV audio...");
      
      // Get base64 audio using the Promise-based method
      final base64Audio = await _getBase64FromJS();
      
      if (base64Audio == null || base64Audio.isEmpty) {
        print("❌ Failed to convert audio to base64");
        return null;
      }

      // Check minimum size (WAV header is 44 bytes, so base64 should be at least ~60 chars)
      if (base64Audio.length < 100) {
        print("⚠️ Audio too short: ${base64Audio.length} chars, likely empty");
        return null;
      }

      print("📡 Sending ${base64Audio.length} chars to Google Speech API...");
      
      // Send to Google Speech API
      final transcript = await _transcribeWithGoogleAPI(base64Audio);
      
      if (transcript != null && transcript.isNotEmpty) {
        print("✅ Transcription successful: $transcript");
        return transcript;
      } else {
        print("❌ No transcription returned");
        return null;
      }
      
    } catch (e) {
      print("❌ Error during transcription: $e");
      _isRecording = false;
      return null;
    }
  }

  // Properly handle the JavaScript Promise for base64 conversion
  Future<String?> _getBase64FromJS() async {
    try {
      // Set up a completion callback
      js.context['_base64Result'] = null;
      js.context['_base64Error'] = null;
      
      final script = '''
        window.speechRecorder.getBase64Audio().then(function(base64) {
          window._base64Result = base64;
        }).catch(function(error) {
          window._base64Error = error.toString();
          console.error('Base64 conversion error:', error);
        });
      ''';
      
      js.context.callMethod('eval', [script]);
      
      // Poll for result
      for (int i = 0; i < 50; i++) { // 5 second timeout
        await Future.delayed(const Duration(milliseconds: 100));
        
        final result = js.context['_base64Result'];
        final error = js.context['_base64Error'];
        
        if (error != null) {
          print("❌ Base64 conversion error: $error");
          return null;
        }
        
        if (result != null) {
          print("✅ Base64 conversion successful");
          return result.toString();
        }
      }
      
      print("❌ Base64 conversion timeout");
      return null;
      
    } catch (e) {
      print("❌ Error getting base64 from JS: $e");
      return null;
    }
  }

  Future<String?> _transcribeWithGoogleAPI(String base64Audio) async {
    try {
      final requestBody = {
        "config": {
          "encoding": "LINEAR16", // Changed from WEBM_OPUS to LINEAR16
          "sampleRateHertz": 16000,
          "languageCode": "en-US",
          "alternativeLanguageCodes": ["ar", "he"],
          "enableAutomaticPunctuation": true,
          "enableWordTimeOffsets": false,
          "model": "latest_long",
          "useEnhanced": true // Enable enhanced model for better accuracy
        },
        "audio": {
          "content": base64Audio
        }
      };

      print("🚀 Sending request to Google Speech API...");
      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print("📡 Google API Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("📋 Full API response: ${json.encode(data)}");
        
        if (data['results'] != null && data['results'].isNotEmpty) {
          final result = data['results'][0];
          if (result['alternatives'] != null && result['alternatives'].isNotEmpty) {
            final transcript = result['alternatives'][0]['transcript'];
            final confidence = result['alternatives'][0]['confidence'] ?? 0.0;
            
            print("✅ Transcript: '$transcript' (confidence: $confidence)");
            
            return transcript?.toString()?.trim();
          } else {
            print("⚠️ No alternatives in result: ${json.encode(result)}");
          }
        } else {
          print("⚠️ No results in API response. Full response: ${response.body}");
          
          // Check if it's a silence/no speech response
          final data = json.decode(response.body);
          if (data['totalBilledTime'] == "0s") {
            print("💭 Likely reason: Audio was too quiet, too short, or no speech detected");
            return ""; // Return empty string to indicate no speech detected
          }
        }
      } else {
        print("❌ Google API Error: ${response.statusCode} - ${response.body}");
      }
      
      return null;
    } catch (e) {
      print("❌ API request failed: $e");
      return null;
    }
  }

  bool get isRecording => _isRecording;
  bool get isInitialized => _isInitialized;

  void dispose() {
    if (_isRecording) {
      try {
        js.context.callMethod('eval', ['window.speechRecorder.stopRecording()']);
      } catch (e) {
        print("❌ Error stopping recording during dispose: $e");
      }
    }
    _isRecording = false;
  }
}