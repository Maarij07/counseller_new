// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GradientShadowCircle extends StatelessWidget {
  final double size;

  const GradientShadowCircle({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      width: 120.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B61FF).withOpacity(0.16),
            blurRadius: 160.r,
            offset: Offset(1.w, 4.h),
            spreadRadius: 10.r,
          ),
          BoxShadow(
            color: const Color(0xFFFF61DA).withOpacity(0.16),
            blurRadius: 160.r,
            offset: Offset(1.w, 3.h),
            spreadRadius: 50.r,
          ),
        ],
      ),
    );
  }
}

class GradientBackgroundScreen extends StatelessWidget {
  final Widget child;
  const GradientBackgroundScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          child: GradientShadowCircle(
            size: 100.r,
          ),
        ),
        SafeArea(child: child),
      ],
    );
  }
}
