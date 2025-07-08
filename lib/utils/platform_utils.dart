// Platform utilities for handling web-specific operations
import 'package:flutter/foundation.dart';

// Conditional imports for web-only features
import 'platform_utils_stub.dart'
    if (dart.library.html) 'platform_utils_web.dart'
    if (dart.library.io) 'platform_utils_mobile.dart';

/// Abstract class defining platform-specific operations
abstract class PlatformUtils {
  /// Set the document title (web-only operation)
  static void setDocumentTitle(String title) {
    if (kIsWeb) {
      PlatformUtilsImpl.setDocumentTitle(title);
    }
    // On mobile platforms, this is a no-op
  }
  
  /// Check if running on web platform
  static bool get isWeb => kIsWeb;
  
  /// Check if running on mobile platform
  static bool get isMobile => !kIsWeb;
}
