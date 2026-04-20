import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/screens/sign_in_screen.dart';

class ClientSettingsScreen extends StatelessWidget {
  const ClientSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: _buildBody(context),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(0.8),
      padding: const EdgeInsets.only(
        top: 48,
        left: 24,
        right: 24,
        bottom: 16,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: Color(0xFF101828),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF101828),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFAF5FF),
            Color(0xFFEFF6FF),
            Color(0xFFFDF2F8),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionLabel('Preferences'),
          const SizedBox(height: 12),
          _buildCard(
            children: [
              _buildSettingsRow(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                trailing: 'Enabled',
                hasDivider: true,
              ),
              _buildSettingsRow(
                icon: Icons.language_outlined,
                label: 'Language',
                trailing: 'English',
                hasDivider: true,
              ),
              _buildSettingsRow(
                icon: Icons.dark_mode_outlined,
                label: 'Dark Mode',
                trailing: 'Off',
                hasDivider: false,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionLabel('Privacy & Security'),
          const SizedBox(height: 12),
          _buildCard(
            children: [
              _buildSettingsRow(
                icon: Icons.lock_outline_rounded,
                label: 'Privacy Settings',
                hasDivider: true,
              ),
              _buildSettingsRow(
                icon: Icons.key_outlined,
                label: 'Change Password',
                hasDivider: false,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionLabel('Support'),
          const SizedBox(height: 12),
          _buildCard(
            children: [
              _buildSettingsRow(
                icon: Icons.help_outline_rounded,
                label: 'Help Center',
                hasDivider: true,
              ),
              _buildSettingsRow(
                icon: Icons.star_outline_rounded,
                label: 'Rate the App',
                hasDivider: false,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildAppInfoCard(),
          const SizedBox(height: 20),
          _buildLogoutButton(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF101828),
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required String label,
    String? trailing,
    required bool hasDivider,
    Color? labelColor,
  }) {
    return Container(
      height: hasDivider ? 57 : 56,
      decoration: hasDivider
          ? const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1),
        ),
      )
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: labelColor ?? const Color(0xFF101828),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: labelColor ?? const Color(0xFF101828),
              ),
            ),
          ),
          if (trailing != null) ...[
            Text(
              trailing,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6A7282),
              ),
            ),
            const SizedBox(width: 8),
          ],
          const Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: Color(0xFF6A7282),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        children: [
          SizedBox(height: 4),
          Text(
            'MindGrowth',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4A5565),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Version 1.0.0',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6A7282),
            ),
          ),
          SizedBox(height: 4),
          Text(
            '© 2025 MindGrowth. All rights reserved.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6A7282),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SignInScreen()),
        );
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              size: 20,
              color: Color(0xFFE7000B),
            ),
            SizedBox(width: 8),
            Text(
              'Log Out',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFFE7000B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}