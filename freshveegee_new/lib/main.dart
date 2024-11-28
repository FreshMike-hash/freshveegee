import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:freshveegee/mainpage.dart';
import 'signup_page.dart';
import 'login_page.dart';
import 'dashboard.dart';
import 'profile.dart';
import 'camera.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', 
      routes: {
        '/': (context) => const WelcomePage(),
        '/signup': (context) => const SignUpPage(),
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/profile': (context) => const ProfilePage(),
        '/camera': (context) => const FruitScanner(),
      },
    );
  }
}
