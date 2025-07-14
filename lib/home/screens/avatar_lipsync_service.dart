// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'dart:ui_web' as ui_web;
import 'dart:convert';

class AvatarLipSyncService {
  bool _isInitialized = false;
  String? _viewType;
  html.IFrameElement? _iframe;
  bool _iframeReady = false;

  // Message handling
  final Map<String, Completer> _pendingRequests = {};
  int _requestId = 0;

  // Status tracking
  bool _isAvatarLoaded = false;
  bool _isSpeaking = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    if (kIsWeb) {
      await _registerIframeView();
      _setupMessageListener();
      _isInitialized = true;
      print("✅ iframe Avatar Service initialized");
    } else {
      print("⚠️ Avatar Service only works on web platform");
    }
  }

  Future<void> _registerIframeView() async {
    _viewType = 'avatar-iframe-view-${DateTime.now().millisecondsSinceEpoch}';

    ui_web.platformViewRegistry.registerViewFactory(_viewType!, (int viewId) {
      _iframe = html.IFrameElement()
        ..width = '100%'
        ..height = '100%'
        ..src = 'avatar_viewer.html'
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allowFullscreen = false;

      _iframe!.onLoad.listen((_) {
        print("🌐 iframe loaded successfully");
        _waitForIframeReady();
      });

      _iframe!.onError.listen((error) {
        print("❌ iframe load error: $error");
      });

      final container = html.DivElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.position = 'relative'
        ..style.overflow = 'hidden'
        ..append(_iframe!);

      return container;
    });
  }

  void _setupMessageListener() {
    html.window.onMessage.listen((html.MessageEvent event) {
      try {
        final data = event.data;
        if (data is Map && data['source'] == 'avatar-viewer') {
          _handleIframeMessage(Map<String, dynamic>.from(data)); // ✅ Fix applied here
        }
      } catch (e) {
        print("❌ Error handling iframe message: $e");
      }
    });
  }

  void _handleIframeMessage(Map<String, dynamic> message) {
    final String type = message['type'] ?? '';
    final dynamic data = message['data'] ?? {};

    print("📨 Received from iframe: $type");

    switch (type) {
      case 'initialized':
        _iframeReady = true;
        print("✅ iframe avatar viewer ready");
        break;

      case 'avatarLoaded':
        _isAvatarLoaded = data['success'] == true;
        print("📦 Avatar loaded: $_isAvatarLoaded");
        break;

      case 'morphTargetsFound':
        final count = data['count'] ?? 0;
        print("🎯 Found $count meshes with morph targets");
        break;

      case 'speechEnded':
        _isSpeaking = false;
        print("🗣️ Speech ended");
        break;

      case 'error':
        print("❌ iframe error: ${data['message']}");
        break;

      default:
        print("📝 Unknown iframe message: $type");
    }

    if (_pendingRequests.containsKey(type)) {
      _pendingRequests[type]!.complete(data);
      _pendingRequests.remove(type);
    }
  }

  Future<void> _waitForIframeReady() async {
    int attempts = 0;
    const maxAttempts = 100;

    while (!_iframeReady && attempts < maxAttempts) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }

    if (!_iframeReady) {
      print("⚠️ iframe not ready after 10 seconds");
    }
  }

  void _sendMessageToIframe(String type, Map<String, dynamic> data) {
    if (_iframe?.contentWindow != null) {
      try {
        final message = {
          'type': type,
          'data': data,
          'requestId': _requestId++,
        };
        _iframe!.contentWindow!.postMessage(message, '*');
        print("📤 Sent to iframe: $type");
      } catch (e) {
        print("❌ Failed to send message to iframe: $e");
      }
    } else {
      print("⚠️ iframe not available for messaging");
    }
  }

  String? get viewType => _viewType;

  Future<bool> initializeAvatar(String avatarUrl) async {
    if (!_isInitialized) {
      print("❌ Service not initialized");
      return false;
    }

    if (!kIsWeb) {
      print("❌ Not running on web platform");
      return false;
    }

    try {
      print("🎯 Initializing avatar with URL: $avatarUrl");

      await _waitForIframeReady();

      if (!_iframeReady) {
        print("❌ iframe not ready");
        return false;
      }

      _sendMessageToIframe('loadAvatar', {'url': avatarUrl});

      int attempts = 0;
      const maxAttempts = 300;

      while (!_isAvatarLoaded && attempts < maxAttempts) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }

      if (_isAvatarLoaded) {
        print("✅ Avatar initialized successfully");
        return true;
      } else {
        print("⚠️ Avatar initialization timed out, but iframe may still be working");
        return false;
      }

    } catch (e) {
      print("❌ Error initializing avatar: $e");
      return false;
    }
  }

  Future<void> speakText(String text, {double speed = 1.0}) async {
    if (!kIsWeb || !_isInitialized) {
      print("❌ Cannot speak - not on web or not initialized");
      return;
    }

    if (!_iframeReady) {
      print("⚠️ iframe not ready, attempting to speak anyway");
    }

    try {
      print("🗣️ Avatar speaking: $text");

      _isSpeaking = true;
      _sendMessageToIframe('speak', {
        'text': text,
        'speed': speed,
      });

      int attempts = 0;
      const maxAttempts = 300;

      while (_isSpeaking && attempts < maxAttempts) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }

      if (attempts >= maxAttempts) {
        print("⚠️ Speech timeout, forcing stop");
        stopLipSync();
      }

    } catch (e) {
      print("❌ Error speaking text: $e");
      _isSpeaking = false;
    }
  }

  void stopLipSync() {
    if (!kIsWeb) return;

    try {
      print("🛑 Stopping lip sync");
      _isSpeaking = false;
      _sendMessageToIframe('stopSpeaking', {});
    } catch (e) {
      print("❌ Error stopping lip sync: $e");
    }
  }

  void setMouthExpression({double open = 0.0, double smile = 0.0, double pucker = 0.0}) {
    if (!kIsWeb || !_isInitialized) return;

    try {
      _sendMessageToIframe('setMouthExpression', {
        'open': open,
        'smile': smile,
        'pucker': pucker,
      });
    } catch (e) {
      print("❌ Error setting mouth expression: $e");
    }
  }

  void resetMouth() {
    if (!kIsWeb || !_isInitialized) return;

    try {
      _sendMessageToIframe('resetMouth', {});
    } catch (e) {
      print("❌ Error resetting mouth: $e");
    }
  }

  bool get isInitialized => _isInitialized;
  bool get isIframeReady => _iframeReady;
  bool get isAvatarLoaded => _isAvatarLoaded;
  bool get isSpeaking => _isSpeaking;

  void dispose() {
    print("🗑️ Disposing avatar service");

    stopLipSync();

    _pendingRequests.forEach((key, completer) {
      if (!completer.isCompleted) {
        completer.completeError('Service disposed');
      }
    });
    _pendingRequests.clear();

    _iframeReady = false;
    _isAvatarLoaded = false;
    _isSpeaking = false;

    if (_iframe != null) {
      try {
        _sendMessageToIframe('dispose', {});
      } catch (e) {
        print("⚠️ Error sending dispose message: $e");
      }
    }
  }
}
