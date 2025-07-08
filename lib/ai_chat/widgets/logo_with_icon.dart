import 'package:flutter/material.dart';

class LogoWithText extends StatelessWidget {
  const LogoWithText({super.key, required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // ← לא מציג כלום
  }
}
