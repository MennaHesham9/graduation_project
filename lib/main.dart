// lib/main.dart
//
// FIX: Removed AgoraProvider and EmotionProvider from the global MultiProvider.
//
// These providers must NOT be global because:
//   • The coach and client each open their own session screen on separate
//     devices — they must have independent engine instances.
//   • If both are registered globally, initAndJoin() from one screen
//     overwrites the other's remoteUid and connection state, causing both
//     screens to permanently show "Waiting for..." or see the wrong video.
//
// Each session screen now creates its own scoped providers via the static
// route() factory:
//   • VideoSessionScreen.route(...)          — coach screen
//   • ClientVideoSessionScreen.route(...)    — client screen

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
// AgoraProvider and EmotionProvider intentionally NOT imported here.
// They are scoped inside VideoSessionScreen.route() and
// ClientVideoSessionScreen.route() respectively.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => CoachesProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        // ← AgoraProvider removed (scoped per session screen)
        // ← EmotionProvider removed (scoped per session screen)
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

      // Testing as COACH:
      //home: const CoachNavBar(),

      // Testing Mood Tracking page:
      //home: const MoodTrackingScreen(),

      // Testing notification page:
      //home: const NotificationScreen(),

      // Testing Pre-session Questionnaire page:
      //home: const PresessionQuestionnaireScreen(),

      // Testing CoachProfileClientSide page:
      //home: const CoachProfileClientSide(),

      home: const OnboardingScreen(),
    );
  }
}