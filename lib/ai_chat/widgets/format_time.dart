String formatTime(int seconds) {
  final min = seconds ~/ 60;
  final sec = seconds % 60;
  final secStr = sec < 10 ? '0$sec' : '$sec';
  return '$min:$secStr';
}