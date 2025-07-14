// lib/home/screens/mobile_avatar_service.dart

// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MobileAvatarService extends ChangeNotifier {
  bool _isInitialized = false;
  bool _isAvatarLoaded = false;
  bool _isSpeaking = false;
  bool _isAnimating = false;
  
  // Animation controllers and states
  double _jawOpen = 0.0;
  double _mouthOpen = 0.0;
  double _mouthSmile = 0.0;
  double _mouthFunnel = 0.0;
  double _mouthPucker = 0.0;
  
  // Natural animation states
  double _eyeBlinkLeft = 0.0;
  double _eyeBlinkRight = 0.0;
  double _browUp = 0.0;
  double _cheekPuff = 0.0;
  
  // Hand gesture states
  double _leftHandX = -0.3;
  double _leftHandY = 0.8;
  double _leftHandRotation = 0.0;
  double _rightHandX = 0.3;
  double _rightHandY = 0.8;
  double _rightHandRotation = 0.0;
  
  // Animation timing
  Timer? _lipSyncTimer;
  Timer? _naturalAnimationTimer;
  Timer? _gestureTimer;
  
  final FlutterTts _tts = FlutterTts();
  final LipSyncEngine _lipSyncEngine = LipSyncEngine();

  // Getters for animation values
  double get jawOpen => _jawOpen;
  double get mouthOpen => _mouthOpen;
  double get mouthSmile => _mouthSmile;
  double get mouthFunnel => _mouthFunnel;
  double get mouthPucker => _mouthPucker;
  double get eyeBlinkLeft => _eyeBlinkLeft;
  double get eyeBlinkRight => _eyeBlinkRight;
  double get browUp => _browUp;
  double get cheekPuff => _cheekPuff;
  double get leftHandX => _leftHandX;
  double get leftHandY => _leftHandY;
  double get leftHandRotation => _leftHandRotation;
  double get rightHandX => _rightHandX;
  double get rightHandY => _rightHandY;
  double get rightHandRotation => _rightHandRotation;
  
  bool get isInitialized => _isInitialized;
  bool get isAvatarLoaded => _isAvatarLoaded;
  bool get isSpeaking => _isSpeaking;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize TTS
      await _tts.setLanguage("en-US");
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(1.0);
      
      // Initialize lip sync engine
      _lipSyncEngine.initialize();
      
      // Start natural animations
      _startNaturalAnimations();
      
      _isInitialized = true;
      print("✅ Mobile Avatar Service initialized");
    } catch (e) {
      print("❌ Failed to initialize Mobile Avatar Service: $e");
    }
  }

  Future<bool> loadAvatar(String avatarPath) async {
    if (!_isInitialized) {
      print("❌ Service not initialized");
      return false;
    }

    try {
      print("📦 Loading mobile avatar: $avatarPath");
      
      // Simulate avatar loading (in real implementation, you'd load the 3D model)
      await Future.delayed(const Duration(milliseconds: 1500));
      
      _isAvatarLoaded = true;
      print("✅ Mobile avatar loaded successfully");
      notifyListeners();
      return true;
    } catch (e) {
      print("❌ Failed to load avatar: $e");
      return false;
    }
  }

  Future<void> speakText(String text, {double speed = 1.0}) async {
    if (!_isInitialized) {
      print("❌ Service not initialized");
      return;
    }

    if (_isSpeaking) {
      stopSpeaking();
    }

    try {
      print("🗣️ Mobile avatar speaking: $text");
      _isSpeaking = true;
      notifyListeners();

      // Generate phoneme sequence
      final phonemeSequence = _lipSyncEngine.textToPhonemes(text);
      print("🎯 Generated phoneme sequence: ${phonemeSequence.length} phonemes");

      // Analyze gestures
      final gestures = _lipSyncEngine.analyzeTextForGestures(text);
      final gestureTimings = _lipSyncEngine.planGestureTimings(text, phonemeSequence, gestures);
      
      if (gestureTimings.isNotEmpty) {
        _scheduleGestures(gestureTimings);
      }

      // Start lip sync animation
      _startLipSyncAnimation(phonemeSequence);

      // Start TTS
      await _tts.setSpeechRate(speed);
      await _tts.speak(text);

      // Wait for speech to complete
      await _waitForSpeechCompletion(phonemeSequence);

    } catch (e) {
      print("❌ Error speaking text: $e");
    } finally {
      _stopLipSync();
    }
  }

  void _startLipSyncAnimation(List<PhonemeData> phonemeSequence) {
    _isAnimating = true;
    int currentPhonemeIndex = 0;
    int phonemeStartTime = DateTime.now().millisecondsSinceEpoch;

    _lipSyncTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!_isAnimating || !_isSpeaking) {
        timer.cancel();
        return;
      }

      final elapsed = DateTime.now().millisecondsSinceEpoch - phonemeStartTime;

      if (currentPhonemeIndex < phonemeSequence.length) {
        final currentPhoneme = phonemeSequence[currentPhonemeIndex];

        // Check if we need to move to next phoneme
        if (elapsed >= currentPhoneme.duration) {
          currentPhonemeIndex++;
          phonemeStartTime = DateTime.now().millisecondsSinceEpoch;

          if (currentPhonemeIndex >= phonemeSequence.length) {
            timer.cancel();
            return;
          }
        }

        // Apply viseme for current phoneme
        final viseme = _lipSyncEngine.getVisemeForPhoneme(currentPhoneme.phoneme);
        final progress = (elapsed / currentPhoneme.duration).clamp(0.0, 1.0);
        final easeInOut = _easeInOutCubic(progress);

        _applyViseme(viseme, easeInOut);
      }
    });
  }

  void _applyViseme(VisemeData viseme, double intensity) {
    _jawOpen = viseme.jawOpen * intensity;
    _mouthOpen = viseme.mouthOpen * intensity;
    _mouthSmile = viseme.mouthSmile * intensity;
    _mouthFunnel = viseme.mouthFunnel * intensity;
    _mouthPucker = viseme.mouthPucker * intensity;
    
    notifyListeners();
  }

  double _easeInOutCubic(double t) {
    return t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3) / 2;
  }

  void _scheduleGestures(List<GestureTiming> gestureTimings) {
    for (final gesture in gestureTimings) {
      Timer(Duration(milliseconds: gesture.startTime.toInt()), () {
        _playHandGesture(gesture.type, gesture.duration.toInt());
      });
    }
  }

  void _playHandGesture(String gestureType, int duration) {
    print("🤲 Playing mobile gesture: $gestureType");

    switch (gestureType) {
      case 'greeting':
        _animateGreetingWave(duration);
        break;
      case 'explaining':
        _animateExplainingGesture(duration);
        break;
      case 'emphasizing':
        _animateEmphasizingGesture(duration);
        break;
      case 'welcoming':
        _animateWelcomingGesture(duration);
        break;
      default:
        _animateIdleGesture();
    }
  }

  void _animateGreetingWave(int duration) {
    final steps = duration ~/ 100;
    int step = 0;

    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (step >= steps) {
        timer.cancel();
        _resetHandPosition();
        return;
      }

      final progress = step / steps;
      final wave = sin(progress * pi * 4) * 0.3;

      _rightHandX = 0.3 + wave * 0.2;
      _rightHandY = 0.8 + (wave.abs() * 0.1);
      _rightHandRotation = wave * 0.5;

      notifyListeners();
      step++;
    });
  }

  void _animateExplainingGesture(int duration) {
    final steps = duration ~/ 150;
    int step = 0;

    Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (step >= steps) {
        timer.cancel();
        _resetHandPosition();
        return;
      }

      final progress = step / steps;
      final upDown = sin(progress * pi * 2) * 0.15;
      final openClose = sin(progress * pi * 3) * 0.2;

      _leftHandX = -0.4 + openClose;
      _leftHandY = 0.8 + upDown;
      _rightHandX = 0.4 - openClose;
      _rightHandY = 0.8 + upDown;

      notifyListeners();
      step++;
    });
  }

  void _animateEmphasizingGesture(int duration) {
    final steps = duration ~/ 120;
    int step = 0;

    Timer.periodic(const Duration(milliseconds: 120), (timer) {
      if (step >= steps) {
        timer.cancel();
        _resetHandPosition();
        return;
      }

      final progress = step / steps;
      final point = progress < 0.5 ? progress * 2 : 2 - (progress * 2);

      _rightHandX = 0.2 + point * 0.3;
      _rightHandY = 1.1;
      _rightHandRotation = point * 0.3;

      notifyListeners();
      step++;
    });
  }

  void _animateWelcomingGesture(int duration) {
    final steps = duration ~/ 200;
    int step = 0;

    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (step >= steps) {
        timer.cancel();
        _resetHandPosition();
        return;
      }

      final progress = step / steps;
      final openness = sin(progress * pi) * 0.6;

      _leftHandX = -0.3 - openness;
      _leftHandY = 1.2;
      _leftHandRotation = -openness * 0.5;
      _rightHandX = 0.3 + openness;
      _rightHandY = 1.2;
      _rightHandRotation = openness * 0.5;

      notifyListeners();
      step++;
    });
  }

  void _animateIdleGesture() {
    final time = DateTime.now().millisecondsSinceEpoch * 0.0005;
    final subtleX = sin(time) * 0.02;
    final subtleY = sin(time * 0.7) * 0.01;

    _leftHandX = -0.3 + subtleX;
    _leftHandY = 0.8 + subtleY;
    _rightHandX = 0.3 - subtleX;
    _rightHandY = 0.8 + subtleY;

    notifyListeners();
  }

  void _resetHandPosition() {
    _leftHandX = -0.3;
    _leftHandY = 0.8;
    _leftHandRotation = 0.0;
    _rightHandX = 0.3;
    _rightHandY = 0.8;
    _rightHandRotation = 0.0;
    notifyListeners();
  }

  void _startNaturalAnimations() {
    _naturalAnimationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _updateNaturalAnimations();
    });
  }

  void _updateNaturalAnimations() {
    final time = DateTime.now().millisecondsSinceEpoch * 0.001;

    // Natural blinking
    if (Random().nextDouble() < 0.02) { // 2% chance per frame
      _triggerBlink();
    }

    // Subtle brow movements during speech
    if (_isSpeaking) {
      _browUp = (sin(time * 0.5) + 1) * 0.5 * 0.2;
      _cheekPuff = (sin(time * 0.3) + 1) * 0.5 * 0.1;
    } else {
      _browUp = 0.0;
      _cheekPuff = 0.0;
    }

    notifyListeners();
  }

  void _triggerBlink() {
    _eyeBlinkLeft = 1.0;
    _eyeBlinkRight = 1.0;
    notifyListeners();

    Timer(const Duration(milliseconds: 150), () {
      _eyeBlinkLeft = 0.0;
      _eyeBlinkRight = 0.0;
      notifyListeners();
    });
  }

  Future<void> _waitForSpeechCompletion(List<PhonemeData> phonemeSequence) async {
    final totalDuration = phonemeSequence.fold(0, (sum, p) => sum + p.duration) + 1000;
    await Future.delayed(Duration(milliseconds: totalDuration));
  }

  void stopSpeaking() {
    _isSpeaking = false;
    _isAnimating = false;
    
    _tts.stop();
    _stopLipSync();
    
    print("🛑 Mobile avatar stopped speaking");
    notifyListeners();
  }

  void _stopLipSync() {
    _lipSyncTimer?.cancel();
    _gestureTimer?.cancel();
    
    // Reset mouth to neutral
    _jawOpen = 0.0;
    _mouthOpen = 0.0;
    _mouthSmile = 0.0;
    _mouthFunnel = 0.0;
    _mouthPucker = 0.0;
    
    _resetHandPosition();
    notifyListeners();
  }

  void setMouthExpression({double open = 0.0, double smile = 0.0, double pucker = 0.0}) {
    if (!_isSpeaking) {
      _mouthOpen = open;
      _mouthSmile = smile;
      _mouthPucker = pucker;
      notifyListeners();
    }
  }

  void resetMouth() {
    if (!_isSpeaking) {
      _jawOpen = 0.0;
      _mouthOpen = 0.0;
      _mouthSmile = 0.0;
      _mouthFunnel = 0.0;
      _mouthPucker = 0.0;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    print("🗑️ Disposing mobile avatar service");
    
    stopSpeaking();
    _naturalAnimationTimer?.cancel();
    _lipSyncTimer?.cancel();
    _gestureTimer?.cancel();
    
    super.dispose();
  }
}

// Supporting classes for lip sync engine
class LipSyncEngine {
  final Map<String, VisemeData> _visemeMap = {
    'sil': VisemeData(jawOpen: 0.0, mouthOpen: 0.0, mouthSmile: 0.0, mouthFunnel: 0.0, mouthPucker: 0.0),
    'AA': VisemeData(jawOpen: 0.9, mouthOpen: 0.8, mouthSmile: 0.0, mouthFunnel: 0.0, mouthPucker: 0.0),
    'AE': VisemeData(jawOpen: 0.7, mouthOpen: 0.6, mouthSmile: 0.3, mouthFunnel: 0.0, mouthPucker: 0.0),
    'AH': VisemeData(jawOpen: 0.8, mouthOpen: 0.7, mouthSmile: 0.0, mouthFunnel: 0.0, mouthPucker: 0.0),
    'AO': VisemeData(jawOpen: 0.7, mouthOpen: 0.6, mouthSmile: 0.0, mouthFunnel: 0.5, mouthPucker: 0.3),
    'EH': VisemeData(jawOpen: 0.5, mouthOpen: 0.4, mouthSmile: 0.4, mouthFunnel: 0.0, mouthPucker: 0.0),
    'IY': VisemeData(jawOpen: 0.2, mouthOpen: 0.1, mouthSmile: 0.8, mouthFunnel: 0.0, mouthPucker: 0.0),
    'OW': VisemeData(jawOpen: 0.5, mouthOpen: 0.4, mouthSmile: 0.0, mouthFunnel: 0.8, mouthPucker: 0.5),
    'UW': VisemeData(jawOpen: 0.3, mouthOpen: 0.2, mouthSmile: 0.0, mouthFunnel: 0.9, mouthPucker: 0.6),
    'B': VisemeData(jawOpen: 0.0, mouthOpen: 0.0, mouthSmile: 0.0, mouthFunnel: 0.0, mouthPucker: 0.0),
    'M': VisemeData(jawOpen: 0.0, mouthOpen: 0.0, mouthSmile: 0.0, mouthFunnel: 0.0, mouthPucker: 0.0),
    'P': VisemeData(jawOpen: 0.0, mouthOpen: 0.0, mouthSmile: 0.0, mouthFunnel: 0.0, mouthPucker: 0.0),
    'F': VisemeData(jawOpen: 0.2, mouthOpen: 0.1, mouthSmile: 0.0, mouthFunnel: 0.0, mouthPucker: 0.0),
    'V': VisemeData(jawOpen: 0.2, mouthOpen: 0.1, mouthSmile: 0.0, mouthFunnel: 0.0, mouthPucker: 0.0),
    'TH': VisemeData(jawOpen: 0.3, mouthOpen: 0.2, mouthSmile: 0.0, mouthFunnel: 0.0, mouthPucker: 0.0),
    'S': VisemeData(jawOpen: 0.2, mouthOpen: 0.1, mouthSmile: 0.3, mouthFunnel: 0.0, mouthPucker: 0.0),
    'Z': VisemeData(jawOpen: 0.2, mouthOpen: 0.1, mouthSmile: 0.3, mouthFunnel: 0.0, mouthPucker: 0.0),
    'SH': VisemeData(jawOpen: 0.3, mouthOpen: 0.2, mouthSmile: 0.0, mouthFunnel: 0.6, mouthPucker: 0.0),
    'CH': VisemeData(jawOpen: 0.3, mouthOpen: 0.2, mouthSmile: 0.0, mouthFunnel: 0.5, mouthPucker: 0.0),
    'T': VisemeData(jawOpen: 0.3, mouthOpen: 0.2, mouthSmile: 0.0, mouthFunnel: 0.0, mouthPucker: 0.0),
    'D': VisemeData(jawOpen: 0.3, mouthOpen: 0.2, mouthSmile: 0.0, mouthFunnel: 0.0, mouthPucker: 0.0),
    'L': VisemeData(jawOpen: 0.4, mouthOpen: 0.3, mouthSmile: 0.2, mouthFunnel: 0.0, mouthPucker: 0.0),
    'R': VisemeData(jawOpen: 0.4, mouthOpen: 0.3, mouthSmile: 0.0, mouthFunnel: 0.4, mouthPucker: 0.0),
    'N': VisemeData(jawOpen: 0.3, mouthOpen: 0.2, mouthSmile: 0.0, mouthFunnel: 0.0, mouthPucker: 0.0),
    'K': VisemeData(jawOpen: 0.4, mouthOpen: 0.3, mouthSmile: 0.0, mouthFunnel: 0.0, mouthPucker: 0.0),
    'G': VisemeData(jawOpen: 0.4, mouthOpen: 0.3, mouthSmile: 0.0, mouthFunnel: 0.0, mouthPucker: 0.0),
    'W': VisemeData(jawOpen: 0.3, mouthOpen: 0.2, mouthSmile: 0.0, mouthFunnel: 0.8, mouthPucker: 0.5),
    'Y': VisemeData(jawOpen: 0.3, mouthOpen: 0.2, mouthSmile: 0.6, mouthFunnel: 0.0, mouthPucker: 0.0),
    'H': VisemeData(jawOpen: 0.4, mouthOpen: 0.3, mouthSmile: 0.0, mouthFunnel: 0.0, mouthPucker: 0.0),
  };

  final Map<String, List<String>> _gestureKeywords = {
    'greeting': ['hello', 'hi', 'welcome', 'good morning', 'good afternoon', 'good evening'],
    'explaining': ['because', 'therefore', 'let me explain', 'you see', 'for example', 'understand'],
    'emphasizing': ['important', 'remember', 'focus', 'key point', 'crucial', 'must', 'definitely'],
    'welcoming': ['come in', 'please', 'feel free', 'comfortable', 'welcome', 'open', 'together'],
  };

  final Map<String, int> _phonemeDurations = {
    'AA': 180, 'AE': 160, 'AH': 140, 'AO': 170, 'EH': 150, 'IY': 160, 'OW': 180, 'UW': 170,
    'B': 60, 'M': 80, 'P': 60, 'F': 100, 'V': 100, 'TH': 100, 'S': 110, 'Z': 110,
    'SH': 120, 'CH': 90, 'T': 60, 'D': 70, 'L': 90, 'R': 100, 'N': 80, 'K': 70,
    'G': 70, 'W': 80, 'Y': 70, 'H': 90, 'sil': 150,
  };

  void initialize() {
    print("🎯 Mobile Lip Sync Engine initialized");
  }

  List<PhonemeData> textToPhonemes(String text) {
    final words = text.toLowerCase().replaceAll(RegExp(r'[.,!?;:]'), '').split(RegExp(r'\s+'));
    final phonemeSequence = <PhonemeData>[];

    for (int i = 0; i < words.length; i++) {
      if (i > 0) {
        phonemeSequence.add(PhonemeData(phoneme: 'sil', duration: 100, word: '[pause]'));
      }

      final word = words[i];
      final phonemes = _getWordPhonemes(word);
      
      for (final phoneme in phonemes) {
        phonemeSequence.add(PhonemeData(
          phoneme: phoneme,
          duration: _phonemeDurations[phoneme] ?? 120,
          word: word,
        ));
      }
    }

    phonemeSequence.add(PhonemeData(phoneme: 'sil', duration: 200, word: '[end]'));
    return phonemeSequence;
  }

  List<String> _getWordPhonemes(String word) {
    // Simplified phoneme mapping - in a real implementation you'd have a comprehensive dictionary
    switch (word.toLowerCase()) {
      case 'hello': return ['H', 'AH', 'L', 'OW'];
      case 'hi': return ['H', 'AY'];
      case 'how': return ['H', 'AW'];
      case 'are': return ['AA', 'R'];
      case 'you': return ['Y', 'UW'];
      case 'today': return ['T', 'AH', 'D', 'EY'];
      case 'good': return ['G', 'UH', 'D'];
      case 'morning': return ['M', 'AO', 'R', 'N', 'IH', 'NG'];
      case 'welcome': return ['W', 'EH', 'L', 'K', 'AH', 'M'];
      case 'thank': return ['TH', 'AE', 'NG', 'K'];
      case 'thanks': return ['TH', 'AE', 'NG', 'K', 'S'];
      default: return _approximatePhonemes(word);
    }
  }

  List<String> _approximatePhonemes(String word) {
    final phonemes = <String>[];
    final letters = word.toLowerCase().split('');

    for (int i = 0; i < letters.length; i++) {
      final letter = letters[i];
      final nextLetter = i + 1 < letters.length ? letters[i + 1] : null;

      switch (letter) {
        case 'a': phonemes.add('AE'); break;
        case 'e': phonemes.add('EH'); break;
        case 'i': phonemes.add('IY'); break;
        case 'o': phonemes.add('OW'); break;
        case 'u': phonemes.add('UW'); break;
        case 'b': phonemes.add('B'); break;
        case 'm': phonemes.add('M'); break;
        case 'p': phonemes.add('P'); break;
        case 'f': phonemes.add('F'); break;
        case 'v': phonemes.add('V'); break;
        case 's': phonemes.add('S'); break;
        case 't': phonemes.add('T'); break;
        case 'd': phonemes.add('D'); break;
        case 'l': phonemes.add('L'); break;
        case 'r': phonemes.add('R'); break;
        case 'n': phonemes.add('N'); break;
        case 'k': case 'c': phonemes.add('K'); break;
        case 'g': phonemes.add('G'); break;
        case 'w': phonemes.add('W'); break;
        case 'y': phonemes.add('Y'); break;
        case 'h': phonemes.add('H'); break;
        default: phonemes.add('AH'); break;
      }
    }

    return phonemes.isNotEmpty ? phonemes : ['AH'];
  }

  VisemeData getVisemeForPhoneme(String phoneme) {
    return _visemeMap[phoneme] ?? _visemeMap['sil']!;
  }

  List<String> analyzeTextForGestures(String text) {
    final lowerText = text.toLowerCase();
    final detectedGestures = <String>[];

    for (final entry in _gestureKeywords.entries) {
      for (final keyword in entry.value) {
        if (lowerText.contains(keyword)) {
          if (!detectedGestures.contains(entry.key)) {
            detectedGestures.add(entry.key);
          }
        }
      }
    }

    if (detectedGestures.isEmpty) {
      if (lowerText.contains('?')) {
        detectedGestures.add('emphasizing');
      } else if (lowerText.length > 50) {
        detectedGestures.add('explaining');
      }
    }

    return detectedGestures;
  }

  List<GestureTiming> planGestureTimings(String text, List<PhonemeData> phonemeSequence, List<String> gestures) {
    final gestureTimings = <GestureTiming>[];
    final totalDuration = phonemeSequence.fold(0, (sum, p) => sum + p.duration);

    if (gestures.isNotEmpty) {
      for (int i = 0; i < gestures.length; i++) {
        final startTime = (totalDuration / gestures.length) * i;
        gestureTimings.add(GestureTiming(
          type: gestures[i],
          startTime: startTime.toDouble(),
          duration: 2000.0,
        ));
      }
    }

    return gestureTimings;
  }
}

class PhonemeData {
  final String phoneme;
  final int duration;
  final String word;

  PhonemeData({required this.phoneme, required this.duration, required this.word});
}

class VisemeData {
  final double jawOpen;
  final double mouthOpen;
  final double mouthSmile;
  final double mouthFunnel;
  final double mouthPucker;

  VisemeData({
    required this.jawOpen,
    required this.mouthOpen,
    required this.mouthSmile,
    required this.mouthFunnel,
    required this.mouthPucker,
  });
}

class GestureTiming {
  final String type;
  final double startTime;
  final double duration;

  GestureTiming({required this.type, required this.startTime, required this.duration});
}
