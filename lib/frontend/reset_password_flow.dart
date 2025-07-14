// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class ResetPasswordFlow extends StatefulWidget {
  const ResetPasswordFlow({super.key});

  @override
  _ResetPasswordFlowState createState() => _ResetPasswordFlowState();
}

class _ResetPasswordFlowState extends State<ResetPasswordFlow> {
  final emailController = TextEditingController();
  final codeController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
bool obscureNewPassword = true;
bool obscureConfirmPassword = true;

  String generatedCode = '';
  bool showResetFields = false;

  String generateRandomCode() {
    final random = DateTime.now().millisecondsSinceEpoch.remainder(1000000);
    return random.toString().padLeft(6, '0');
  }

  Future<void> sendResetEmail(String email, String message) async {
    const serviceId = 'service_j0cu26o';
    const templateId = 'template_ud0zjcp';
    const userId = 'C6-8XJwSYTqFhyQUb';

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    final response = await http.post(
      url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: json.encode({
      'service_id': serviceId,
      'template_id': templateId,
      'user_id': userId,
      'template_params': {
        'email': email,     // ← תואם ל־{{email}} בתבנית
'code': generatedCode,
      },
    }),
  
    );

    if (response.statusCode == 200) {
      print('✅ Email sent successfully');
    } else {
      print('❌ Failed to send email');
      print('🔴 Error ${response.statusCode}: ${response.body}');
    }
  }
void handleSendCode() async {
  final email = emailController.text.trim();
  if (email.isEmpty) return;

  final firestore = FirebaseFirestore.instance;

  // בדוק ב־users
  final userQuery = await firestore.collection('users').where('email', isEqualTo: email).get();

  // אם לא נמצא ב־users, בדוק ב־admin
  final adminQuery = userQuery.docs.isEmpty
      ? await firestore.collection('admin').where('email', isEqualTo: email).get()
      : null;

  if (userQuery.docs.isEmpty && (adminQuery?.docs.isEmpty ?? true)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Email not found in Firestore")),
    );
    return;
  }

  generatedCode = generateRandomCode();
  await sendResetEmail(email, generatedCode);

  setState(() {
    showResetFields = true;
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Verification code sent")),
  );
}
void handleResetPassword() async {
  final email = emailController.text.trim();
  final enteredCode = codeController.text.trim();
  final newPassword = newPasswordController.text.trim();
  final confirmPassword = confirmPasswordController.text.trim();

  // בדיקת קוד אימות
  if (enteredCode != generatedCode) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Incorrect code")),
    );
    return;
  }

  // בדיקת התאמה בין סיסמה לאישור
  if (newPassword != confirmPassword) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Passwords do not match")),
    );
    return;
  }

  // בדיקת חוזק סיסמה
  if (newPassword.length < 8 ||
      !newPassword.contains(RegExp(r'[A-Z]')) ||
      !newPassword.contains(RegExp(r'[a-z]')) ||
      !newPassword.contains(RegExp(r'[0-9]')) ||
      !newPassword.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Password must be at least 8 characters and include:\n• Uppercase letter\n• Lowercase letter\n• Number\n• Special character",
        ),
        duration: Duration(seconds: 4),
      ),
    );
    return;
  }

  final firestore = FirebaseFirestore.instance;

  // חיפוש ב־users
  var query = await firestore.collection('users').where('email', isEqualTo: email).get();
  String collection = 'users';

  // אם לא נמצא שם — חפש ב־admin
  if (query.docs.isEmpty) {
    query = await firestore.collection('admin').where('email', isEqualTo: email).get();
    collection = 'admin';
  }

  // אם נמצא — עדכן את הסיסמה
  if (query.docs.isNotEmpty) {
    final docId = query.docs.first.id;

    await firestore.collection(collection).doc(docId).update({
      'password': newPassword,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Password updated successfully")),
    );

    Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("User not found")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reset Password"),
        backgroundColor: Colors.indigo.shade400,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: handleSendCode,
              child: Text(generatedCode.isEmpty ? "Send Code" : "Resend Code"),
            ),
            if (showResetFields) ...[
              TextField(
                controller: codeController,
                decoration: InputDecoration(labelText: "Enter Code"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "New Password"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Confirm Password"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: handleResetPassword,
                child: Text("Reset Password"),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
