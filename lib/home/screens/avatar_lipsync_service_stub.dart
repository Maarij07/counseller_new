// lib/home/screens/avatar_lipsync_service_stub.dart

/// Stub implementation for avatar lip sync service on non-web platforms
class AvatarLipSyncService {
  bool _isInitialized = false;
  
  Future<void> initialize() async {
    print("⚠️ Avatar Lip Sync Service not available on this platform");
    _isInitialized = false;
  }
  
  Future<bool> initializeAvatar(String avatarUrl) async {
    print("❌ Avatar Lip Sync Service not available on this platform");
    return false;
  }
  
  Future<void> speakText(String text, {double speed = 1.0}) async {
    print("❌ Avatar Lip Sync Service not available on this platform");
  }
  
  void stopLipSync() {
    print("❌ Avatar Lip Sync Service not available on this platform");
  }
  
  void setMouthExpression({double open = 0.0, double smile = 0.0, double pucker = 0.0}) {
    print("❌ Avatar Lip Sync Service not available on this platform");
  }
  
  void resetMouth() {
    print("❌ Avatar Lip Sync Service not available on this platform");
  }
  
  String? get viewType => null;
  bool get isInitialized => _isInitialized;
  bool get isIframeReady => false;
  bool get isAvatarLoaded => false;
  bool get isSpeaking => false;
  
  void dispose() {
    print("🗑️ Avatar Lip Sync Service disposed (stub)");
  }
}
