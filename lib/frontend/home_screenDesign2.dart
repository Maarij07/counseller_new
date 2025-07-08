import 'package:flutter/material.dart';

class HomeScreenDesign2 extends StatelessWidget {
  const HomeScreenDesign2({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      right: 56,
      child: Row(
        children: [
 PopupMenuButton<String>(
  icon: const Icon(Icons.more_vert, color: Colors.black),
    tooltip: '', // ✅ מסיר את המילה "Show menu"

    offset: Offset(0, 40), // ✅ מזיז את התפריט 10 פיקסלים מתחת לאייקון

  color: Colors.white, // רקע לבן
  padding: EdgeInsets.zero, // מבטל מרווח חיצוני מיותר
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  onSelected: (value) {
    if (value == 'archive') {
      // פעולה לארכיון
    } else if (value == 'delete') {
      // פעולה למחיקה
    }
  },
  itemBuilder: (context) => [
    PopupMenuItem(
      height: 36, // ← גובה נמוך יותר לכל שורה
      value: 'archive',
      child: Row(
        children: [
          Icon(Icons.archive_outlined, color: Colors.black, size: 20),
          SizedBox(width: 8),
          Text('Archive', style: TextStyle(fontSize: 14)),
        ],
      ),
    ),
    PopupMenuItem(
      height: 36,
      value: 'delete',
      child: Row(
        children: [
          Icon(Icons.delete_outline, color: Colors.red, size: 20),
          SizedBox(width: 8),
          Text('Delete', style: TextStyle(color: Colors.red, fontSize: 14)),
        ],
      ),
    ),
  ],
)


        ],
      ),
    );
  }
}
