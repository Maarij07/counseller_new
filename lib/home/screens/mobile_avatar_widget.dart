// lib/home/screens/mobile_avatar_widget.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:phychological_counselor/home/screens/camera_mobile.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'mobile_avatar_service.dart';

class MobileAvatarWidget extends StatefulWidget {
  final double width;
  final double height;

  const MobileAvatarWidget({
    super.key,
    this.width = 300,
    this.height = 400,
  });

  @override
  State<MobileAvatarWidget> createState() => _MobileAvatarWidgetState();
}

class _MobileAvatarWidgetState extends State<MobileAvatarWidget>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _idleController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _idleAnimation;

  Flutter3DController controller = Flutter3DController();
  Future<void> init3DController() async {
    //It will return available textures list of 3D model.
await controller.getAvailableTextures();

//It will set your desired camera target.
controller.setCameraTarget(0.3, 0.2, 0.4);

//It will reset the camera target to default.
controller.resetCameraTarget();

//It will set your desired camera orbit.
controller.setCameraOrbit(20, 20, 5);

//It will reset the camera orbit to default.
controller.resetCameraOrbit();
  }

  @override
  void initState() {
    super.initState();
    init3DController() ;
    // Breathing animation
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _breathingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));
    
    // Idle movement animation
    _idleController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );
    _idleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _idleController,
      curve: Curves.easeInOut,
    ));

    _breathingController.repeat();
    _idleController.repeat();
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _idleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MobileAvatarService>(
      builder: (context, avatarService, child) {
        return Stack(
          children: [
            
            Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue.shade100,
                    Colors.purple.shade100,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: 
                  //The 3D viewer widget for glb and gltf format
                  Stack(
                    children: [
                      _buildBackgroundEffects(),
                    ModelViewer(
                      src: 'assets/avatars/avatarOriginal.glb',
                      autoPlay: true,
                      cameraControls: true,
                      disableZoom: true,
                      iosSrc: 'assets/avatars/avatarOriginal.glb',
                      alt: "A 3D avatar",
                      ar: true,
                      arModes: [

                      ],
                        
                    ),
                  _buildStatusIndicator(avatarService),
                    ],
                  ),
            
            // 3D Controller
                  // Stack(
                  //   children: [
                  //     _buildBackgroundEffects(),
                  //     Flutter3DViewer(
                  //         //If you pass 'true' the flutter_3d_controller will add gesture interceptor layer
                  //         //to prevent gesture recognizers from malfunctioning on iOS and some Android devices.
                  //         //the default value is true
                  //         activeGestureInterceptor: true,
                  //         //If you don't pass progressBarColor, the color of defaultLoadingProgressBar will be grey.
                  //         //You can set your custom color or use [Colors.transparent] for hiding loadingProgressBar.
                  //         progressBarColor: Colors.orange,
                  //         //You can disable viewer touch response by setting 'enableTouch' to 'false'
                  //         enableTouch: true,
                  //         //This callBack will return the loading progress value between 0 and 1.0
                  //         onProgress: (double progressValue) {
                  //           debugPrint('model loading progress : $progressValue');
                              
                  //         },
                  //         //This callBack will call after model loaded successfully and will return model address
                  //         onLoad: (String modelAddress) {
                  //           debugPrint('model loaded : $modelAddress');
                  //           controller.playAnimation(loopCount: 0);
                  //         },
                  //         //this callBack will call when model failed to load and will return failure error
                  //         onError: (String error) {
                  //           debugPrint('model failed to load : $error');
                  //         },
                  //         //You can have full control of 3d model animations, textures and camera
                  //         controller: controller, //3D model with different animations
                  //         src: 'assets/avatars/avatarOriginal.glb', //3D model with different animations
                  //         //src: 'assets/sheen_chair.glb', //3D model with different textures
                  //         //src: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb', // 3D model from URL
                  //     ),

                  // _buildStatusIndicator(avatarService),
                  //   ],
                  // ),
            
              // Stack(
              //   children: [
                  // Background and lighting effects
                  // _buildBackgroundEffects(),]
                  // Center(
                  //   child: AnimatedBuilder(
                  //     animation: Listenable.merge([_breathingAnimation, _idleAnimation]),
                  //     builder: (context, child) {
                  //       return CustomPaint(
                  //         size: Size(widget.width, widget.height),
                  //         painter: AvatarPainter(
                  //           avatarService: avatarService,
                  //           breathingValue: _breathingAnimation.value,
                  //           idleValue: _idleAnimation.value,
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // ),
                  // // Status indicator
                  // _buildStatusIndicator(avatarService),
                  // ],
              // ),
            // ),

            ),
            Positioned(
                bottom: 100,
                right: 260,
                left: 0,
                top: 20,
                child: CameraBox(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildBackgroundEffects() {
    return AnimatedBuilder(
      animation: _idleAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: RadialGradient(
              center: Alignment(
                sin(_idleAnimation.value * 2 * pi) * 0.3,
                cos(_idleAnimation.value * 2 * pi) * 0.2,
              ),
              radius: 0.8,
              colors: [
                Colors.white.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIndicator(MobileAvatarService avatarService) {
    String statusText = '';
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.circle;

    if (avatarService.isSpeaking) {
      statusText = '🗣️ Speaking...';
      statusColor = Colors.green;
      statusIcon = Icons.record_voice_over;
    } else if (avatarService.isAvatarLoaded) {
      statusText = '💬 Ready';
      statusColor = Colors.blue;
      statusIcon = Icons.check_circle;
    } else {
      statusText = '⏳ Loading...';
      statusColor = Colors.orange;
      statusIcon = Icons.hourglass_empty;
    }

    return Positioned(
      top: 10,
      left: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(statusIcon, color: statusColor, size: 16),
            const SizedBox(width: 6),
            Text(
              statusText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AvatarPainter extends CustomPainter {
  final MobileAvatarService avatarService;
  final double breathingValue;
  final double idleValue;

  AvatarPainter({
    required this.avatarService,
    required this.breathingValue,
    required this.idleValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Calculate breathing offset
    final breathingOffset = sin(breathingValue * 2 * pi) * 2;
    
    // Calculate idle movement
    final idleOffsetX = sin(idleValue * 2 * pi) * 5;
    final idleOffsetY = cos(idleValue * 3 * pi) * 3;
    
    final avatarCenter = Offset(
      center.dx + idleOffsetX,
      center.dy + breathingOffset + idleOffsetY,
    );

    // Draw shadow
    _drawShadow(canvas, avatarCenter, size);
    
    // Draw body
    _drawBody(canvas, avatarCenter, size);
    
    // Draw hands
    _drawHands(canvas, avatarCenter, size);
    
    // Draw head
    _drawHead(canvas, avatarCenter, size);
    
    // Draw hair
    _drawHair(canvas, avatarCenter, size);
    
    // Draw face features
    _drawFaceFeatures(canvas, avatarCenter, size);
    
    // Draw mouth with lip sync
    _drawMouth(canvas, avatarCenter, size);
    
    // Draw eyes with blinking
    _drawEyes(canvas, avatarCenter, size);
    
    // Draw eyebrows with expressions
    _drawEyebrows(canvas, avatarCenter, size);
  }

  void _drawShadow(Canvas canvas, Offset center, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, size.height - 30),
        width: 120,
        height: 20,
      ),
      paint,
    );
  }

  void _drawBody(Canvas canvas, Offset center, Size size) {
    final bodyPaint = Paint()
      ..color = const Color(0xFF87CEEB)
      ..style = PaintingStyle.fill;

    // Torso
    final torsoRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + 80),
        width: 100,
        height: 120,
      ),
      const Radius.circular(15),
    );
    canvas.drawRRect(torsoRect, bodyPaint);

    // Shoulders
    canvas.drawCircle(
      Offset(center.dx - 40, center.dy + 30),
      25,
      bodyPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + 40, center.dy + 30),
      25,
      bodyPaint,
    );
  }

  void _drawHands(Canvas canvas, Offset center, Size size) {
    final handPaint = Paint()
      ..color = const Color(0xFFFFDBB5)
      ..style = PaintingStyle.fill;

    // Left hand
    final leftHandX = center.dx + (avatarService.leftHandX * 100);
    final leftHandY = center.dy + (avatarService.leftHandY * 100);
    final leftHandPos = Offset(leftHandX, leftHandY);
    
    canvas.save();
    canvas.translate(leftHandPos.dx, leftHandPos.dy);
    canvas.rotate(avatarService.leftHandRotation);
    canvas.drawCircle(Offset.zero, 15, handPaint);
    
    // Fingers for left hand
    for (int i = 0; i < 5; i++) {
      final fingerAngle = (i - 2) * 0.3;
      final fingerEnd = Offset(
        cos(fingerAngle) * 20,
        sin(fingerAngle) * 20,
      );
      canvas.drawLine(
        Offset.zero,
        fingerEnd,
        Paint()
          ..color = const Color(0xFFFFDBB5)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.restore();

    // Right hand
    final rightHandX = center.dx + (avatarService.rightHandX * 100);
    final rightHandY = center.dy + (avatarService.rightHandY * 100);
    final rightHandPos = Offset(rightHandX, rightHandY);
    
    canvas.save();
    canvas.translate(rightHandPos.dx, rightHandPos.dy);
    canvas.rotate(avatarService.rightHandRotation);
    canvas.drawCircle(Offset.zero, 15, handPaint);
    
    // Fingers for right hand
    for (int i = 0; i < 5; i++) {
      final fingerAngle = (i - 2) * 0.3;
      final fingerEnd = Offset(
        cos(fingerAngle) * 20,
        sin(fingerAngle) * 20,
      );
      canvas.drawLine(
        Offset.zero,
        fingerEnd,
        Paint()
          ..color = const Color(0xFFFFDBB5)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.restore();

    // Arms connecting to hands
    final armPaint = Paint()
      ..color = const Color(0xFF87CEEB)
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    // Left arm
    canvas.drawLine(
      Offset(center.dx - 40, center.dy + 30),
      leftHandPos,
      armPaint,
    );

    // Right arm
    canvas.drawLine(
      Offset(center.dx + 40, center.dy + 30),
      rightHandPos,
      armPaint,
    );
  }

  void _drawHead(Canvas canvas, Offset center, Size size) {
    final headPaint = Paint()
      ..color = const Color(0xFFFFDBB5)
      ..style = PaintingStyle.fill;

    // Head shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawCircle(
      Offset(center.dx + 2, center.dy - 28),
      52,
      shadowPaint,
    );

    // Main head
    canvas.drawCircle(Offset(center.dx, center.dy - 30), 50, headPaint);
  }

  void _drawHair(Canvas canvas, Offset center, Size size) {
    final hairPaint = Paint()
      ..color = const Color(0xFF8B4513)
      ..style = PaintingStyle.fill;

    // Hair outline
    final hairPath = Path();
    hairPath.addOval(Rect.fromCenter(
      center: Offset(center.dx, center.dy - 45),
      width: 110,
      height: 80,
    ));

    canvas.drawPath(hairPath, hairPaint);
  }

  void _drawFaceFeatures(Canvas canvas, Offset center, Size size) {
    // Nose
    final nosePaint = Paint()
      ..color = const Color(0xFFFFDBB5).withOpacity(0.8)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(center.dx, center.dy - 20), 6, nosePaint);

    // Cheeks (with expression)
    if (avatarService.cheekPuff > 0) {
      final cheekPaint = Paint()
        ..color = Colors.pink.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(center.dx - 25, center.dy - 15),
        8 + (avatarService.cheekPuff * 5),
        cheekPaint,
      );
      canvas.drawCircle(
        Offset(center.dx + 25, center.dy - 15),
        8 + (avatarService.cheekPuff * 5),
        cheekPaint,
      );
    }
  }

  void _drawMouth(Canvas canvas, Offset center, Size size) {
    final mouthCenter = Offset(center.dx, center.dy - 5);
    
    // Calculate mouth shape based on lip sync values
    final jawOffset = avatarService.jawOpen * 15;
    final mouthWidth = 20 + (avatarService.mouthSmile * 15) - (avatarService.mouthPucker * 10);
    final mouthHeight = 4 + (avatarService.mouthOpen * 12) + (avatarService.jawOpen * 8);
    final funnelEffect = avatarService.mouthFunnel * 0.5;

    final mouthPaint = Paint()
      ..color = const Color(0xFFD2691E)
      ..style = PaintingStyle.fill;

    // Draw mouth shape
    if (avatarService.mouthPucker > 0.3 || avatarService.mouthFunnel > 0.3) {
      // Rounded mouth for pucker/funnel
      canvas.drawCircle(
        Offset(mouthCenter.dx, mouthCenter.dy + jawOffset),
        mouthWidth * (0.5 + funnelEffect),
        mouthPaint,
      );
    } else {
      // Elliptical mouth for other expressions
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(mouthCenter.dx, mouthCenter.dy + jawOffset),
          width: mouthWidth,
          height: mouthHeight,
        ),
        mouthPaint,
      );
    }

    // Teeth when mouth is open
    if (avatarService.mouthOpen > 0.3 || avatarService.jawOpen > 0.3) {
      final teethPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(mouthCenter.dx, mouthCenter.dy + jawOffset - 2),
          width: mouthWidth * 0.8,
          height: mouthHeight * 0.6,
        ),
        teethPaint,
      );
    }
  }

  void _drawEyes(Canvas canvas, Offset center, Size size) {
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final pupilPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final leftEyeCenter = Offset(center.dx - 18, center.dy - 35);
    final rightEyeCenter = Offset(center.dx + 18, center.dy - 35);

    // Eye whites
    if (avatarService.eyeBlinkLeft < 0.9) {
      canvas.drawOval(
        Rect.fromCenter(
          center: leftEyeCenter,
          width: 16,
          height: 12 * (1 - avatarService.eyeBlinkLeft),
        ),
        eyePaint,
      );
    }

    if (avatarService.eyeBlinkRight < 0.9) {
      canvas.drawOval(
        Rect.fromCenter(
          center: rightEyeCenter,
          width: 16,
          height: 12 * (1 - avatarService.eyeBlinkRight),
        ),
        eyePaint,
      );
    }

    // Pupils
    if (avatarService.eyeBlinkLeft < 0.7) {
      canvas.drawCircle(leftEyeCenter, 4, pupilPaint);
    }

    if (avatarService.eyeBlinkRight < 0.7) {
      canvas.drawCircle(rightEyeCenter, 4, pupilPaint);
    }

    // Eyelashes
    final lashPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    if (avatarService.eyeBlinkLeft < 0.8) {
      for (int i = 0; i < 5; i++) {
        final angle = (i - 2) * 0.2;
        final start = Offset(
          leftEyeCenter.dx + cos(angle) * 8, 
          leftEyeCenter.dy - sin(angle) * 6
        );
        final end = Offset(
          leftEyeCenter.dx + cos(angle) * 12, 
          leftEyeCenter.dy - sin(angle) * 10
        );
        canvas.drawLine(start, end, lashPaint);
      }
    }

    if (avatarService.eyeBlinkRight < 0.8) {
      for (int i = 0; i < 5; i++) {
        final angle = (i - 2) * 0.2;
        final start = Offset(
          rightEyeCenter.dx + cos(angle) * 8, 
          rightEyeCenter.dy - sin(angle) * 6
        );
        final end = Offset(
          rightEyeCenter.dx + cos(angle) * 12, 
          rightEyeCenter.dy - sin(angle) * 10
        );
        canvas.drawLine(start, end, lashPaint);
      }
    }
  }

  void _drawEyebrows(Canvas canvas, Offset center, Size size) {
    final browPaint = Paint()
      ..color = const Color(0xFF8B4513)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final leftBrowCenter = Offset(center.dx - 18, center.dy - 50);
    final rightBrowCenter = Offset(center.dx + 18, center.dy - 50);

    // Apply brow expression
    final browOffset = avatarService.browUp * 5;

    // Left eyebrow
    canvas.drawLine(
      Offset(leftBrowCenter.dx - 8, leftBrowCenter.dy - browOffset),
      Offset(leftBrowCenter.dx + 8, leftBrowCenter.dy - browOffset),
      browPaint,
    );

    // Right eyebrow
    canvas.drawLine(
      Offset(rightBrowCenter.dx - 8, rightBrowCenter.dy - browOffset),
      Offset(rightBrowCenter.dx + 8, rightBrowCenter.dy - browOffset),
      browPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Always repaint for animations
  }
}
// // lib/home/screens/mobile_avatar_widget.dart

// // ignore_for_file: deprecated_member_use

// import 'package:flutter/material.dart';
// import 'package:model_viewer_plus/model_viewer_plus.dart';
// import 'package:phychological_counselor/home/screens/camera_mobile.dart';
// import 'package:provider/provider.dart';
// import 'dart:math';
// import 'mobile_avatar_service.dart';

// class MobileAvatarWidget extends StatefulWidget {
//   final double width;
//   final double height;

//   const MobileAvatarWidget({
//     super.key,
//     this.width = 300,
//     this.height = 400,
//   });

//   @override
//   State<MobileAvatarWidget> createState() => _MobileAvatarWidgetState();
// }

// class _MobileAvatarWidgetState extends State<MobileAvatarWidget>
//     with TickerProviderStateMixin {
//   late AnimationController _breathingController;
//   late AnimationController _idleController;
//   late Animation<double> _breathingAnimation;
//   late Animation<double> _idleAnimation;

//   @override
//   void initState() {
//     super.initState();
    
//     // Breathing animation
//     _breathingController = AnimationController(
//       duration: const Duration(seconds: 4),
//       vsync: this,
//     );
//     _breathingAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _breathingController,
//       curve: Curves.easeInOut,
//     ));
    
//     // Idle movement animation
//     _idleController = AnimationController(
//       duration: const Duration(seconds: 6),
//       vsync: this,
//     );
//     _idleAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _idleController,
//       curve: Curves.easeInOut,
//     ));

//     _breathingController.repeat();
//     _idleController.repeat();
//   }

//   @override
//   void dispose() {
//     _breathingController.dispose();
//     _idleController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<MobileAvatarService>(
//       builder: (context, avatarService, child) {
//         return Stack(
//           children: [
            
//             Container(
//               width: widget.width,
//               height: widget.height,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Colors.blue.shade100,
//                     Colors.purple.shade100,
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 10,
//                     offset: const Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: Stack(
//                 children: [
//                   // Background and lighting effects
//                   _buildBackgroundEffects(),
//                   // Main avatar
//                   Center(
//                     child: AnimatedBuilder(
//                       animation: Listenable.merge([_breathingAnimation, _idleAnimation]),
//                       builder: (context, child) {
//                         return CustomPaint(
//                           size: Size(widget.width, widget.height),
//                           painter: AvatarPainter(
//                             avatarService: avatarService,
//                             breathingValue: _breathingAnimation.value,
//                             idleValue: _idleAnimation.value,
//                           ),
//                         );
//                       },
//                     ),
//                   ),
              
//                   // Status indicator
//                   _buildStatusIndicator(avatarService),
//                 ],
//               ),
//             ),
//             Positioned(
//                 bottom: 100,
//                 right: 260,
//                 left: 0,
//                 top: 20,
//                 child: CameraBox(),
//               ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildBackgroundEffects() {
//     return AnimatedBuilder(
//       animation: _idleAnimation,
//       builder: (context, child) {
//         return Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(20),
//             gradient: RadialGradient(
//               center: Alignment(
//                 sin(_idleAnimation.value * 2 * pi) * 0.3,
//                 cos(_idleAnimation.value * 2 * pi) * 0.2,
//               ),
//               radius: 0.8,
//               colors: [
//                 Colors.white.withOpacity(0.3),
//                 Colors.transparent,
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildStatusIndicator(MobileAvatarService avatarService) {
//     String statusText = '';
//     Color statusColor = Colors.grey;
//     IconData statusIcon = Icons.circle;

//     if (avatarService.isSpeaking) {
//       statusText = '🗣️ Speaking...';
//       statusColor = Colors.green;
//       statusIcon = Icons.record_voice_over;
//     } else if (avatarService.isAvatarLoaded) {
//       statusText = '💬 Ready';
//       statusColor = Colors.blue;
//       statusIcon = Icons.check_circle;
//     } else {
//       statusText = '⏳ Loading...';
//       statusColor = Colors.orange;
//       statusIcon = Icons.hourglass_empty;
//     }

//     return Positioned(
//       top: 10,
//       left: 10,
//       right: 10,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         decoration: BoxDecoration(
//           color: Colors.black87,
//           borderRadius: BorderRadius.circular(15),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(statusIcon, color: statusColor, size: 16),
//             const SizedBox(width: 6),
//             Text(
//               statusText,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class AvatarPainter extends CustomPainter {
//   final MobileAvatarService avatarService;
//   final double breathingValue;
//   final double idleValue;

//   AvatarPainter({
//     required this.avatarService,
//     required this.breathingValue,
//     required this.idleValue,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
    
//     // Calculate breathing offset
//     final breathingOffset = sin(breathingValue * 2 * pi) * 2;
    
//     // Calculate idle movement
//     final idleOffsetX = sin(idleValue * 2 * pi) * 5;
//     final idleOffsetY = cos(idleValue * 3 * pi) * 3;
    
//     final avatarCenter = Offset(
//       center.dx + idleOffsetX,
//       center.dy + breathingOffset + idleOffsetY,
//     );

//     // Draw shadow
//     _drawShadow(canvas, avatarCenter, size);
    
//     // Draw body
//     _drawBody(canvas, avatarCenter, size);
    
//     // Draw hands
//     _drawHands(canvas, avatarCenter, size);
    
//     // Draw head
//     _drawHead(canvas, avatarCenter, size);
    
//     // Draw hair
//     _drawHair(canvas, avatarCenter, size);
    
//     // Draw face features
//     _drawFaceFeatures(canvas, avatarCenter, size);
    
//     // Draw mouth with lip sync
//     _drawMouth(canvas, avatarCenter, size);
    
//     // Draw eyes with blinking
//     _drawEyes(canvas, avatarCenter, size);
    
//     // Draw eyebrows with expressions
//     _drawEyebrows(canvas, avatarCenter, size);
//   }

//   void _drawShadow(Canvas canvas, Offset center, Size size) {
//     final paint = Paint()
//       ..color = Colors.black.withOpacity(0.1)
//       ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

//     canvas.drawOval(
//       Rect.fromCenter(
//         center: Offset(center.dx, size.height - 30),
//         width: 120,
//         height: 20,
//       ),
//       paint,
//     );
//   }

//   void _drawBody(Canvas canvas, Offset center, Size size) {
//     final bodyPaint = Paint()
//       ..color = const Color(0xFF87CEEB)
//       ..style = PaintingStyle.fill;

//     // Torso
//     final torsoRect = RRect.fromRectAndRadius(
//       Rect.fromCenter(
//         center: Offset(center.dx, center.dy + 80),
//         width: 100,
//         height: 120,
//       ),
//       const Radius.circular(15),
//     );
//     canvas.drawRRect(torsoRect, bodyPaint);

//     // Shoulders
//     canvas.drawCircle(
//       Offset(center.dx - 40, center.dy + 30),
//       25,
//       bodyPaint,
//     );
//     canvas.drawCircle(
//       Offset(center.dx + 40, center.dy + 30),
//       25,
//       bodyPaint,
//     );
//   }

//   void _drawHands(Canvas canvas, Offset center, Size size) {
//     final handPaint = Paint()
//       ..color = const Color(0xFFFFDBB5)
//       ..style = PaintingStyle.fill;

//     // Left hand
//     final leftHandX = center.dx + (avatarService.leftHandX * 100);
//     final leftHandY = center.dy + (avatarService.leftHandY * 100);
//     final leftHandPos = Offset(leftHandX, leftHandY);
    
//     canvas.save();
//     canvas.translate(leftHandPos.dx, leftHandPos.dy);
//     canvas.rotate(avatarService.leftHandRotation);
//     canvas.drawCircle(Offset.zero, 15, handPaint);
    
//     // Fingers for left hand
//     for (int i = 0; i < 5; i++) {
//       final fingerAngle = (i - 2) * 0.3;
//       final fingerEnd = Offset(
//         cos(fingerAngle) * 20,
//         sin(fingerAngle) * 20,
//       );
//       canvas.drawLine(
//         Offset.zero,
//         fingerEnd,
//         Paint()
//           ..color = const Color(0xFFFFDBB5)
//           ..strokeWidth = 3
//           ..strokeCap = StrokeCap.round,
//       );
//     }
//     canvas.restore();

//     // Right hand
//     final rightHandX = center.dx + (avatarService.rightHandX * 100);
//     final rightHandY = center.dy + (avatarService.rightHandY * 100);
//     final rightHandPos = Offset(rightHandX, rightHandY);
    
//     canvas.save();
//     canvas.translate(rightHandPos.dx, rightHandPos.dy);
//     canvas.rotate(avatarService.rightHandRotation);
//     canvas.drawCircle(Offset.zero, 15, handPaint);
    
//     // Fingers for right hand
//     for (int i = 0; i < 5; i++) {
//       final fingerAngle = (i - 2) * 0.3;
//       final fingerEnd = Offset(
//         cos(fingerAngle) * 20,
//         sin(fingerAngle) * 20,
//       );
//       canvas.drawLine(
//         Offset.zero,
//         fingerEnd,
//         Paint()
//           ..color = const Color(0xFFFFDBB5)
//           ..strokeWidth = 3
//           ..strokeCap = StrokeCap.round,
//       );
//     }
//     canvas.restore();

//     // Arms connecting to hands
//     final armPaint = Paint()
//       ..color = const Color(0xFF87CEEB)
//       ..strokeWidth = 20
//       ..strokeCap = StrokeCap.round;

//     // Left arm
//     canvas.drawLine(
//       Offset(center.dx - 40, center.dy + 30),
//       leftHandPos,
//       armPaint,
//     );

//     // Right arm
//     canvas.drawLine(
//       Offset(center.dx + 40, center.dy + 30),
//       rightHandPos,
//       armPaint,
//     );
//   }

//   void _drawHead(Canvas canvas, Offset center, Size size) {
//     final headPaint = Paint()
//       ..color = const Color(0xFFFFDBB5)
//       ..style = PaintingStyle.fill;

//     // Head shadow
//     final shadowPaint = Paint()
//       ..color = Colors.black.withOpacity(0.1)
//       ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

//     canvas.drawCircle(
//       Offset(center.dx + 2, center.dy - 28),
//       52,
//       shadowPaint,
//     );

//     // Main head
//     canvas.drawCircle(Offset(center.dx, center.dy - 30), 50, headPaint);
//   }

//   void _drawHair(Canvas canvas, Offset center, Size size) {
//     final hairPaint = Paint()
//       ..color = const Color(0xFF8B4513)
//       ..style = PaintingStyle.fill;

//     // Hair outline
//     final hairPath = Path();
//     hairPath.addOval(Rect.fromCenter(
//       center: Offset(center.dx, center.dy - 45),
//       width: 110,
//       height: 80,
//     ));

//     canvas.drawPath(hairPath, hairPaint);
//   }

//   void _drawFaceFeatures(Canvas canvas, Offset center, Size size) {
//     // Nose
//     final nosePaint = Paint()
//       ..color = const Color(0xFFFFDBB5).withOpacity(0.8)
//       ..style = PaintingStyle.fill;

//     canvas.drawCircle(Offset(center.dx, center.dy - 20), 6, nosePaint);

//     // Cheeks (with expression)
//     if (avatarService.cheekPuff > 0) {
//       final cheekPaint = Paint()
//         ..color = Colors.pink.withOpacity(0.3)
//         ..style = PaintingStyle.fill;

//       canvas.drawCircle(
//         Offset(center.dx - 25, center.dy - 15),
//         8 + (avatarService.cheekPuff * 5),
//         cheekPaint,
//       );
//       canvas.drawCircle(
//         Offset(center.dx + 25, center.dy - 15),
//         8 + (avatarService.cheekPuff * 5),
//         cheekPaint,
//       );
//     }
//   }

//   void _drawMouth(Canvas canvas, Offset center, Size size) {
//     final mouthCenter = Offset(center.dx, center.dy - 5);
    
//     // Calculate mouth shape based on lip sync values
//     final jawOffset = avatarService.jawOpen * 15;
//     final mouthWidth = 20 + (avatarService.mouthSmile * 15) - (avatarService.mouthPucker * 10);
//     final mouthHeight = 4 + (avatarService.mouthOpen * 12) + (avatarService.jawOpen * 8);
//     final funnelEffect = avatarService.mouthFunnel * 0.5;

//     final mouthPaint = Paint()
//       ..color = const Color(0xFFD2691E)
//       ..style = PaintingStyle.fill;

//     // Draw mouth shape
//     if (avatarService.mouthPucker > 0.3 || avatarService.mouthFunnel > 0.3) {
//       // Rounded mouth for pucker/funnel
//       canvas.drawCircle(
//         Offset(mouthCenter.dx, mouthCenter.dy + jawOffset),
//         mouthWidth * (0.5 + funnelEffect),
//         mouthPaint,
//       );
//     } else {
//       // Elliptical mouth for other expressions
//       canvas.drawOval(
//         Rect.fromCenter(
//           center: Offset(mouthCenter.dx, mouthCenter.dy + jawOffset),
//           width: mouthWidth,
//           height: mouthHeight,
//         ),
//         mouthPaint,
//       );
//     }

//     // Teeth when mouth is open
//     if (avatarService.mouthOpen > 0.3 || avatarService.jawOpen > 0.3) {
//       final teethPaint = Paint()
//         ..color = Colors.white
//         ..style = PaintingStyle.fill;

//       canvas.drawOval(
//         Rect.fromCenter(
//           center: Offset(mouthCenter.dx, mouthCenter.dy + jawOffset - 2),
//           width: mouthWidth * 0.8,
//           height: mouthHeight * 0.6,
//         ),
//         teethPaint,
//       );
//     }
//   }

//   void _drawEyes(Canvas canvas, Offset center, Size size) {
//     final eyePaint = Paint()
//       ..color = Colors.white
//       ..style = PaintingStyle.fill;

//     final pupilPaint = Paint()
//       ..color = Colors.black
//       ..style = PaintingStyle.fill;

//     final leftEyeCenter = Offset(center.dx - 18, center.dy - 35);
//     final rightEyeCenter = Offset(center.dx + 18, center.dy - 35);

//     // Eye whites
//     if (avatarService.eyeBlinkLeft < 0.9) {
//       canvas.drawOval(
//         Rect.fromCenter(
//           center: leftEyeCenter,
//           width: 16,
//           height: 12 * (1 - avatarService.eyeBlinkLeft),
//         ),
//         eyePaint,
//       );
//     }

//     if (avatarService.eyeBlinkRight < 0.9) {
//       canvas.drawOval(
//         Rect.fromCenter(
//           center: rightEyeCenter,
//           width: 16,
//           height: 12 * (1 - avatarService.eyeBlinkRight),
//         ),
//         eyePaint,
//       );
//     }

//     // Pupils
//     if (avatarService.eyeBlinkLeft < 0.7) {
//       canvas.drawCircle(leftEyeCenter, 4, pupilPaint);
//     }

//     if (avatarService.eyeBlinkRight < 0.7) {
//       canvas.drawCircle(rightEyeCenter, 4, pupilPaint);
//     }

//     // Eyelashes
//     final lashPaint = Paint()
//       ..color = Colors.black
//       ..strokeWidth = 1.5
//       ..strokeCap = StrokeCap.round;

//     if (avatarService.eyeBlinkLeft < 0.8) {
//       for (int i = 0; i < 5; i++) {
//         final angle = (i - 2) * 0.2;
//         final start = Offset(
//           leftEyeCenter.dx + cos(angle) * 8, 
//           leftEyeCenter.dy - sin(angle) * 6
//         );
//         final end = Offset(
//           leftEyeCenter.dx + cos(angle) * 12, 
//           leftEyeCenter.dy - sin(angle) * 10
//         );
//         canvas.drawLine(start, end, lashPaint);
//       }
//     }

//     if (avatarService.eyeBlinkRight < 0.8) {
//       for (int i = 0; i < 5; i++) {
//         final angle = (i - 2) * 0.2;
//         final start = Offset(
//           rightEyeCenter.dx + cos(angle) * 8, 
//           rightEyeCenter.dy - sin(angle) * 6
//         );
//         final end = Offset(
//           rightEyeCenter.dx + cos(angle) * 12, 
//           rightEyeCenter.dy - sin(angle) * 10
//         );
//         canvas.drawLine(start, end, lashPaint);
//       }
//     }
//   }

//   void _drawEyebrows(Canvas canvas, Offset center, Size size) {
//     final browPaint = Paint()
//       ..color = const Color(0xFF8B4513)
//       ..strokeWidth = 4
//       ..strokeCap = StrokeCap.round;

//     final leftBrowCenter = Offset(center.dx - 18, center.dy - 50);
//     final rightBrowCenter = Offset(center.dx + 18, center.dy - 50);

//     // Apply brow expression
//     final browOffset = avatarService.browUp * 5;

//     // Left eyebrow
//     canvas.drawLine(
//       Offset(leftBrowCenter.dx - 8, leftBrowCenter.dy - browOffset),
//       Offset(leftBrowCenter.dx + 8, leftBrowCenter.dy - browOffset),
//       browPaint,
//     );

//     // Right eyebrow
//     canvas.drawLine(
//       Offset(rightBrowCenter.dx - 8, rightBrowCenter.dy - browOffset),
//       Offset(rightBrowCenter.dx + 8, rightBrowCenter.dy - browOffset),
//       browPaint,
//     );
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true; // Always repaint for animations
//   }
// }
