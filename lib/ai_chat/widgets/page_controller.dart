import 'package:flutter/cupertino.dart';


void onOptionSelected(int index,PageController _pageController) {
  _pageController.animateToPage(index,
      duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
}
