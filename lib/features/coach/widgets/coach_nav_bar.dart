import 'package:flutter/material.dart';
import '../../../../core/widgets/app_nav_bar.dart';
import '../screens/coach_home_screen.dart';
import '../screens/coach_calandar_screen.dart';
import '../screens/coach_clients_screen.dart';
import '../screens/coach_wallet_screen.dart';
import '../screens/coach_profile_screen.dart';

class CoachNavBar extends StatelessWidget {
  const CoachNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppNavBar(
      items: [
        NavItemData(icon: Icons.home_outlined, label: 'Home', screen: CoachHomeScreen()),
        NavItemData(icon: Icons.calendar_today_outlined, label: 'Calendar', screen: CoachCalendarScreen()),
        NavItemData(icon: Icons.group_outlined, label: 'Clients',  screen: CoachClientsScreen()),
        NavItemData(icon: Icons.account_balance_wallet_outlined, label: 'Wallet', screen: CoachWalletScreen()),
        NavItemData(icon: Icons.person_outline, label: 'Profile', screen: CoachProfileScreen()),
      ],
    );
  }
}