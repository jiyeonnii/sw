import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  BottomNavBar({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/calendar.png',
            width: 24,
            height: 24,
          ),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/budget.png',
            width: 24,
            height: 24,
          ),
          label: 'Budget',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/home.png',
            width: 24,
            height: 24,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/map.png',
            width: 24,
            height: 24,
          ),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/diary.png',
            width: 24,
            height: 24,
          ),
          label: 'Diary',
        ),
      ],
    );
  }
}
