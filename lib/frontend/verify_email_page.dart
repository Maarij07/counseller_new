// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});
  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool _isSending     = false;
  bool _isChecking    = false;
  final bool _emailVerified = false;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
  }

  void _startVerificationCheck() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      await _checkEmailVerified();
      return !_emailVerified;
    });
  }

  Future<void> _checkEmailVerified() async {
    setState(() => _isChecking = true);
    final user = FirebaseAuth.instance.currentUser!;
    await user.reload();
    final updatedUser = FirebaseAuth.instance.currentUser!;

     if (updatedUser.emailVerified) {
      // 3. ניווט למסך הבית
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('המייל עדיין לא מאומת. נסי שוב בעוד רגע.')),
      );
    }

    setState(() => _isChecking = false);
  }


  Future<void> _resendVerification() async {
    setState(() => _isSending = true);
    final user = FirebaseAuth.instance.currentUser!;
    await user.sendEmailVerification();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('מייל אימות נוסף נשלח.')),
    );
    setState(() => _isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('אימות מייל')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'אנא אמת את כתובת המייל בה קיבלת קישור. '
              'כשסיימת, חזרה לאפליקציה לבדיקה אוטומטית.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_isChecking) const CircularProgressIndicator(),
            ElevatedButton(
              onPressed: _isSending ? null : _resendVerification,
              child: Text(_isSending ? 'שולח...' : 'שלחי שוב אימות'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _checkEmailVerified,
              child: const Text('בדוק שוב'),
            ),
          ],
        ),
      ),
    );
  }
}
