// 📄 קובץ: validation.dart

import 'package:flutter/material.dart';

bool validateStep({
  required int step,
  required BuildContext context,
  required TextEditingController firstNameController,
  required TextEditingController lastNameController,
  required TextEditingController emailController,
  required TextEditingController confirmEmailController,
  required TextEditingController ageController,
  required TextEditingController genderController,
  required TextEditingController passwordController,
  required TextEditingController confirmPasswordController,
}) {
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  switch (step) {
    case 0:
      if (firstNameController.text.isEmpty || !_isAlphabetic(firstNameController.text)) {
        showError('First name must contain only letters');
        return false;
      }
      break;
    case 1:
      if (lastNameController.text.isEmpty || !_isAlphabetic(lastNameController.text)) {
        showError('Last name must contain only letters');
        return false;
      }
      break;
    case 2:
if (!isValidEmail(emailController.text) || emailController.text != confirmEmailController.text){   
        showError('Emails do not match or invalid');
        return false;
      }
      break;
    case 3:
      final age = int.tryParse(ageController.text);
      if (age == null || age <= 16) {
        showError('Age must be greater than 16');
        return false;
      }
      break;
    case 4:
      if (genderController.text.isEmpty) {
        showError('Gender is required');
        return false;
      }
      break;
    case 5:
      if (!_isValidPassword(passwordController.text) || passwordController.text != confirmPasswordController.text) {
        showError('Passwords do not match or invalid');
        return false;
      }
      break;
  }
  return true;
}

bool _isAlphabetic(String input) => RegExp(r'^[a-zA-Z]+$').hasMatch(input);

bool isValidEmail(String email) {
  final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
  return emailRegex.hasMatch(email);
}

bool _isValidPassword(String password) {
  final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
  final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
  final hasDigit = RegExp(r'\d').hasMatch(password);
  final hasSpecialChar = RegExp(r'[!@#\$&*~]').hasMatch(password);
  final hasMinLength = password.length >= 8;

  return hasUppercase && hasLowercase && hasDigit && hasSpecialChar && hasMinLength;
}
