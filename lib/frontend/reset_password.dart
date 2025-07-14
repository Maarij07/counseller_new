// // File: lib/widgets/reset_password_dialog.dart

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// Future<void> showResetPasswordDialog(BuildContext context) async {
//   final emailController = TextEditingController();
//   final newPasswordController = TextEditingController();
//   final confirmPasswordController = TextEditingController();

//   int step = 1;

//   void showStep() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => StatefulBuilder(
//         builder: (context, setState) {
//           Widget content;

//           if (step == 1) {
//             content = Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text('Enter your email to reset password'),
//                 const SizedBox(height: 10),
//                 TextField(
//                   controller: emailController,
//                   decoration: const InputDecoration(
//                     hintText: 'Email',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//               ],
//             );
//           } else {
//             content = Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text('Enter new password'),
//                 const SizedBox(height: 10),
//                 TextField(
//                   controller: newPasswordController,
//                   obscureText: true,
//                   decoration: const InputDecoration(
//                     hintText: 'New Password',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 const Text('Confirm password'),
//                 const SizedBox(height: 5),
//                 TextField(
//                   controller: confirmPasswordController,
//                   obscureText: true,
//                   decoration: const InputDecoration(
//                     hintText: 'Confirm Password',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//               ],
//             );
//           }

//           return AlertDialog(
//             backgroundColor: Colors.grey[200],
//             title: const Text('Reset Password'),
//             content: SingleChildScrollView(child: content),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text("Cancel"),
//               ),
//               ElevatedButton(
//                 onPressed: () async {
//                   final email = emailController.text.trim();

//                   if (step == 1) {
//                     if (email.isEmpty) {
//                       showError(context, 'Please enter your email');
//                       return;
//                     }

//                     try {
//                       await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
//                       showSuccess(context, 'Password reset link sent to your email.');
//                       Navigator.pop(context);
//                     } catch (e) {
//                       showError(context, 'Error sending email: $e');
//                     }
//                   } else {
//                     final newPassword = newPasswordController.text.trim();
//                     final confirm = confirmPasswordController.text.trim();

//                     if (newPassword.length < 8) {
//                       showError(context, 'Password must be at least 8 characters');
//                       return;
//                     }
//                     if (newPassword != confirm) {
//                       showError(context, 'Passwords do not match');
//                       return;
//                     }

//                     try {
//                       final userDoc = await FirebaseFirestore.instance
//                           .collection('users')
//                           .where('email', isEqualTo: email)
//                           .limit(1)
//                           .get();

//                       if (userDoc.docs.isNotEmpty) {
//                         final userRef = userDoc.docs.first.reference;

//                         await userRef.update({
//                           'password': newPassword,
//                         });

//                         print('✅ Password updated for user: ${userRef.id}');

//                         showSuccess(context, 'Password saved in Firestore');
//                         Navigator.pop(context);
//                       } else {
//                         print('❌ User not found for email: $email');
//                         showError(context, 'User not found in Firestore');
//                       }
//                     } catch (e) {
//                       print('❌ Error updating password in Firestore: $e');
//                       showError(context, 'Error saving password: $e');
//                     }
//                   }
//                 },
//                 child: const Text("Continue"),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   showStep();
// }

// void showError(BuildContext context, String message) {
//   showDialog(
//     context: context,
//     builder: (_) => AlertDialog(
//       title: const Text('Error'),
//       content: Text(message),
//       actions: [
//         TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
//       ],
//     ),
//   );
// }

// void showSuccess(BuildContext context, String message) {
//   showDialog(
//     context: context,
//     builder: (_) => AlertDialog(
//       title: const Text('Success'),
//       content: Text(message),
//       actions: [
//         TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
//       ],
//     ),
//   );
// }
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
Future<void> sendPasswordResetEmail({
  required String userEmail,
  required String resetLink,
}) async {
  const serviceId = 'service_j0cu26o';
  const templateId = 'template_ud0zjcp';
  const publicKey = 'VBWBT...'; // המפתח הפומבי שלך מ־EmailJS
  const userId = 'C6-8XJwSYTqFhyQUb';
  //  updating it adding email variable
  const email = "";

  final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

  final response = await http.post(
  url,
  headers: {
    'origin': 'http://localhost', // לא לקצר ל־loca
    'Content-Type': 'application/json',
  },
  body: json.encode({
    'service_id': serviceId,
    'template_id': templateId,
    'user_id': userId, // זה המפתח הציבורי שלך (Public Key)
    'template_params': {
      'email': email,         // לוודא שקיים בשבלונה שלך
      'message': resetLink,   // או כל פרמטר אחר שמוגדר בתבנית
    },
  }),
);


  if (response.statusCode == 200) {
    print('✅ Email sent!');
    print(publicKey);

  } else {
    print('❌ Failed to send email: ${response.body}');
    print('🔴 Error response: ${response.statusCode} - ${response.body}');

  }
}

// 🔵 2. ואז בתוך ה־Widget שלך (כפתור לדוגמה)
class ForgotPasswordPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reset Password")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            ElevatedButton(
              onPressed: () async {
                String email = emailController.text.trim();
                String code = 'ABC123'; // כאן תייצרי קוד משלך
                String link = 'https://yourapp.com/reset?code=$code';

await sendPasswordResetEmail(userEmail: email, resetLink: link);
              },
              child: Text("Send Reset Link"),
            ),
          ],
        ),
      ),
    );
  }
}
