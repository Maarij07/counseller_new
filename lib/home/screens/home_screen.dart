// lib/home/screens/home_screen.dart

// ignore_for_file: unused_field, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phychological_counselor/data/services/gpt_service.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:phychological_counselor/home/screens/audio_handler_stub.dart'
    if (dart.library.html) 'package:phychological_counselor/home/screens/audio_handler_web.dart'
    if (dart.library.io) 'package:phychological_counselor/home/screens/audio_handler_mobile.dart';
import 'package:phychological_counselor/home/screens/firestore_service.dart';
import 'package:phychological_counselor/home/screens/speech_service.dart';
import 'package:phychological_counselor/home/screens/avatar_lipsync_service_stub.dart'
    if (dart.library.html) 'package:phychological_counselor/home/screens/avatar_lipsync_service.dart';
import 'package:phychological_counselor/home/screens/mobile_avatar_service.dart';
import 'package:phychological_counselor/home/screens/mobile_avatar_widget.dart';
import 'package:phychological_counselor/home/screens/browser_speech_service_stub.dart'
    if (dart.library.html) 'package:phychological_counselor/home/screens/browser_speech_service.dart'
    if (dart.library.io) 'package:phychological_counselor/home/screens/browser_speech_service_mobile.dart';
import 'package:flutter/foundation.dart'; 
import 'package:phychological_counselor/frontend/home_screenDesign2.dart';
import 'package:phychological_counselor/frontend/chat_side_panel.dart';

import '../../ai_chat/provider/chat_provider.dart';
import '../../ai_chat/widgets/build_message.dart';
import 'package:phychological_counselor/frontend/home_screenDesign.dart';

import 'tts_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

const double kHeaderHeight = 64.0;

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isRecording = false;
  bool _showAvatar = false;
  String? _userId;
  bool _showSidePanel = false;
  String? _selectedChatId;

  // Avatar conversation state
  bool _isAvatarSpeaking = false;
  bool _canUseVoiceWithAvatar = false;
  bool _showTypingIndicator = false;
  
  late AudioHandler _audioHandler;
  final _ttsService = TtsService();
  final _avatarLipSync = AvatarLipSyncService();
  final _mobileAvatarService = MobileAvatarService();
  final _browserSpeech = BrowserSpeechService();
  bool _isAvatarInitialized = false;
  bool _isSpeechInitialized = false;

  late SpeechService _speechService;

  String? _currentSessionId;
  bool _lastInputWasVoice = false;

  // Avatar URL - UPDATE THIS TO YOUR ACTUAL ASSET PATH
  static const String _avatarUrl = 'assets/avatars/avatar.glb';

  @override
  void initState() {
    super.initState();

    print("⚙️ initState started");

    _userId = FirebaseAuth.instance.currentUser?.uid;
    if (_userId != null) {
      _speechService = SpeechService();
    }

    // Initialize services
    _initializeServices();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      print("📡 Firebase auth listener activated");

      if (user != null) {
        print("🟢 Logged in as: ${user.email}");
        setState(() {
          _userId = user.uid;
        });
        _startNewSession();

        Future.delayed(Duration(seconds: 1), () {
          // Add welcome message
        });
      } else {
        print("❌ אין משתמש מחובר כרגע, לא ניתן להתחיל סשן.");
      }
    });
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize audio handler
      _audioHandler = AudioHandler();
      
      if (kIsWeb) {
        // Web platform - use iframe avatar
        await _avatarLipSync.initialize();
        await _browserSpeech.initialize();
        setState(() => _isSpeechInitialized = true);
      } else {
        // Mobile platform - use mobile avatar
        await _mobileAvatarService.initialize();
      }
      
      setState(() => _isAvatarInitialized = true);
      print("✅ All services initialized for ${kIsWeb ? 'web' : 'mobile'}");
    } catch (e) {
      print('❌ Service initialization failed: $e');
    }
  }

  Future<void> _startNewSession() async {
    final newDoc = await FirebaseFirestore.instance
        .collection('chat_sessions')
        .add({
      'userId': _userId,
      'title': 'שיחה חדשה - ${DateTime.now().toLocal()}',
      'createdAt': FieldValue.serverTimestamp(),
    });
    setState(() => _currentSessionId = newDoc.id);
  }

  // ENHANCED: Camera button - shows avatar and speaks greeting
  Future<void> _toggleAvatarAndGreet() async {
    setState(() => _showAvatar = !_showAvatar);
    
    if (_showAvatar && _isAvatarInitialized) {
      try {
        bool success = false;
        
        if (kIsWeb) {
          // Web platform - iframe avatar
          await Future.delayed(const Duration(milliseconds: 3000));
          print("🎬 Initializing iframe avatar...");
          success = await _avatarLipSync.initializeAvatar(_avatarUrl);
        } else {
          // Mobile platform - mobile avatar
          await Future.delayed(const Duration(milliseconds: 1000));
          print("🎬 Initializing mobile avatar...");
          success = await _mobileAvatarService.loadAvatar(_avatarUrl);
        }
        
        print("🗣️ Avatar speaking greeting...");
        setState(() => _isAvatarSpeaking = true);
        
        // Add greeting to chat first
        const greeting = "Hello! How are you doing today?";
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        chatProvider.addMessage("gpt", greeting);
        await FirestoreService.saveMessage(_userId!, "gpt", greeting);
        _scrollToBottom();
        
        if (success) {
          if (kIsWeb && _avatarLipSync.isIframeReady) {
            // Use iframe avatar lip sync
            await _avatarLipSync.speakText(greeting);
          } else if (!kIsWeb) {
            // Use mobile avatar lip sync
            await _mobileAvatarService.speakText(greeting);
          } else {
            // Fallback to regular TTS
            print("⚠️ Avatar not fully ready, using fallback TTS");
            await _ttsService.speak(greeting);
          }
        } else {
          // Fallback to regular TTS
          print("⚠️ Avatar initialization failed, using fallback TTS");
          await _ttsService.speak(greeting);
        }
        
        // Enable voice input when speaking is done
        setState(() {
          _isAvatarSpeaking = false;
          _canUseVoiceWithAvatar = true;
        });
        
        print("✅ Avatar finished greeting - voice input enabled");
        
      } catch (e) {
        print('❌ Error with avatar greeting: $e');
        
        // Fallback: still speak with regular TTS
        const greeting = "Hello! How are you doing today?";
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        chatProvider.addMessage("gpt", greeting);
        await FirestoreService.saveMessage(_userId!, "gpt", greeting);
        _scrollToBottom();
        
        await _ttsService.speak(greeting);
        
        setState(() {
          _isAvatarSpeaking = false;
          _canUseVoiceWithAvatar = true;
        });
      }
    } else {
      // Hide avatar - reset voice conversation state
      setState(() {
        _canUseVoiceWithAvatar = false;
        _isAvatarSpeaking = false;
      });
    }
  }

  // ENHANCED: Smart microphone - context-aware functionality
  Future<void> _toggleRecording() async {
    if (_showAvatar && _isSpeechInitialized) {
      // AVATAR MODE: Use browser speech for voice conversation
      await _handleAvatarVoiceRecording();
    } else {
      // NORMAL MODE: Use original audio handler
      await _handleNormalVoiceRecording();
    }
  }

  // Avatar voice recording with Browser Speech API
  Future<void> _handleAvatarVoiceRecording() async {
    if (_isRecording) {
      // Stop recording and process
      print("🛑 Stopping avatar recording and transcribing...");
      setState(() => _canUseVoiceWithAvatar = false);
      
      final transcript = await _browserSpeech.stopRecordingAndTranscribe();
      setState(() => _isRecording = false);
      
      if (transcript != null && transcript.trim().isNotEmpty) {
        print("🎯 Avatar voice transcript: $transcript");
        
        // IMMEDIATELY show transcribed text in chat
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        chatProvider.addMessage("user", transcript);
        await FirestoreService.saveMessage(_userId!, "user", transcript);
        _scrollToBottom();
        
        // Then process with AI and respond
        await _processAvatarVoiceMessage(transcript);
      } else if (transcript == "") {
        // Empty string means no speech detected
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        chatProvider.addMessage("gpt", "⚠️ No speech detected. Please try speaking louder.");
        setState(() => _canUseVoiceWithAvatar = true);
        _scrollToBottom();
      } else {
        // Null means error
        print("❌ No valid transcript received");
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        chatProvider.addMessage("gpt", "❌ Sorry, I couldn't understand that. Please try again.");
        setState(() => _canUseVoiceWithAvatar = true);
        _scrollToBottom();
      }
    } else {
      // Check if avatar is currently speaking
      bool avatarCurrentlySpeaking = false;
      if (kIsWeb) {
        avatarCurrentlySpeaking = _isAvatarSpeaking || _avatarLipSync.isSpeaking;
      } else {
        avatarCurrentlySpeaking = _isAvatarSpeaking || _mobileAvatarService.isSpeaking;
      }
      
      if (avatarCurrentlySpeaking) {
        print("🛑 Stopping avatar TTS to start recording");
        // Stop the avatar lip sync
        if (kIsWeb) {
          _avatarLipSync.stopLipSync();
        } else {
          _mobileAvatarService.stopSpeaking();
        }
        setState(() {
          _isAvatarSpeaking = false;
          _canUseVoiceWithAvatar = true;
        });
        
        // Wait a moment for TTS to stop
        await Future.delayed(const Duration(milliseconds: 300));
      }
      
      if (!_canUseVoiceWithAvatar || _isAvatarSpeaking) {
        print("⚠️ Cannot use voice - avatar speaking or not ready");
        return;
      }

      // Start recording
      print("🎤 Starting avatar voice recording...");
      final started = await _browserSpeech.startRecording();
      
      if (!started) {
        print("❌ Failed to start avatar recording");
        setState(() => _isRecording = false);
        return;
      }
      
      setState(() => _isRecording = true);
      print("✅ Avatar voice recording started");
    }
  }

  // Normal voice recording
  Future<void> _handleNormalVoiceRecording() async {
    setState(() => _isRecording = !_isRecording);
    

    if (_isRecording) {
      await _audioHandler.startRecording();
    } else {
      final transcript = await _audioHandler.stopAndTranscribe(kIsWeb);
      setState(() => _isRecording = false);

      if (transcript.trim().isNotEmpty) {
        // Show transcribed text immediately
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        chatProvider.addMessage("user", transcript);
        await FirestoreService.saveMessage(_userId!, "user", transcript);
        _scrollToBottom();
        
        // Process AI response directly
        await _processNormalVoiceMessage(transcript);
      } else {
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        chatProvider.addMessage("gpt", "❌ Sorry, I couldn't understand that. Please try again.");
        _scrollToBottom();
      }
    }
  }

  // Process normal voice message
  Future<void> _processNormalVoiceMessage(String message) async {
    setState(() => _isLoading = true);

    // Show three dots animation while processing
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.addMessage("system", "typing");
    _scrollToBottom();

    try {
      final response = await getGPTResponse(message, _userId!);
      final reply = response ?? "❌ לא התקבלה תשובה מה-GPT";

      // Remove typing indicator and add real response
      _removeTypingIndicator(chatProvider);
      chatProvider.addMessage("gpt", reply);
      await FirestoreService.saveMessage(_userId!, "gpt", reply);
      _scrollToBottom();

      // Use regular TTS for normal voice
      await _ttsService.speak(reply);

    } catch (e) {
      // Remove typing indicator and add error
      _removeTypingIndicator(chatProvider);
      chatProvider.addMessage("gpt", "❌ שגיאה בקבלת תשובה מה-GPT");
      _scrollToBottom();
    }

    setState(() => _isLoading = false);
  }

  // Process avatar voice message and respond with iframe avatar lip sync
  Future<void> _processAvatarVoiceMessage(String message) async {
    setState(() => _isLoading = true);

    // Show three dots animation while processing
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.addMessage("system", "typing");
    _scrollToBottom();

    try {
      print("🤖 Getting AI response for: $message");
      final response = await getGPTResponse(message, _userId!);
      final reply = response ?? "I'm sorry, I didn't catch that. Could you try again?";

      print("💬 AI response: $reply");
      
      // Remove typing indicator and add real response
      _removeTypingIndicator(chatProvider);
      chatProvider.addMessage("gpt", reply);
      await FirestoreService.saveMessage(_userId!, "gpt", reply);
      _scrollToBottom();

      // Speak response with avatar lip sync (with fallback)
      setState(() => _isAvatarSpeaking = true);
      
      try {
        bool speechSuccess = false;
        
        if (kIsWeb && _avatarLipSync.isIframeReady && _avatarLipSync.isAvatarLoaded) {
          await _avatarLipSync.speakText(reply);
          speechSuccess = true;
          print("✅ Web avatar spoke successfully");
        } else if (!kIsWeb && _mobileAvatarService.isAvatarLoaded) {
          await _mobileAvatarService.speakText(reply);
          speechSuccess = true;
          print("✅ Mobile avatar spoke successfully");
        }
        
        if (!speechSuccess) {
          print("⚠️ Avatar not ready, using fallback TTS");
          await _ttsService.speak(reply);
        }
      } catch (e) {
        print("⚠️ Avatar speech failed, using fallback TTS: $e");
        await _ttsService.speak(reply);
      }
      
      // Enable voice input again when done speaking
      setState(() {
        _isAvatarSpeaking = false;
        _canUseVoiceWithAvatar = true;
      });
      
      print("✅ Avatar response complete - ready for next input");

    } catch (e) {
      print("❌ Error processing avatar voice message: $e");
      
      // Remove typing indicator and add error
      _removeTypingIndicator(chatProvider);
      chatProvider.addMessage("gpt", "I'm having trouble processing that. Please try again.");
      _scrollToBottom();
      
      setState(() {
        _isAvatarSpeaking = false;
        _canUseVoiceWithAvatar = true;
      });
    }

    setState(() => _isLoading = false);
  }

  // Helper function to remove typing indicator
  void _removeTypingIndicator(ChatProvider chatProvider) {
    // Check if last message is typing indicator and remove it safely
    if (chatProvider.messages.isNotEmpty && 
        chatProvider.messages.last['text'] == "typing") {
      // Create a new list without the typing indicator
      final updatedMessages = List.from(chatProvider.messages)..removeLast();
      
      // Clear and re-add all messages except typing
      chatProvider.clearMessages();
      for (final msg in updatedMessages) {
        // Preserve original message structure exactly as it was
        chatProvider.messages.add(msg);
      }
      
      // UI will update automatically via ChangeNotifierProvider.
      // Removed direct call to notifyListeners() to avoid error.
    }
  }

  // Send message function
  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;
    
    // If recording, stop it first but don't process the voice
    if (_isRecording) {
      if (_showAvatar && _isSpeechInitialized) {
        // Stop avatar recording without processing
        _browserSpeech.dispose();
      } else {
        // Stop normal recording without processing  
        await _audioHandler.stopAndTranscribe(kIsWeb);
      }
      setState(() => _isRecording = false);
    }
    
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    
    // Only add message if it's not from voice input (avoid duplicates)
    if (!_lastInputWasVoice) {
      chatProvider.addMessage("user", message);
      await FirestoreService.saveMessage(_userId!, "user", message);
    }

    setState(() {
      _isLoading = true;
      _showTypingIndicator = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final response = await getGPTResponse(message, _userId!);
      final reply = response ?? "❌ לא התקבלה תשובה מה-GPT";

      // Add real response
      chatProvider.addMessage("gpt", reply);
      await FirestoreService.saveMessage(_userId!, "gpt", reply);
      _scrollToBottom();

      // Smart TTS based on context
      if (_lastInputWasVoice || _showAvatar) {
        if (_showAvatar && _isAvatarInitialized) {
          // Use avatar lip sync (with fallback)
          setState(() => _isAvatarSpeaking = true);
          
          try {
            bool speechSuccess = false;
            
            if (kIsWeb && _avatarLipSync.isIframeReady && _avatarLipSync.isAvatarLoaded) {
              await _avatarLipSync.speakText(reply);
              speechSuccess = true;
            } else if (!kIsWeb && _mobileAvatarService.isAvatarLoaded) {
              await _mobileAvatarService.speakText(reply);
              speechSuccess = true;
            }
            
            if (!speechSuccess) {
              print("⚠️ Avatar not ready, using fallback TTS");
              await _ttsService.speak(reply);
            }
          } catch (e) {
            print("⚠️ Avatar TTS failed, using fallback: $e");
            await _ttsService.speak(reply);
          }
          
          setState(() {
            _isAvatarSpeaking = false;
            _canUseVoiceWithAvatar = true;
          });
        } else {
          // Use regular TTS
          await _ttsService.speak(reply);
        }
      }

    } catch (e) {
      // Add error message
      chatProvider.addMessage("gpt", "❌ שגיאה בקבלת תשובה מה-GPT");
      _scrollToBottom();
    }

    // Reset voice flag
    _lastInputWasVoice = false;
    setState(() {
      _isLoading = false;
      _showTypingIndicator = false;
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }


  // AVATAR SECTION (supports both web iframe and mobile custom widget)
  Widget _buildAvatarSection() {
    if (!_showAvatar) return const SizedBox.shrink();
    
    return SizedBox(
      height: 250,
      child: Stack(
        children: [
          // Platform-specific avatar rendering
          if (kIsWeb)
            // Web: iframe Avatar using HtmlElementView
            _avatarLipSync.viewType != null
                ? HtmlElementView(
                    viewType: _avatarLipSync.viewType!,
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  )
          else
            // Mobile: Custom drawn avatar using ChangeNotifierProvider
            ChangeNotifierProvider.value(
              value: _mobileAvatarService,
              child: const Center(
                child: MobileAvatarWidget(
                  width: 250,
                  height: 250,
                ),
              ),
            ),
            
          // Status overlay for avatar conversation
          Positioned(
            top: 8,
            left: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                _getAvatarStatusText(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getAvatarStatusText() {
    bool avatarSpeaking = false;
    bool avatarReady = false;
    bool avatarLoaded = false;
    
    if (kIsWeb) {
      avatarSpeaking = _isAvatarSpeaking || _avatarLipSync.isSpeaking;
      avatarReady = _avatarLipSync.isIframeReady;
      avatarLoaded = _avatarLipSync.isAvatarLoaded;
    } else {
      avatarSpeaking = _isAvatarSpeaking || _mobileAvatarService.isSpeaking;
      avatarReady = _mobileAvatarService.isInitialized;
      avatarLoaded = _mobileAvatarService.isAvatarLoaded;
    }
    
    if (avatarSpeaking) {
      return "🗣️ AI is speaking...";
    } else if (_isRecording) {
      return "🎤 Listening...";
    } else if (_canUseVoiceWithAvatar && avatarReady) {
      return "💬 Ready for voice input";
    } else if (avatarReady && !avatarLoaded) {
      return "📦 Loading avatar...";
    } else if (!avatarReady) {
      return kIsWeb ? "⏳ Initializing iframe..." : "⏳ Initializing mobile avatar...";
    } else {
      return "⚠️ Avatar status unknown";
    }
  }

  // Input field with smart controls
  Widget _buildInputField() {
    final double maxWidth = MediaQuery.of(context).size.width * 0.8;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 48.0,
            maxHeight: 150.0,
            maxWidth: maxWidth,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: true,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.send,
                    minLines: 1,
                    maxLines: null,
                    onSubmitted: (text) {
                      _sendMessage(text);
                    },
                    decoration: InputDecoration(
                      hintText: _isRecording 
                        ? "Listening... or type to send text"
                        : "Type your message...",
                      hintStyle: TextStyle(
                        fontSize: 16,
                        color: _isRecording ? Colors.orange : Colors.grey,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    ),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                
                // Camera button for avatar toggle
                IconButton(
                  icon: Icon(
                    _showAvatar ? Icons.visibility_off : Icons.camera_alt, 
                    size: 20,
                    color: _showAvatar ? Colors.green : Colors.grey[600],
                  ),
                  onPressed: _toggleAvatarAndGreet,
                  tooltip: _showAvatar ? "Hide Avatar" : "Show Avatar & Start Chat",
                ),
                
                // Smart microphone button
                IconButton(
                  icon: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    size: 20, 
                    color: _isRecording 
                      ? Colors.red 
                      : _showAvatar 
                        ? (_canUseVoiceWithAvatar || _isAvatarSpeaking ? Colors.green : Colors.grey)
                        : Colors.blue
                  ),
                  onPressed: _showAvatar 
                    ? _toggleRecording
                    : _toggleRecording,
                  tooltip: _showAvatar 
                    ? (_isAvatarSpeaking 
                        ? "Tap to interrupt and speak"
                        : _canUseVoiceWithAvatar 
                          ? "Record voice for avatar chat" 
                          : "Wait for avatar...")
                    : "Record voice message",
                ),
                
                // Send button
                IconButton(
                  icon: Icon(
                    Icons.send, 
                    size: 20,
                    color: _controller.text.trim().isNotEmpty ? Colors.blue : Colors.grey,
                  ),
                  onPressed: () {
                    final text = _controller.text.trim();
                    if (text.isNotEmpty) {
                      FocusScope.of(context).unfocus();
                      _lastInputWasVoice = false;
                      _sendMessage(text);
                    }
                  },
                  tooltip: "Send Message",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) return Center(child: CircularProgressIndicator());

    final chatProvider = Provider.of<ChatProvider>(context);
    const double sidePanelWidth = 250.0;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              left: _showSidePanel ? sidePanelWidth : 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Column(
                children: [
                  SizedBox(height: kHeaderHeight),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              // iframe Avatar section
                              _buildAvatarSection(),
                              
                              Expanded(
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: chatProvider.messages.isEmpty
                                                ? const Center(
                                                    child: Text(
                                                      "Welcome! How can I help?",
                                                      style: TextStyle(
                                                        fontSize: 22,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.black87,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  )
                                                : ListView.builder(
                                                    controller: _scrollController,
                                                    padding: const EdgeInsets.only(
                                                      left: 16.0,
                                                      right: 16.0,
                                                      bottom: 16.0,
                                                    ),
                                                    itemCount: chatProvider.messages.length,
                                                    itemBuilder: (context, index) {
                                                      final message = chatProvider.messages[index];
                                                      return buildMessage(message, context);
                                                    },
                                                  ),
                                          ),
                                          
                                          // Show typing indicator separately if active
                                          if (_showTypingIndicator)
                                            Container(
                                              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 24),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[300],
                                                      borderRadius: BorderRadius.circular(18),
                                                    ),
                                                    child: const Text(
                                                      "AI is thinking...",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey,
                                                        fontStyle: FontStyle.italic,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    _buildInputField(),
                                    SizedBox(height: 20.h),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            ChatSidePanel(
              isOpen: _showSidePanel,
              onClose: () {
                setState(() {
                  _showSidePanel = false;
                });
              },
              onNewConversation: () {
                _startNewSession();
                setState(() {
                  _showSidePanel = false;
                });
              },
              onSearch: () {
                print('Search clicked!');
                setState(() {
                  _showSidePanel = false;
                });
              },
              onChatSelected: (String selectedChatId) {
                setState(() {
                  _selectedChatId = selectedChatId;
                  _showSidePanel = false;
                });
              },
            ),

            // Hamburger menu
            Positioned(
              top: 0,
              left: 0,
              child: SizedBox(
                height: kHeaderHeight,
                child: SafeArea(
                  child: IconButton(
                    icon: const Icon(Icons.menu, size: 28, color: Colors.black87),
                    onPressed: () {
                      setState(() {
                        _showSidePanel = !_showSidePanel;
                      });
                    },
                  ),
                ),
              ),
            ),

            const HomeScreenDesign(),
            const HomeScreenDesign2(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (kIsWeb) {
      _avatarLipSync.dispose();
      _browserSpeech.dispose();
    } else {
      _mobileAvatarService.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

}