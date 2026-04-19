import 'package:flutter/material.dart';
import 'core/screens/notification_screen.dart';
import 'features/client/widgets/client_nav_bar.dart';
import 'features/coach/widgets/coach_nav_bar.dart';
import 'core/screens/sign_in_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      debugShowCheckedModeBanner: false,

      // Testing as CLIENT:
      //home: const ClientNavBar(),

      // Testing as COACH: (uncomment this!)
      //home: const CoachNavBar(),

      // Testing Login page:
      home: const SignInScreen(),

      // Testing notification page:
      //home: const NotificationScreen(),

    );
  }
}