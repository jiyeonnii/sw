// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/map_screen.dart';
import 'screens/diary_screen.dart';

void main() {
  runApp(PieceOfMemoryApp());
}

class PieceOfMemoryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Piece Of Memory',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/home': (context) => HomeScreen(),
        '/calendar': (context) => CalendarScreen(),
        '/budget': (context) => BudgetScreen(),
        '/map': (context) => MapScreen(),
        '/diary': (context) => DiaryScreen(),
      },
    );
  }
}
