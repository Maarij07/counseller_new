// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:phychological_counselor/home/screens/home_screen.dart'; // היבוא של home_screen.dart
// import 'package:phychological_counselor/frontend/SignUpPage.dart';  // היבוא של SignUpPage
// import 'package:phychological_counselor/main/navigation/routes/name.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:phychological_counselor/frontend/reset_password_dialog.dart';

// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _obscurePassword = true;

//   Future<void> _login() async {
//   FocusScope.of(context).unfocus(); // סגור מקלדת
//   // 1. קלט מהמסך
//   final emailInput = _emailController.text.trim();
//   final password   = _passwordController.text.trim();
//   // print("📧 Email: '$email'");
//   print("🔑 Password: '$password'");

//   print("📧 Email: '$emailInput'");
// if (emailInput.isEmpty || password.isEmpty) {
//       showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text('Missing Info'),
//         content: Text('Please fill in both fields'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: Text('OK')),
//         ],
//       ),
//     );
//     return;
//   }
// print("Trying login with email: $emailInput");
//    try {
//     // 1. התחברות
//     final cred = await FirebaseAuth.instance
//       .signInWithEmailAndPassword(email: emailInput, password: password);
//     final uid = cred.user!.uid;

//     final firestore = FirebaseFirestore.instance;

//     // 2. בדיקה ישירה לפי doc.id ב־admin
//     // final adminDoc = await firestore.collection('admin').doc(uid).get();
//     // if (adminDoc.exists) {
//     //   // → אדמין
//     //   Navigator.pushReplacement(
//     //     context,
//     //     MaterialPageRoute(builder: (_) => const HomeScreen()),
//     //   );
//     //   return;
//     // }
// final adminQuery = await firestore
//     .collection('admin')
//     .where('userId', isEqualTo: uid)
//     .get();

// if (adminQuery.docs.isNotEmpty) {
//   Navigator.pushReplacement(
//     context,
//     MaterialPageRoute(builder: (_) => const HomeScreen()),
//   );
//   return;
// }

//     // 3. אחרת בודקים ב־users
//     final userDoc = await firestore.collection('users').doc(uid).get();
//     if (userDoc.exists) {
//       // → משתמש רגיל
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const HomeScreen()),
//       );
//       return;
//     }
//         await _showError("Login Failed", "Your account is not registered.");

// } on FirebaseAuthException catch (e) {
//     print("❌ FirebaseAuth Login Error: $e");

//     showDialog(
//   context: context,
//     barrierColor: Colors.black.withOpacity(0.2), // ← רקע שקוף בהיר

//   builder: (_) => Center(
//     child: SizedBox(
//       width: 300, // ← גודל הקופסה
//       child: AlertDialog(
//         backgroundColor: Colors.grey[200], // ✅ צבע הרקע של הקופסה עצמה
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16), // ← פינות מעוגלות
//         ),
//         title: Text(
//           'Login Failed',
//           style: TextStyle(color: Colors.black87, fontSize: 18),
//         ),
//         content: Text(
//           'Error: ${e.message}',
//           style: TextStyle(color: Colors.black, fontSize: 14),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'OK',
// style: TextStyle(
//       color: Colors.indigo, // ✅ צבע טקסט סגול
//       fontWeight: FontWeight.bold,
//       fontSize: 16,
//     ),            ),
//           ),
//         ],
//       ),
//     ),
//   ),
// );

//   }catch (e) {
//       showDialog(
//         context: context,
//         builder: (_) => AlertDialog(
//           title: Text('Login Failed'),
//           content: Text('Error: $e'),
//           actions: [
//             TextButton(onPressed: () => Navigator.pop(context), child: Text('OK')),
//           ],
//         ),
//       );
//   }
// }
// // עזר להצגה אחידה של דיאלוג
// Future<void> _showError(String title, String body) {
//   return showDialog(
//     context: context,
//     builder: (_) => AlertDialog(
//       title: Text(title),
//       content: Text(body),
//       actions: [
//         TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
//       ],
//     ),
//   );
// }
// Future<void> manualLoginTest() async {
//   final email = _emailController.text.trim();
//   final password = _passwordController.text.trim();

//   try {
//     final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
//       email: email,
//       password: password,
//     );

//     print("✅ התחברות הצליחה! UID: ${credential.user?.uid}");
//     Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
//   } on FirebaseAuthException catch (e) {
//     print("❌ שגיאה: ${e.message}");
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text("Login Failed"),
//         content: Text("שגיאה: ${e.message}"),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: Text("סגור")),
//         ],
//       ),
//     );
//   }
// }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
        
//   backgroundColor: Colors.white, // ← הוסיפי שורה זו

//       appBar: AppBar(
//   backgroundColor: Colors.white,     // צבע רקע לבן
//   elevation: 0,                      // אין צל בכלל
//   centerTitle: true,                // אם את רוצה ליישר את הכותרת למרכז
//   iconTheme: IconThemeData(color: Colors.black), // ← צבע חץ אחורה (אם יש)
//   title: Text(
//     '', // השאירי ריק או כתבי 'Welcome' אם צריך
//     style: TextStyle(
//       color: Colors.indigo.shade400,
//       fontWeight: FontWeight.bold,
//       fontSize: 24,
//     ),
//   ),
// ),

//       body: Center(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Text(
//                   'Welcome',
//                   style: TextStyle(
//                     color: Colors.indigo.shade400,
//                     fontSize: 32,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 SizedBox(height: 40),
//                 MouseRegion(
//                   onEnter: (event) => {},
//                   onExit: (event) => {},
//                   child: Container(
//                     width: 250,
//                       height: 45, // ✅ חדש: גובה קטן יותר
//                     child: TextField(
//                       style: TextStyle(color: Colors.black,  fontSize: 13),
//                       controller: _emailController,
//                       decoration: InputDecoration(
//                         labelText: 'Email',
//                         labelStyle: TextStyle(color: Colors.indigo.shade400,  fontSize: 14),// או אפילו 12 אם את רוצה קטן יו),
//                         enabledBorder: OutlineInputBorder(
//                           borderSide: BorderSide(color: Colors.indigo.shade400),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderSide: BorderSide(color: Colors.indigo.shade400),
//                         ),
//                       ),
//                         cursorColor: Colors.indigo.shade400, // ✅ הוסיפי שורה זו

//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 20),
//               MouseRegion(
//   onEnter: (event) => {},
//   onExit: (event) => {},
//   child: Container(
//     width: 250,
//     height: 45,
//     child: TextField(
//       controller: _passwordController,
//       obscureText: _obscurePassword,
//       style: TextStyle(color: Colors.black, fontSize: 13),
//       cursorColor: Colors.indigo.shade400,
//         onSubmitted: (_) => _login(), // ✅ הוסיפי את זה כאן

//       decoration: InputDecoration(
//         labelText: 'Password',
//         labelStyle: TextStyle(color: Colors.indigo.shade400, fontSize: 14),
//         enabledBorder: OutlineInputBorder(
//           borderSide: BorderSide(color: Colors.indigo.shade400),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderSide: BorderSide(color: Colors.indigo.shade400),
//         ),
//         suffixIcon: IconButton(
//           icon: Icon(
//             _obscurePassword ? Icons.visibility_off : Icons.visibility,
//             color: Colors.grey,
//           ),
//           onPressed: () {
//             setState(() {
//               _obscurePassword = !_obscurePassword;
//             });
//           },
//         ),
//       ),
//     ),
//   ),
// ),

                
//  Container(
//   width: 300,
//   alignment: Alignment.centerRight,
//   child: TextButton(
//     onPressed: () {
//       showResetPasswordDialog(context); // ✅ תיבת דיאלוג במקום מעבר לעמוד חדש
//     },
//     child: Text(
//   'Forgot Password?',
//   style: TextStyle(
//     color: Colors.indigo,
//     fontSize: 12, // כאן קובעים את הגודל הקטן יותר
//   ),
// ),

//   ),
// ),

// SizedBox(
//   width: 70,
//   height: 30,
//   child: ElevatedButton(
//     style: ElevatedButton.styleFrom(
//       backgroundColor: Colors.indigo.shade400,
//       foregroundColor: Colors.white,
//       shape: StadiumBorder(),
//             padding: EdgeInsets.zero, // ✅ מבטל מרווחים פנימיים נוספים

//     ),
//     onPressed: _login,
//     child: Text('Login', style: TextStyle(fontSize: 18)),
//   ),
// ),
// SizedBox(height: 10), // ← מוסיף רווח אנכי של 10 פיקסלים
// SizedBox(
//   width: 70,
//   height: 30,
//   child: ElevatedButton(
//     style: ElevatedButton.styleFrom(
//       backgroundColor: Colors.indigo.shade400,
//       foregroundColor: Colors.white,
//       shape: StadiumBorder(),
//             padding: EdgeInsets.zero, // ✅ מבטל מרווחים פנימיים נוספים

//     ),
//     onPressed: () {
//       FocusScope.of(context).unfocus();
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => SignUpPage()),
//       );
//     },
//     child: Text('Sign Up', style: TextStyle(fontSize: 18)),
//   ),
// ),

//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

// ignore_for_file: use_build_context_synchronously

// }
 import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phychological_counselor/home/screens/home_screen.dart'; // היבוא של home_screen.dart
import 'package:phychological_counselor/frontend/SignUpPage.dart';  // היבוא של SignUpPage
import 'package:phychological_counselor/main/navigation/routes/name.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:phychological_counselor/frontend/reset_password_dialog.dart';
import 'package:phychological_counselor/frontend/reset_password_flow.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  Future<void> _login() async {
  FocusScope.of(context).unfocus(); // סגור מקלדת

   final email = _emailController.text.trim();
  final password = _passwordController.text.trim();
  print("📧 Email: '$email'");
  print("🔑 Password: '$password'");

  if (email.isEmpty || password.isEmpty) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Missing Info'),
        content: Text('Please fill in both fields'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('OK')),
        ],
      ),
    );
    return;
  }
    print("Trying login with email: $email");
}
Future<bool> tryLoginFromFirestoreIfNotInAuth(String email, String password) async {
  final firestore = FirebaseFirestore.instance;

  // 🔍 בדיקה בקולקשן admin
  final adminQuery = await firestore
      .collection('admin')
      .where('email', isEqualTo: email)
      .get();

  if (adminQuery.docs.isNotEmpty) {
    final userData = adminQuery.docs.first.data();
    if (userData['password'] == password) {
      print("✅ התחברות מוצלחת דרך admin");
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
      return true;
    } else {
      print("❌ סיסמה שגויה עבור admin");
    }
  }

  return false;
}

Future<bool> tryFirestoreLogin(String email, String password) async {
  final firestore = FirebaseFirestore.instance;

  // בדוק בקולקשן admin
  final adminQuery = await firestore
      .collection('admin')
      .where('email', isEqualTo: email)
      .get();

  if (adminQuery.docs.isNotEmpty) {
    final userData = adminQuery.docs.first.data();
if (userData['password'].toString() == password) {
      print("✅ התחברות מוצלחת דרך admin");
      // נווט לדף הבית
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.home, (route) => false);
      return true;
    }
  }

  // בדוק בקולקשן users
  final userQuery = await firestore
      .collection('users')
      .where('email', isEqualTo: email)
      .get();

  if (userQuery.docs.isNotEmpty) {
    final userData = userQuery.docs.first.data();
    if (userData['password'] == password) {
      print("✅ התחברות מוצלחת דרך users");
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.home, (route) => false);
      return true;
    }
  }

  return false;
}

Future<void> manualLoginTest() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();

  try {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    print("✅ התחברות הצליחה! UID: ${credential.user?.uid}");
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
  } on FirebaseAuthException catch (e) {
    print("❌ שגיאה: ${e.message}");
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Login Failed"),
        content: Text("שגיאה: ${e.message}"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("סגור")),
        ],
      ),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        
  backgroundColor: Colors.white, // ← הוסיפי שורה זו

      appBar: AppBar(
  backgroundColor: Colors.white,     // צבע רקע לבן
  elevation: 0,                      // אין צל בכלל
  centerTitle: true,                // אם את רוצה ליישר את הכותרת למרכז
  iconTheme: IconThemeData(color: Colors.black), // ← צבע חץ אחורה (אם יש)
  title: Text(
    '', // השאירי ריק או כתבי 'Welcome' אם צריך
    style: TextStyle(
      color: Colors.indigo.shade400,
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
  ),
),

      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Welcome',
                  style: TextStyle(
                    color: Colors.indigo.shade400,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                MouseRegion(
                  onEnter: (event) => {},
                  onExit: (event) => {},
                  child: SizedBox(
                    width: 250,
                      height: 45, // ✅ חדש: גובה קטן יותר
                    child: TextField(
                      style: TextStyle(color: Colors.black,  fontSize: 13),
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.indigo.shade400,  fontSize: 14),// או אפילו 12 אם את רוצה קטן יו),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.indigo.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.indigo.shade400),
                        ),
                      ),
                        cursorColor: Colors.indigo.shade400, // ✅ הוסיפי שורה זו

                    ),
                  ),
                ),
                SizedBox(height: 20),
              MouseRegion(
  onEnter: (event) => {},
  onExit: (event) => {},
  child: SizedBox(
    width: 250,
    height: 45,
    child: TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: TextStyle(color: Colors.black, fontSize: 13),
      cursorColor: Colors.indigo.shade400,
        onSubmitted: (_) => _login(), // ✅ הוסיפי את זה כאן

      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: TextStyle(color: Colors.indigo.shade400, fontSize: 14),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.indigo.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.indigo.shade400),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
    ),
  ),
),

                
//  Container(
//   width: 300,
//   alignment: Alignment.centerRight,
//   child: TextButton(
//     onPressed: () {
// showResetPasswordFlow(context);
//     },
//     child: Text(
//   'Forgot Password?',
//   style: TextStyle(
//     color: Colors.indigo,
//     fontSize: 12, // כאן קובעים את הגודל הקטן יותר
//   ),
// ),

//   ),
// ),
TextButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResetPasswordFlow()),
    );
  },
  child: Text(
    'Forgot Password?',
    style: TextStyle(
      color: Colors.indigo,
      fontSize: 12,
    ),
  ),
),

SizedBox(
  width: 70,
  height: 30,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.indigo.shade400,
      foregroundColor: Colors.white,
      shape: StadiumBorder(),
            padding: EdgeInsets.zero, // ✅ מבטל מרווחים פנימיים נוספים

    ),
    onPressed: _login,
    child: Text('Login', style: TextStyle(fontSize: 18)),
  ),
),
SizedBox(height: 10), // ← מוסיף רווח אנכי של 10 פיקסלים
SizedBox(
  width: 70,
  height: 30,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.indigo.shade400,
      foregroundColor: Colors.white,
      shape: StadiumBorder(),
            padding: EdgeInsets.zero, // ✅ מבטל מרווחים פנימיים נוספים

    ),
    onPressed: () {
      FocusScope.of(context).unfocus();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SignUpPage()),
      );
    },
    child: Text('Sign Up', style: TextStyle(fontSize: 18)),
  ),
),

              ],
            ),
          ),
        ),
      ),
    );
  }

}
 