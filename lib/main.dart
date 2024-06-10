import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:piece_of_memory/screens/home_screen.dart';
import 'package:piece_of_memory/screens/login_screen.dart';
import 'package:piece_of_memory/screens/signup_screen.dart';
import 'package:piece_of_memory/screens/budget_screen.dart';
import 'package:piece_of_memory/screens/diary_screen.dart';
import 'package:piece_of_memory/screens/map_screen.dart';
import 'package:piece_of_memory/screens/calendar_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Piece of Memory',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
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
