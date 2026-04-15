import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/client/dashboard/providers/dashboard_provider.dart';
import 'features/client/widgets/client_nav_bar.dart';

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
        home: const ClientNavBar(),

        // Testing as COACH: wire your coach flow here.
      ),
    );
  }
}