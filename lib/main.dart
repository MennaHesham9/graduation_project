import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mindwell/features/on_boarding/screens/on_boarding_screen1.dart';
import 'package:provider/provider.dart';
import 'core/screens/notification_screen.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/profile_provider.dart';
import 'features/booking/providers/booking_provider.dart';
import 'features/client/dashboard/providers/dashboard_provider.dart';
import 'features/client/providers/coaches_provider.dart';
import 'features/client/screens/coach_profile_client_side.dart';
import 'features/client/widgets/client_nav_bar.dart';
import 'features/coach/screens/presession_questionnaire_screen.dart';
import 'features/coach/widgets/coach_nav_bar.dart';
import 'features/authentication/screens/sign_in_screen.dart';
import 'features/coach/screens/manage_session.dart';
import 'features/client/screens/mood_tracking.dart';
import 'features/on_boarding/screens/splash_screen.dart';
import 'features/tasks/providers/task_provider.dart';
import 'features/client/goals/providers/goal_provider.dart';
import 'firebase_options.dart';
import 'features/client/providers/mood_provider.dart';
import 'core/providers/agora_provider.dart';
import 'core/providers/emotion_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()), // ← ADDED
        ChangeNotifierProvider(create: (_) => CoachesProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => AgoraProvider()),   // NEW
        ChangeNotifierProvider(create: (_) => EmotionProvider()), // NEW

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

      //testing the push
      // Testing Splash page:
      home: const OnboardingScreen(),
    );
  }
}


