import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class NavItemData {
  final IconData icon;
  final String label;
  final Widget screen;

  const NavItemData({
    required this.icon,
    required this.label,
    required this.screen,
  });
}

class AppNavBar extends StatefulWidget {
  final List<NavItemData> items;

  const AppNavBar({
    super.key,
    required this.items,
  });

  @override
  State<AppNavBar> createState() => _AppNavBarState();
}

class _AppNavBarState extends State<AppNavBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: widget.items.map((e) => e.screen).toList(),
      ),
      bottomNavigationBar: SafeArea(
        child: _BottomBar(
          items: widget.items,
          selectedIndex: _selectedIndex,
          onItemTapped: (i) => setState(() => _selectedIndex = i),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final List<NavItemData> items;
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const _BottomBar({
    required this.items,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(50)),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.navUnselected,
          selectedLabelStyle:   const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          elevation: 0,
          items: items.map((e) => BottomNavigationBarItem(
            label: e.label,
            icon: _NavIcon(icon: e.icon, active: false),
            activeIcon: _NavIcon(icon: e.icon, active: true),
          )).toList(),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool active;

  const _NavIcon({required this.icon, required this.active});

  @override
  Widget build(BuildContext context) {
    if (!active) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Icon(icon, size: 27),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Container(
        width: 46,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 25, color: Colors.white),
      ),
    );
  }
}