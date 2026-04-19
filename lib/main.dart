import 'package:flutter/material.dart';
import 'package:gradproject/features/client/screens/sessions/assessments_screen.dart';
import 'features/client/widgets/client_nav_bar.dart';
import 'features/coach/widgets/coach_nav_bar.dart';


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
      home: const AssessmentsScreen(),

      // Testing as COACH: (uncomment this!)
      //home: const CoachNavBar(),
    );
  }
}