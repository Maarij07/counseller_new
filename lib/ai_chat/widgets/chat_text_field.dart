import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';

class ChatTextField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSubmitted;

  const ChatTextField({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(

        // color: Colors.black,
        // borderRadius: BorderRadius.circular(30.r),

        color: Colors.white, // רקע לבן
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: Colors.grey.shade300),

      ),
      child: Center(
        child: TextField(
          controller: controller,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              FocusScope.of(context).unfocus();
              onSubmitted(value);
            }
          },

          // style: Theme.of(context)
          //     .textTheme
          //     .titleSmall!
          //     .copyWith(color: Colors.white),
          // cursorColor: AppColors.background,
          // decoration: InputDecoration(
          //   hintText: "Type your message...",
          //   hintStyle: Theme.of(context)
          //       .textTheme
          //       .titleSmall!
          //       .copyWith(color: AppColors.background),

          style: TextStyle(
            fontFamily: 'NotoSansHebrew', // פונטים דמויי ChatGPT
            color: Colors.black,
            fontSize: 15.sp,
            fontWeight: FontWeight.w400,
          ),
          cursorColor: Colors.black,
          decoration: InputDecoration(
            hintText: "Type your message...",
            hintStyle: TextStyle(
              fontFamily: 'NotoSansHebrew',
              color: Colors.grey,
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
            ),

            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ),
          ),
        ),
      ),
    );
  }
}