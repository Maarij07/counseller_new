// Web-specific platform utilities implementation
// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;

/// Web implementation of platform utilities
class PlatformUtilsImpl {
  /// Set the document title in web browser
  static void setDocumentTitle(String title) {
    html.document.title = title;
  }
}
