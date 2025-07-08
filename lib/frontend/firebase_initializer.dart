// // firebase_initializer.dart

// import 'package:firebase_core/firebase_core.dart';

// class FirebaseInitializer {
//   static Future<void> initialize() async {
//     await Firebase.initializeApp(
//       options: FirebaseOptions(
//         apiKey: "AIzaSyB8uI6BP5MnuyNV0bbulJvVaZv2fQA3yTc",
//         authDomain: "therapyrobot-a8d2f.firebaseapp.com",
//         projectId: "therapyrobot-a8d2f",
//         storageBucket: "therapyrobot-a8d2f.appspot.com",
//         messagingSenderId: "834280724593",
//         appId: "1:834280724593:web:48ef8df841a28876dc23d0",
//       ),
//     );
//   }
// }
// lib/frontend/firebase_initializer.dart

import 'package:firebase_core/firebase_core.dart';

class FirebaseInitializer {
  static Future<void> initialize() async {
    // אם כבר אתחלנו בעבר (כלומר רשימת האפליקציות אינה ריקה), לא עושים שוב את הקריאה
    if (Firebase.apps.isNotEmpty) return;

    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyB8uI6BP5MnuyNV0bbulJvVaZv2fQA3yTc",
        authDomain: "therapyrobot-a8d2f.firebaseapp.com",
        projectId: "therapyrobot-a8d2f",
        storageBucket: "therapyrobot-a8d2f.appspot.com",
        messagingSenderId: "834280724593",
        appId: "1:834280724593:web:48ef8df841a28876dc23d0",
      ),
    );
  }
}
