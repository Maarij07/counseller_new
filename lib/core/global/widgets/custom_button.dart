import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class CustomButton extends StatelessWidget {
  final String icon;
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final Color svgColor;
  final Color textColor;

  const CustomButton({super.key, 
    required this.icon,
    required this.text,
    required this.onPressed,
    required this.color,
    required this.svgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.06,

        margin: EdgeInsets.all(5.0.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.r),
          color: color, // Set dynamic color
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              icon,
              colorFilter: ColorFilter.mode(svgColor, BlendMode.srcIn),
            ),
            const SizedBox(width: 5.0),
            Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
