// ✅ קובץ: frontend/signup_steps.dart

import 'package:flutter/material.dart';

Widget buildTextField({
  required TextEditingController controller,
  required String label,
  bool obscureText = false,
  TextInputType keyboardType = TextInputType.text,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(), // טופס עם מסגרת
        filled: true,
        fillColor: Colors.white,
      ),
    ),
  );
}
 
//   return TextField(
//     controller: controller,
//     decoration: InputDecoration(labelText: label),
//     obscureText: obscureText,
//     keyboardType: keyboardType,
//   );
// }

class SignUpSteps extends StatelessWidget {
  final int step;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController confirmEmailController;
  final TextEditingController ageController;
  final TextEditingController genderController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  const SignUpSteps({
    required this.step,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.confirmEmailController,
    required this.ageController,
    required this.genderController,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  @override
Widget build(BuildContext context) {
  Widget content;

  switch (step) {
    case 0:
      content = buildTextField(controller: firstNameController, label: 'First Name');
      break;
    case 1:
      content = buildTextField(controller: lastNameController, label: 'Last Name');
      break;
    case 2:
      content = Column(
        children: [
          buildTextField(controller: emailController, label: 'Email'),
          buildTextField(controller: confirmEmailController, label: 'Confirm Email'),
        ],
      );
      break;
    case 3:
      content = buildTextField(
        controller: ageController,
        label: 'Age',
        keyboardType: TextInputType.number,
      );
      break;
    case 4:
      content = DropdownButtonFormField<String>(
        value: genderController.text.isNotEmpty ? genderController.text : null,
        items: ['Male', 'Female', 'Other']
            .map((value) => DropdownMenuItem(value: value, child: Text(value)))
            .toList(),
        onChanged: (value) => genderController.text = value!,
        decoration: InputDecoration(
          labelText: 'Gender',
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      );
      break;
    case 5:
      content = Column(
        children: [
          buildTextField(controller: passwordController, label: 'Password', obscureText: true),
          buildTextField(controller: confirmPasswordController, label: 'Confirm Password', obscureText: true),
        ],
      );
      break;
    default:
      content = SizedBox();
  }

  return Center(
    child: Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: 400,
          child: content,
        ),
      ),
    ),
  );
}

}