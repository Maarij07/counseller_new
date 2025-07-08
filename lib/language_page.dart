import 'package:flutter/material.dart';

class LanguagePage extends StatelessWidget {
  final List<String> languages = [
    'Arabic',
    'Hebrew',
    'English',
    'Chinese',
    'Spanish'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Language'),
      ),
      body: ListView.builder(
        itemCount: languages.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(languages[index]),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Language changed to ${languages[index]}')),
              );
              Navigator.pop(context); // חזרה לעמוד התפריט
            },
          );
        },
      ),
    );
  }
}
