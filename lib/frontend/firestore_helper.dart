import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phychological_counselor/main/navigation/routes/name.dart';

Future<void> signUpAndSaveUser({
  bool isAdmin = false,

  required BuildContext context,
  required String firstName,
  required String lastName,
  required String email,
  required String password,
  required String age,
  required String gender,
}) async {
  try {
    // 🟢 שלב 1: רישום המשתמש בפועל ב־Firebase Authentication
    final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user == null) {
      throw Exception("לא נוצר משתמש.");
    }
    final collection = isAdmin ? 'admin' : 'users';

    // 🟢 שלב 2: שמירת המשתמש ב־Firestore
await FirebaseFirestore.instance.collection(collection).doc(user.uid).set({
      'userId': user.uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password, // ⚠️ אל תשאירי את זה בפרודקשן!
      'age': int.tryParse(age),
      'gender': gender,
      'createdAt': FieldValue.serverTimestamp(),
    });
if (!isAdmin) {
      await FirebaseFirestore.instance.collection('notifications').add({
        'type': 'signup',
  'message': '$firstName $lastName registered for the website',
        'timestamp': FieldValue.serverTimestamp(),
        'userEmail': email,
      });
    }
    // ניווט למסך הבית
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );

  } on FirebaseAuthException catch (e) {
    String message;
    if (e.code == 'email-already-in-use') {
      message = 'האימייל כבר בשימוש.';
    } else if (e.code == 'weak-password') {
      message = 'הסיסמה חלשה מדי.';
    } else {
      message = 'שגיאה בהרשמה: ${e.message}';
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('שגיאה כללית: $e')));
  }
}
