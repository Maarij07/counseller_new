import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/theme/app_colors.dart';

class SendButton extends StatelessWidget {
  const SendButton({
    super.key,
    required this.path,
    this.onTap,
    required this.isLoading, // Add isLoading to determine button state
  });

  final String path;
  final Function()? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap, // Disable tap when loading
      child: Container(
        height: 45.h,
        width: 45.h,
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  height: 15.h, // Ensure equal dimensions for circular shape
                  width: 15.h,
                  child: const CircularProgressIndicator(
                    color: Colors.white, // Show loading indicator
                    strokeWidth: 3,
                  ),
                )
              : SvgPicture.asset(
                  'assets/icons/$path.svg',
                  height: 20.h,
                  width: 20.h,
                ),
        ),
      ),
    );
  }
}
