// ignore_for_file: unused_field, file_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phychological_counselor/frontend/users_screen.dart';

class HomeScreenDesign extends StatefulWidget {
  const HomeScreenDesign({super.key});

  @override
  State<HomeScreenDesign> createState() => _HomeScreenDesignState();
}

class _HomeScreenDesignState extends State<HomeScreenDesign> {
  bool _menuOpen = false;
  final bool _obscureCurrent = true; 
  final bool _obscureNew = true;
  final bool _obscureConfirm = true;
  bool _isAdmin = false; // <-- שדה חדש
 @override
void initState() {
  super.initState();
  final currentEmail = FirebaseAuth.instance.currentUser?.email;
  if (currentEmail != null) {
    FirebaseFirestore.instance
      .collection('admin')
      .where('email', isEqualTo: currentEmail)
      .limit(1)
      .get()
      .then((snap) {
        if (mounted) {
          setState(() {
            _isAdmin = snap.docs.isNotEmpty;
          });
        }
      });
  }
}

  void _showStatisticsDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("📊Statistics"),
        content: const Text("כאן יופיעו הנתונים הסטטיסטיים בהמשך..."),
        
      ),
    );
  }

  void _showReportsDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("📄Reports"),
        content: const Text("כאן יוצגו דוחות בהמשך..."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("סגור"),
          ),
        ],
      ),
    );
  }


 @override
Widget build(BuildContext context) {
  final user = FirebaseAuth.instance.currentUser;

  return Stack(
    children: [
      Positioned(
        top: 12,
        right: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            
            InkWell(
              onTap: () {
                setState(() {
                  _menuOpen = !_menuOpen;
                });
              },
             child: Icon(
  Icons.person,
  color: Colors.indigo.shade400, // 💜 הצבע הרצוי
  size: 28,
),
            ),
             if (_isAdmin)
        Transform.translate(
          offset: const Offset(-6, -2),
          child: IconButton(
            icon: const Icon(Icons.notifications, size: 28),
            color: Colors.indigo,
         onPressed: () async {
  final notificationsSnap = await FirebaseFirestore.instance
      .collection('notifications')
      .orderBy('timestamp', descending: true)
      .limit(20)
      .get();

  final notifications = notificationsSnap.docs;

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
          backgroundColor: Colors.grey[900], // 🟣 כאן משנים את צבע הרקע של התיבה

title: Text(
  'Latest notifications',
  style: TextStyle(
    color: Colors.indigo.shade400,
    fontWeight: FontWeight.bold,
    fontSize: 20,
  ),
),

      content: notifications.isEmpty
          ? const Text('There are no new notifications')
          : SizedBox(
              width: 300,
              height: 300,
              child: ListView(
                children: notifications.map((doc) {
                  final data = doc.data();
                  return ListTile(
                    leading: const Icon(Icons.person_add, color: Colors.indigo),
title: Text(
  data['message'] ?? 'התראה',
  style: TextStyle(
    color: Colors.indigo.shade400, // הצבע הרצוי
    fontSize: 16,                   // גודל קטן יותר
    overflow: TextOverflow.ellipsis, // אם הטקסט ארוך, יוצג ...
  ),
  maxLines: 1, // הכל בשורה אחת
),
                   subtitle: data['timestamp'] != null
    ? Text(
        (data['timestamp'] as Timestamp).toDate().toString(),
        style: TextStyle(
          color: Colors.indigo.shade400,
          fontSize: 16,
          overflow: TextOverflow.ellipsis,
        ),
        maxLines: 1,
      )
    : null,

                  );
                }).toList(),
              ),
            ),
      actions: [
       TextButton(
  onPressed: () => Navigator.pop(context),
  style: TextButton.styleFrom(
    
    backgroundColor: Colors.indigo.shade400,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
  child: const Text(
    'close',
    style: TextStyle(color: Colors.white, fontSize: 16),
  ),
),

      ],
    ),
  );
}

          ),
        ),
    

            if (_menuOpen)
              Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
                child: Container(
                  width: 180,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.email ?? "לא מחובר",
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (_isAdmin) ...[
          _menuIconItem(
            icon: Icons.supervised_user_circle,
        //    text: '👥 Users',
                        text: ' Users',

            onTap: () {
              setState(() => _menuOpen = false);
               Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const UsersScreen()),
    );
            },
          ),
    //      const Divider(),
        ],

                      _menuItem("⚙️ Settings", () {
                        setState(() => _menuOpen = false);
                        showUserProfileDialog(context);
                      }),
                      _menuItem("📊 Statistics", _showStatisticsDialog),
                      _menuItem("📄 Reports", _showReportsDialog),
                    MouseRegion(
  cursor: SystemMouseCursors.click,
  child: GestureDetector(
    onTap: () {
      FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacementNamed('/');
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text("⎋", style: TextStyle(fontSize: 18, color: Colors.redAccent)),
          SizedBox(width: 8),
          Text("Log Out", style: TextStyle(fontSize: 14, color: Colors.black)),
        ],
      ),
    ),
  ),
),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    ],
  );
}
  Widget _menuIconItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.indigo.shade400),
              const SizedBox(width: 8),
              Text(text, style: const TextStyle(fontSize: 14, color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }

Widget _menuItem(String text, VoidCallback onTap, {TextStyle? style}) {
  return MouseRegion(
    cursor: SystemMouseCursors.click, 
    child: GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          text,
          style: style ?? const TextStyle(fontSize: 14, color: Colors.black),
        ),
      ),
    ),
  );
}
}

class MyProfileOnly extends StatelessWidget {
  const MyProfileOnly({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: Center(
        child: Text(user?.email ?? "לא מחובר", style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
Future<void> showUserProfileDialog(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  final adminSnap = await FirebaseFirestore.instance
      .collection('admin')
      .doc(user.uid)
      .get();
  final isAdmin = adminSnap.exists;

  final docRef = FirebaseFirestore.instance
  .collection(isAdmin ? 'admin' : 'users')
      .doc(user.uid);
  final docSnap = await docRef.get();
  final userData = docSnap.data();

  final nameController = TextEditingController(text: userData?['firstName'] ?? '');
  //final _emailController = TextEditingController(text: userData?['email'] ?? '');
  final currentPassController = TextEditingController();
  final newPassController = TextEditingController();
  final confirmPassController = TextEditingController();

  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.grey[300],
          title: const Text('My Profile',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTextField(nameController, 'Name'),
                //  _buildTextField(_emailController, 'Email'),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Change Password",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  _buildPasswordField(
                    controller: currentPassController,
                    label: 'Current Password',
                    obscure: obscureCurrent,
                    toggle: () => setState(() => obscureCurrent = !obscureCurrent),
                  ),
                  _buildPasswordField(
                    controller: newPassController,
                    label: 'New Password',
                    obscure: obscureNew,
                    toggle: () => setState(() => obscureNew = !obscureNew),
                  ),
                  _buildPasswordField(
                    controller: confirmPassController,
                    label: 'Confirm Password',
                    obscure: obscureConfirm,
                    toggle: () => setState(() => obscureConfirm = !obscureConfirm),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
             onPressed: () async {
  final name = nameController.text.trim();
  //final email = _emailController.text.trim();
  final currentPassword = currentPassController.text.trim();
  final newPassword = newPassController.text.trim();
  final confirmPassword = confirmPassController.text.trim();

  if (name.isEmpty) {
    showError(context, ' The name field cannot be empty.');
    return;
  }
//   if (!isEmailValid(email)) {
//   showError(context, 'The email address is invalid. Please try again.');
//   return;
// }


  try {
if (newPassword.isNotEmpty || confirmPassword.isNotEmpty) {
  if (newPassword.isEmpty) {
    showError(context, 'A new password must be entered before entering password verification.');
    return;
  }
       if (currentPassword.isEmpty) {
    showError(context, 'יש להזין את הסיסמה הנוכחית.');
    return;
  }
      if (currentPassword.isEmpty) {
        showError(context, 'Please enter the current password.');
        return;
      }

      // 🔴 בדיקה: אימות מול Firebase
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);

      // 🔴 בדיקה: התאמה בין הסיסמה החדשה לאימות שלה
      if (newPassword != confirmPassword) {
        showError(context, 'The new password and confirm password do not match.');
        return;
      }

      // 🔴 בדיקה: האם הסיסמה חזקה
      if (!isPasswordStrong(newPassword)) {
        showError(context, 'The password must contain at least 8 characters, letters, numbers & symbols.');
        return;
      }
      

      // ✅ עדכון סיסמה בפועל
      await user.updatePassword(newPassword);
    }
 


//     // ✅ עדכון פרטים אחרים (שם, אימייל)
//     await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
//       'firstName': name,
//     //  'email': email,
//       if (newPassword.isNotEmpty) 'password': newPassword, // זמני
//     });
// await FirebaseFirestore.instance
//                   .collection('users')
//                   .doc(user.uid)
//                   .update({'firstName': name});
                
//                 if (isAdmin) {
//                   // ADD: ועדכון גם ב־admin collection
//                   await FirebaseFirestore.instance
//                     .collection('admin')
//                     .doc(user.uid)
//                     .update({'firstName': name});
//                 }
await FirebaseFirestore.instance
    .collection(isAdmin ? 'admin' : 'users')
    .doc(user.uid)
    .update({
      'firstName': name,
      if (newPassword.isNotEmpty) 'password': newPassword,
    });

    Navigator.pop(context);
  } catch (e) {
    showError(context, 'Authentication error: The current password is incorrect.');
  }
},

              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade400,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
              child: const Text('Save', style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.indigo.shade400, fontSize: 18)),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildTextField(TextEditingController controller, String label) {
  return TextField(
    controller: controller,
    style: const TextStyle(fontSize: 16),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black, fontSize: 14),
      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.indigo)),
      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
    ),
  );
}

Widget _buildPasswordField({
  required TextEditingController controller,
  required String label,
  required bool obscure,
  required VoidCallback toggle,
}) {
  return TextField(
    controller: controller,
    obscureText: obscure,
    style: const TextStyle(fontSize: 16),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black, fontSize: 14),
      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.indigo)),
      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
      suffixIcon: IconButton(
        icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
        onPressed: toggle,
      ),
    ),
  );
}

bool isPasswordStrong(String password) {
  final regex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[^A-Za-z\d]).{8,}$');
  return regex.hasMatch(password);
}
 bool isEmailValid(String email) {
  final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return regex.hasMatch(email);
}
void showError(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: const [
          Icon(Icons.error_outline, color: Colors.redAccent),
          SizedBox(width: 10),
          Text(
            "Error Updating",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("close", style: TextStyle(color: Colors.indigo,fontSize:16)),
        ),
      ],
    ),
  );
}