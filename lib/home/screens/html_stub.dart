// lib/home/screens/html_stub.dart


// Stub for html.HtmlElement and related classes
class HtmlElement {
  String? id;
  String? className;
  
  void setAttribute(String name, String value) {}
  String? getAttribute(String name) => null;
  void remove() {}
}

class Document {
  HtmlElement? getElementById(String id) => null;
  HtmlElement createElement(String tagName) => HtmlElement();
}

class Window {
  Document get document => Document();
}

// Global objects that dart:html would provide
final Document document = Document();
final Window window = Window();

// Any other dart:html classes that might be used
// Add them here as needed with stub implementations
