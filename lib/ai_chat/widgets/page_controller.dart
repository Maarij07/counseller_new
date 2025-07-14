import 'package:flutter/cupertino.dart';


void onOptionSelected(int index,PageController pageController) {
  pageController.animateToPage(index,
      duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
}
