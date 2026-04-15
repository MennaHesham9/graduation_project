import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/client/booking/screens/select_plan_screen.dart';
import 'features/client/dashboard/providers/dashboard_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: MaterialApp(
        title: 'My App',
        debugShowCheckedModeBanner: false,

        // Testing as CLIENT:
        home: const SelectPlanScreen(),

        // Testing as COACH: wire your coach flow here.
      ),
    );
  }
}