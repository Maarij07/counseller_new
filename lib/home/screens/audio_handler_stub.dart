// // lib/home/screens/audio_handler_stub.dart

/// AudioHandler “stub” לשאר הפלטפורמות שלא Web ולא Mobile.
/// כל קריאה ל-startRecording() או ל-stopAndTranscribe() כאן תזרוק UnimplementedError.
class AudioHandler {
  Future<void> startRecording() async {
    throw UnimplementedError(
      'AudioHandler.startRecording() אינו מיושם בפלטפורמה זו.',
    );
  }

  Future<String> stopAndTranscribe(bool isWeb) async {
    throw UnimplementedError(
      'AudioHandler.stopAndTranscribe() אינו מיושם בפלטפורמה זו.',
    );
  }
}
