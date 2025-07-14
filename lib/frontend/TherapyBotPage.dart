// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:phychological_counselor/frontend/SignUpPage.dart'; // היבוא של SignUpPage
import 'package:phychological_counselor/frontend/home_page.dart';
import 'package:phychological_counselor/main/navigation/routes/name.dart';


class TherapyBotPage extends StatelessWidget {
  const TherapyBotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // אוף-וייט רך מאוד

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
                  SizedBox(height: 100), // ← זה מה שידחוף את הטקסטים למטה 👇

            // Image.asset(
            //   'assets/images/favicon.png',
            //   width: 100,
            //   height: 100,
            //   fit: BoxFit.cover,
            //   errorBuilder: (context, error, stackTrace) {
            //     return Text(
            //       "Error loading image",
            //       style: TextStyle(color: Colors.red),
            //     );
            //   },
            // ),
            SizedBox(height: 20),
            Text(
              "Hey! I'm Hewar",
              style: TextStyle(
                color: Colors.indigo.shade400,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Counseling Chatbot",
              style: TextStyle(
                color: Colors.indigo.shade400,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            MouseRegion(
              onEnter: (event) => {},
              onExit: (event) => {},
              child: IconButton(
                icon: Icon(
                  Icons.arrow_downward,
                  color: Colors.indigo.shade400,
                  size: 30,
                ),
                onPressed: () {
                  // ניווט לעמוד SignUpPage
                  
                  Navigator.pushNamed(
                    context,AppRoutes.login
                
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 