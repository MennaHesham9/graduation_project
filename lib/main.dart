import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. Add this import
 // 2. Ensure this path is correct
import 'core/screens/notification_screen.dart';
import 'features/client/dashboard/providers/dashboard_provider.dart';
import 'features/client/screens/coach_profile_client_side.dart';
import 'features/client/screens/edit_client_profile.dart';
import 'features/client/widgets/client_nav_bar.dart';
import 'features/coach/screens/presession_questionnaire_screen.dart';
import 'features/coach/widgets/coach_nav_bar.dart';
import 'features/authentication/screens/sign_in_screen.dart';
import 'features/client/screens/my_profile.dart';
import 'features/coach/screens/manage_session.dart';
import 'features/client/screens/mood_tracking.dart';
import 'features/client/screens/splash_screen.dart';
import 'firebase_options.dart';
import '../../../core/providers/auth_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),       // ADD
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindWell',
      debugShowCheckedModeBanner: false,

      // Testing as CLIENT:
      //home: const ClientNavBar(),

      // Testing as COACH: (uncomment this!)
      //home: const CoachNavBar(),

      // Testing Mood Tracking page:
      //home: const MoodTrackingScreen(),

      // Testing notification page:
      //home: const NotificationScreen(),

      // Testing Pre-session Questionnaire page:
      //home: const PresessionQuestionnaireScreen(),

      // Testing CoachProfileClientSide page:
      //home: const CoachProfileClientSide(),

      // Testing EditClientProfile page:
      //home: const EditClientProfile(),

      // Testing Splash page:
      home: const SplashScreen(),



    );
  }
}