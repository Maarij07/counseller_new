// lib/home/screens/mobile_avatar_demo.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mobile_avatar_service.dart';
import 'mobile_avatar_widget.dart';

class MobileAvatarDemo extends StatefulWidget {
  const MobileAvatarDemo({super.key});

  @override
  State<MobileAvatarDemo> createState() => _MobileAvatarDemoState();
}

class _MobileAvatarDemoState extends State<MobileAvatarDemo> {
  late MobileAvatarService _avatarService;

  @override
  void initState() {
    super.initState();
    _avatarService = MobileAvatarService();
    _initializeAvatar();
  }

  Future<void> _initializeAvatar() async {
    await _avatarService.initialize();
    await _avatarService.loadAvatar('assets/avatars/avatar.glb');
  }

  @override
  void dispose() {
    _avatarService.dispose();
    super.dispose();
  }

  void _testSpeech(String text) {
    _avatarService.speakText(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobile Avatar Demo'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ChangeNotifierProvider.value(
        value: _avatarService,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Avatar Display
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: const MobileAvatarWidget(
                  width: 300,
                  height: 400,
                ),
              ),

              // Test Controls
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Avatar Controls',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Speech Tests
                      const Text('Test Speech & Lip Sync:'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ElevatedButton(
                            onPressed: () => _testSpeech('Hello! How are you today?'),
                            child: const Text('Greeting'),
                          ),
                          ElevatedButton(
                            onPressed: () => _testSpeech('Welcome to our psychological counseling session!'),
                            child: const Text('Welcome'),
                          ),
                          ElevatedButton(
                            onPressed: () => _testSpeech('Let me explain this important concept to you.'),
                            child: const Text('Explain'),
                          ),
                          ElevatedButton(
                            onPressed: () => _testSpeech('This is a very important point to remember!'),
                            child: const Text('Emphasize'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Manual Expression Tests
                      const Text('Test Manual Expressions:'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ElevatedButton(
                            onPressed: () => _avatarService.setMouthExpression(smile: 0.8),
                            child: const Text('Smile'),
                          ),
                          ElevatedButton(
                            onPressed: () => _avatarService.setMouthExpression(open: 0.6),
                            child: const Text('Open Mouth'),
                          ),
                          ElevatedButton(
                            onPressed: () => _avatarService.setMouthExpression(pucker: 0.8),
                            child: const Text('Pucker'),
                          ),
                          ElevatedButton(
                            onPressed: () => _avatarService.resetMouth(),
                            child: const Text('Reset'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Status Information
                      Consumer<MobileAvatarService>(
                        builder: (context, service, child) {
                          return Card(
                            color: Colors.grey.shade100,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Avatar Status:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Initialized: ${service.isInitialized}'),
                                  Text('Avatar Loaded: ${service.isAvatarLoaded}'),
                                  Text('Speaking: ${service.isSpeaking}'),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Animation Values:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text('Jaw Open: ${service.jawOpen.toStringAsFixed(2)}'),
                                  Text('Mouth Open: ${service.mouthOpen.toStringAsFixed(2)}'),
                                  Text('Mouth Smile: ${service.mouthSmile.toStringAsFixed(2)}'),
                                  Text('Mouth Funnel: ${service.mouthFunnel.toStringAsFixed(2)}'),
                                  Text('Mouth Pucker: ${service.mouthPucker.toStringAsFixed(2)}'),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
