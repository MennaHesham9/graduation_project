import 'package:flutter/material.dart';
import '../../../../core/widgets/app_nav_bar.dart';
import '../screens/client_home_screen.dart';
import '../screens/client_task_screen.dart';
import '../screens/client_goals_screen.dart';
import '../screens/client_sessions_screen.dart';
import '../screens/client_profile_screen.dart';

class ClientNavBar extends StatelessWidget {
  const ClientNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppNavBar(
      items: [
        NavItemData(icon: Icons.home_outlined, label: 'Home', screen: ClientHomeScreen()),
        NavItemData(icon: Icons.check_box_outlined, label: 'Tasks', screen: ClientTasksScreen()),
        NavItemData(icon: Icons.track_changes_outlined, label: 'Goals', screen: ClientGoalsScreen()),
        NavItemData(icon: Icons.videocam_outlined, label: 'Sessions', screen: MyCoachSessionsScreen()),
        NavItemData(icon: Icons.person_outline, label: 'Profile', screen: ClientProfileScreen()),
      ],
    );
  }
}