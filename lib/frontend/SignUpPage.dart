
import 'package:flutter/material.dart';
import 'package:phychological_counselor/frontend/validation.dart';
import 'package:phychological_counselor/frontend/firestore_helper.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmEmailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _signUp() async {
    final valid = validateStep(
      step: 0,
      context: context,
      firstNameController: _firstNameController,
      lastNameController: _lastNameController,
      emailController: _emailController,
      confirmEmailController: _confirmEmailController,
      ageController: _ageController,
      genderController: _genderController,
      passwordController: _passwordController,
      confirmPasswordController: _confirmPasswordController,
    );

    if (!valid) return;

    if (_emailController.text.trim() != _confirmEmailController.text.trim()) {
_showStyledError('Signup Error', 'Emails do not match.');
      return;
    }

    if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
      _showStyledError('Signup Error', 'Passwords do not match.');
      return;
    }

    await signUpAndSaveUser(
      context: context,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      age: _ageController.text.trim(),
      gender: _genderController.text.trim(),
    );
  }

  void _showStyledError(String title, String message) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          color: Colors.indigo.shade400,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        message,
        style: TextStyle(fontSize: 16, color: Colors.black87),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK', style: TextStyle(color: Colors.indigo.shade400)),
        ),
      ],
    ),
  );
}

  void _showInlineError(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 3),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        toolbarHeight: 160,
        title: Text(
          'Sign Up',
          style: TextStyle(
            color: Colors.indigo.shade400,
            fontSize: 50,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_firstNameController, 'First Name')),
                      const SizedBox(width: 10),
                      Expanded(child: _buildTextField(_lastNameController, 'Last Name')),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_emailController, 'Email')),
                      const SizedBox(width: 10),
                      Expanded(child: _buildTextField(_confirmEmailController, 'Confirm Email')),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_ageController, 'Age', keyboardType: TextInputType.number)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            canvasColor: Colors.grey[200],
                            highlightColor: Colors.indigo.shade100,
                            splashColor: Colors.indigo.shade100,
                            hoverColor: Colors.indigo.shade100,
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _genderController.text.isNotEmpty ? _genderController.text : null,
                            items: ['Male', 'Female', 'Other']
                                .map((value) => DropdownMenuItem(
                                      value: value,
                                      child: Text(value, style: TextStyle(fontSize: 16, color: Colors.black)),
                                    ))
                                .toList(),
                            onChanged: (value) => _genderController.text = value ?? '',
                            style: const TextStyle(fontSize: 16, color: Colors.black),
                            dropdownColor: Colors.grey[200],
                            iconEnabledColor: Colors.indigo.shade400,
                            decoration: InputDecoration(
                              labelText: 'Gender',
                              labelStyle: const TextStyle(fontSize: 14, color: Colors.black),
                              floatingLabelStyle: TextStyle(fontSize: 14, color: Colors.indigo.shade400),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.indigo.shade400, width: 2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          _passwordController,
                          'Password',
                          obscure: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(
                          _confirmPasswordController,
                          'Confirm Password',
                          obscure: _obscureConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    ),
                    child: const Text('Sign Up', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 10),
ElevatedButton(
  onPressed: _signUpAdmin,
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.red.shade400,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
  ),
  child: const Text('Sign Up Admin', style: TextStyle(fontSize: 18)),
),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
void _signUpAdmin() async {
  final valid = validateStep(
    step: 0,
    context: context,
    firstNameController: _firstNameController,
    lastNameController: _lastNameController,
    emailController: _emailController,
    confirmEmailController: _confirmEmailController,
    ageController: _ageController,
    genderController: _genderController,
    passwordController: _passwordController,
    confirmPasswordController: _confirmPasswordController,
  );

  if (!valid) return;

  if (_emailController.text.trim() != _confirmEmailController.text.trim()) {
    _showStyledError('Signup Error', 'Emails do not match.');
    return;
  }

  if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
    _showStyledError('Signup Error', 'Passwords do not match.');
    return;
  }

  await signUpAndSaveUser(
    context: context,
    firstName: _firstNameController.text.trim(),
    lastName: _lastNameController.text.trim(),
    email: _emailController.text.trim(),
    password: _passwordController.text.trim(),
    age: _ageController.text.trim(),
    gender: _genderController.text.trim(),
    isAdmin: true, // <- שימי לב לפרמטר הזה
  );
}

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        cursorColor: Colors.indigo.shade400,
        style: const TextStyle(fontSize: 16, color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 14, color: Colors.black),
          floatingLabelStyle: TextStyle(color: Colors.indigo.shade400, fontSize: 14),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: suffixIcon,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.indigo.shade400, width: 2),
          ),
        ),
      ),
    );
  }
}