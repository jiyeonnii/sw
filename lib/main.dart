import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_plan_screen.dart';

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
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/home': (context) => HomeScreen(),
        '/add_plan': (context) => AddPlanScreen(selectedDay: DateTime.now()), // Dummy date for initial route
      },
    );
  }
}
