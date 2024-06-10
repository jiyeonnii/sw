import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:piece_of_memory/screens/home_screen.dart';
import 'package:piece_of_memory/screens/budget_screen.dart';
import 'package:piece_of_memory/screens/diary_screen.dart';
import 'package:piece_of_memory/screens/map_screen.dart';
import 'package:piece_of_memory/screens/calendar_screen.dart';
import 'package:piece_of_memory/screens/login_screen.dart';
import 'package:piece_of_memory/screens/signup_screen.dart';

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
      home: AuthWrapper(),
      routes: {
        '/calendar': (context) => CalendarScreen(),
        '/budget': (context) => BudgetScreen(),
        '/home': (context) => HomeScreen(),
        '/map': (context) => MapScreen(),
        '/diary': (context) => DiaryScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasData) {
          return HomeScreen();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}
