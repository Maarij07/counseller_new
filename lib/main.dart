// import 'package:flutter/material.dart';

// import 'main/app.dart';
// import 'main/global.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart'; // 📌 ודא שהייבוא הזה קיים
// import 'ai_chat/provider/chat_provider.dart';
// import 'main/app.dart';
// import 'main/global.dart';
// import 'frontend/firebase_initializer.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// //import 'frontend/therapy_bot_page.dart';
// //import 'package:phychological_counselor/frontend/therapy_bot_page.dart'; // הייבוא של TherapyBotPage


// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await dotenv.load(fileName: ".env");

//   await FirebaseInitializer.initialize(); // ← זה מחליף את Firebase.initializeApp

//   await Global.init();

//   testFirestoreAccess(); // ← בדיקת חיבור ל-Firestore
//   runApp(const MyApp());
// }

// void testFirestoreAccess() async {
//   try {
//     final snapshot = await FirebaseFirestore.instance.collection('users').get();
//     print("✅ Success! Got ${snapshot.docs.length} documents from Firestore.");
//   } catch (e) {
//     print("❌ Firestore access failed: $e");
//   }
// }
// lib/main.dart

import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'main/app.dart';
import 'main/global.dart';
import 'frontend/firebase_initializer.dart';
import 'ai_chat/provider/chat_provider.dart';
import 'utils/platform_utils.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // טען קודם כל את הקובץ .env (אם יש צורך)
  await dotenv.load(fileName: ".env");

  // פעל אתחול Firebase (יחד עם בדיקת ה-duplicate שהוספנו)
  // Updating this
    if(Platform.isAndroid)
    {
      await FirebaseInitializer.initialize();
    }
    else{
    if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
    }
  // אתחול משתני Global (אם יש)
  await Global.init();

  // בדיקה ראשונית של Firestore
  testFirestoreAccess();
  
  // Set document title (web-only, safe for all platforms)
  PlatformUtils.setDocumentTitle('Hewar');

  // לבסוף הרץ את האפליקציה
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        // אם יש עוד Providers, הוסיפו אותם כאן
      ],
      child: const MyApp(),
    ),
  );
}

/// פונקציה לבדוק גישה ראשונית ל־Firestore
Future<void> testFirestoreAccess() async {
  try {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    print("✅ Success! Got ${snapshot.docs.length} documents from Firestore.");
  } catch (e) {
    print("❌ Firestore access failed: $e");
  }
}
