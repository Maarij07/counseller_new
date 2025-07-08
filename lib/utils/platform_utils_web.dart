// Web-specific platform utilities implementation
import 'dart:html' as html;

/// Web implementation of platform utilities
class PlatformUtilsImpl {
  /// Set the document title in web browser
  static void setDocumentTitle(String title) {
    html.document.title = title;
  }
}
