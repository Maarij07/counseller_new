// // import 'dart:convert';
// //
// // import 'package:flutter/material.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:soulli/core/theme/app_colors.dart';
// // import 'package:speech_to_text/speech_to_text.dart';
// //
// // import '../../../data/services/gpt_service.dart';
// // import '../../home/widgets/chat_text_field.dart';
// // import '../../home/widgets/logo_with_icon.dart';
// // import '../../home/widgets/send_button.dart';
// //
// // class ChatScreen extends StatefulWidget {
// //   const ChatScreen({super.key});
// //
// //   @override
// //   State<ChatScreen> createState() => _ChatScreenState();
// // }
// //
// // class _ChatScreenState extends State<ChatScreen> {
// //   final TextEditingController _controller = TextEditingController();
// //   final List<Map<String, String>> _messages = [];
// //   bool _isLoading = false;
// //   int selectedButton = 0;
// //   final SpeechToText _speechToText = SpeechToText();
// //
// //   bool _speechEnabled = false;
// //   String _wordsSpoken = "";
// //   String _chatGPTResponse = "";
// //   @override
// //   void initState() {
// //     super.initState();
// //     initSpeech();
// //   }
// //
// //   void initSpeech() async {
// //     _speechEnabled = await _speechToText.initialize();
// //     setState(() {});
// //   }
// //
// //   void _startListening() async {
// //     await _speechToText.listen(onResult: _onSpeechResult);
// //     setState(() {});
// //   }
// //
// //   void _stopListening() async {
// //     await _speechToText.stop();
// //     setState(() {});
// //   }
// //
// //   void _onSpeechResult(result) async {
// //     setState(() {
// //       _wordsSpoken = result.recognizedWords;
// //       // _confidenceLevel = result.confidence;
// //     });
// //
// //     if (_wordsSpoken.isNotEmpty) {
// //       // Send transcribed speech to ChatGPT
// //       final response = await getGPTResponse(_wordsSpoken);
// //       setState(() {
// //         if (response != null) {
// //           _messages.add({"sender": "gpt", "text": response});
// //         }
// //         _isLoading = false;
// //       });
// //     }
// //   }
// //
// //   Future<void> _sendMessage(String message) async {
// //     if (message.trim().isEmpty) return;
// //
// //     setState(() {
// //       _messages.add({"sender": "user", "text": message});
// //       _isLoading = true;
// //     });
// //     _controller.clear();
// //
// //     // Send the message to OpenAI API and get the response
// //     final response = await getGPTResponse(message);
// //
// //     // Add GPT's response to the chat
// //     setState(() {
// //       if (response != null) {
// //         _messages.add({"sender": "gpt", "text": response});
// //       }
// //       _isLoading = false;
// //     });
// //   }
// //
// //   Widget _buildMessage(Map<String, String> message) {
// //     final isUserMessage = message["sender"] == "user";
// //     return Container(
// //       margin: EdgeInsets.symmetric(horizontal: 12.w),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           if (!isUserMessage) LogoWithText(context: context),
// //           SizedBox(
// //             height: 5.h,
// //           ),
// //           Row(
// //             mainAxisAlignment:
// //             isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
// //             children: [
// //               SizedBox(width: 10.w),
// //               Container(
// //                 padding: EdgeInsets.all(12.w),
// //                 constraints: BoxConstraints(maxWidth: 230.w),
// //                 decoration: BoxDecoration(
// //                   color: isUserMessage
// //                       ? AppColors.userChatColor
// //                       : AppColors.botChatColor,
// //                   borderRadius: BorderRadius.circular(10.r),
// //                 ),
// //                 child: isUserMessage
// //                     ? Text(
// //                   message["text"] ?? "",
// //                   style: Theme.of(context)
// //                       .textTheme
// //                       .bodyMedium!
// //                       .copyWith(fontSize: 14.sp),
// //                 )
// //                     : Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     if (message["text"] != null)
// //                       Text(
// //                         message["text"]!,
// //                         style: Theme.of(context)
// //                             .textTheme
// //                             .bodyMedium!
// //                             .copyWith(fontSize: 14.sp),
// //                       ),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildInputField() {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
// //       child: Column(
// //         children: [
// //           Align(
// //             alignment: Alignment.bottomRight,
// //             child: SendButton(
// //               path: 'microphone',
// //               onTap: () {
// //                 _speechToText.isListening ? _stopListening : _startListening;
// //                 // Implement mic functionality
// //               },
// //             ),
// //           ),
// //           SizedBox(
// //             height: 10.h,
// //           ),
// //           Row(
// //             crossAxisAlignment:
// //             CrossAxisAlignment.center, // Align vertically within the row
// //             children: [
// //               ChatTextField(controller: _controller, context: context),
// //               SizedBox(width: 10.w),
// //               Row(
// //                   crossAxisAlignment: CrossAxisAlignment
// //                       .center, // Align vertically within the row
// //                   children: [
// //                     SendButton(
// //                       path: 'send',
// //                       onTap: () {
// //                         if (_controller.text.isNotEmpty) {
// //                           _sendMessage(_controller.text); // Send message on tap
// //                         }
// //                       },
// //                     ),
// //                   ]),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Column(
// //         children: [
// //           Text(
// //             _speechToText.isListening
// //                 ? "Listening..."
// //                 : _speechEnabled
// //                 ? "Tap the microphone to start listening..."
// //                 : "Speech not available",
// //             style: const TextStyle(fontSize: 20.0),
// //           ),
// //           Expanded(
// //             child: ListView.builder(
// //               itemCount: _messages.length,
// //               itemBuilder: (context, index) => _buildMessage(_messages[index]),
// //             ),
// //           ),
// //           _buildInputField(),
// //           SizedBox(
// //             height: 15.h,
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// import 'dart:async';
// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:speech_to_text/speech_recognition_result.dart';
// import 'package:speech_to_text/speech_to_text.dart';
// import '../../../data/services/gpt_service.dart';
// import 'ai_chat/widgets/buildMessage.dart';
// import 'ai_chat/widgets/wave_form.dart';
// import 'home/widgets/chat_text_field.dart';
// import 'home/widgets/logo_with_icon.dart';
// import 'home/widgets/send_button.dart';
// import 'package:soulli/core/theme/app_colors.dart';
//
// class ChatScreen extends StatefulWidget {
//   const ChatScreen({super.key});
//
//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final List<Map<String, String>> _messages = [];
//   final SpeechToText _speechToText = SpeechToText();
//
//   bool _isLoading = false;
//   bool _speechEnabled = false;
//   bool _isListening = false;
//
//   // Waveform data shown on screen
//   final List<double> _soundLevels = [];
//   // Buffer to hold incoming levels before UI update
//   final List<double> _soundBuffer = [];
//
//   final int _maxLevels = 60;
//
//   Timer? _recordTimer;
//   int _recordSeconds = 0;
//
//   Timer? _waveUpdateTimer;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeSpeech();
//
//     // Update waveform at a controlled rate (e.g., every 100ms)
//     _waveUpdateTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
//       if (_soundBuffer.isNotEmpty) {
//         setState(() {
//           _soundLevels.addAll(_soundBuffer);
//           _soundBuffer.clear();
//           if (_soundLevels.length > _maxLevels) {
//             _soundLevels.removeRange(0, _soundLevels.length - _maxLevels);
//           }
//         });
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _recordTimer?.cancel();
//     _waveUpdateTimer?.cancel();
//     super.dispose();
//   }
//
//   Future<void> _initializeSpeech() async {
//     _speechEnabled = await _speechToText.initialize();
//     setState(() {});
//   }
//
//   void _onSpeechResult(SpeechRecognitionResult result) {
//     setState(() {
//       _controller.text = result.recognizedWords;
//     });
//   }
//
//   void _onSoundLevelChange(double level) {
//     // The periodic timer will handle the UI update
//     _soundBuffer.add(level);
//   }
//
//
//
//   Future<void> _startListening() async {
//     if (_speechEnabled) {
//       setState(() {
//         _isListening = true;
//         _soundLevels.clear();
//         _soundBuffer.clear();
//         _recordSeconds = 0;
//       });
//
//       _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
//         setState(() {
//           _recordSeconds++;
//         });
//       });
//
//       try {
//         await _speechToText.listen(
//           onResult: _onSpeechResult,
//           onSoundLevelChange: _onSoundLevelChange,
//           listenMode: ListenMode.dictation,
//         );
//       } catch (e) {
//         debugPrint("Error during speech recognition: $e");
//       }
//     } else {
//       debugPrint("Speech recognition not enabled.");
//     }
//   }
//
//   Future<void> _stopListening() async {
//     try {
//       await _speechToText.stop();
//     } catch (e) {
//       debugPrint("Error stopping speech recognition: $e");
//     }
//
//     _recordTimer?.cancel();
//     setState(() {
//       _isListening = false;
//     });
//   }
//
//   Future<void> _sendMessage(String message) async {
//     if (message.trim().isEmpty) return;
//
//     setState(() {
//       _messages.add({"sender": "user", "text": message});
//       _isLoading = true;
//     });
//
//     _controller.clear();
//
//     final response = await getGPTResponse(message);
//
//     setState(() {
//       if (response != null) {
//         _messages.add({"sender": "gpt", "text": response});
//       }
//       _isLoading = false;
//     });
//   }
//
//
//
//   Widget _buildInputField() {
//     if (_isListening) {
//       return buildWaveform(context,()=>_stopListening(),()=>_stopListening(),_recordSeconds,_soundLevels);
//     }
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//       child: Column(
//         children: [
//           Align(
//             alignment: Alignment.bottomRight,
//             child: SendButton(
//               path: 'microphone',
//               onTap: () {
//                 if (_isListening) {
//                   _stopListening();
//                 } else {
//                   _startListening();
//                 }
//               },
//             ),
//           ),
//           SizedBox(height: 5.h),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               ChatTextField(
//                 controller: _controller,
//                 context: context,
//               ),
//               SizedBox(width: 10.w),
//               SendButton(
//                 path: 'send',
//                 onTap: () {
//                   if (_controller.text.isNotEmpty) {
//                     _sendMessage(_controller.text);
//                   }
//                 },
//               ),
//             ],
//           ),
//           SizedBox(height: 10.h),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           if (_isListening)
//             const Padding(
//               padding: EdgeInsets.all(8.0),
//               child: Text(
//                 "Listening... Tap the cancel or tick to Stop.",
//                 style: TextStyle(color: Colors.grey),
//               ),
//             ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: _messages.length,
//               itemBuilder: (context, index) => buildMessage(_messages[index],context),
//             ),
//           ),
//           _buildInputField(),
//           if (_isLoading)
//             const Padding(
//               padding: EdgeInsets.all(8.0),
//               child: CircularProgressIndicator(),
//             ),
//         ],
//       ),
//     );
//   }
// }
//
// /// A simpler custom painter that draws a series of thin rectangular bars.
// /// We have removed smoothing for performance.
