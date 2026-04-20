import 'package:flutter/material.dart';
import 'package:gradproject/features/authentication/screens/sign_in_screen.dart';

void main() {
  runApp(const MindWellApp());
}

class MindWellApp extends StatelessWidget {
  const MindWellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindWell',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const MyProfileScreen(),
    );
  }
}

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  int _selectedNavIndex = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
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
        child: SafeArea(
          child: Column(
            children: [
              // ── SCROLLABLE CONTENT (header + cards overlap via Stack) ──
              Expanded(
                child: SingleChildScrollView(
                  child: Stack(
                    children: [
                      // Teal header behind everything
                      _buildProfileHeader(),

                      // Cards column — starts partway down the header so they overlap
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 340, 16, 16),
                        child: Column(
                          children: [
                            _buildPersonalInfoCard(),
                            const SizedBox(height: 16),
                            _buildQuickSettingsCard(),
                            const SizedBox(height: 16),
                            _buildStatsRow(),
                            const SizedBox(height: 16),
                            _buildLogOutButton(),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── BOTTOM NAV ──
              _buildBottomNav(),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // APP BAR
  // width:390, height:67.96, padding:10 top, 29.79 right, 29.73 left
  // bg:#FFFFFF, border:1px solid #BABABA1A
  // shadow: 0px 1px 3px #0000004D, 0px 4px 8px 3px #00000026

  // ─────────────────────────────────────────
  // PROFILE HEADER
  // ─────────────────────────────────────────
  // ── CONTAINER 1 ──
  // width:390, height:388, padding: 24 top, 34 left, 33 right, gap:24
  // border-bottom-left-radius:40, border-bottom-right-radius:40
  // background: linear-gradient(90deg, #2F8F9D 0%, #20A8BC 100%)
  // box-shadow: 0px 8px 10px -6px #0000001A, 0px 20px 25px -5px #0000001A
  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      height: 388,
      padding: const EdgeInsets.fromLTRB(34, 0, 33, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF2F8F9D), Color(0xFF20A8BC)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            spreadRadius: -6,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 25,
            spreadRadius: -5,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── App bar row inside header ──
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button — rounded square, white semi-transparent bg
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),

                const Text(
                  'My Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                // Edit icon — rounded square, white semi-transparent bg
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.edit_square,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Avatar: large rounded square with white padding ──
          Stack(
            clipBehavior: Clip.none,
            children: [
              // White padded rounded square frame
              Container(
                width: 140,
                height: 140,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.asset(
                    'assets/images/profile.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFD1D5DB),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 64,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ),
              ),

              // Edit badge — rounded square, bottom-right
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    size: 16,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Name
          const Text(
            'Sarah Johnson',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),

          const SizedBox(height: 6),

          // Member since
          const Text(
            'Member since Nov 2025',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  // ─────────────────────────────────────────
  // PERSONAL INFORMATION
  // ─────────────────────────────────────────
  Widget _buildPersonalInfoCard() {
    return _SectionCard(
      title: 'Personal Information',
      child: Column(
        children: const [
          _InfoRow(
            icon: Icons.mail_outline_rounded,
            iconColor: Color(0xFF8B5CF6),
            label: 'Email',
            value: 'sarah.johnson@example.com',
          ),
          _Divider(),
          _InfoRow(
            icon: Icons.phone_outlined,
            iconColor: Color(0xFF1EAABB),
            label: 'Phone',
            value: '+1 (555) 123-4567',
          ),
          _Divider(),
          _InfoRow(
            icon: Icons.location_on_outlined,
            iconColor: Color(0xFF22C55E),
            label: 'Location',
            value: 'San Francisco, CA',
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // QUICK SETTINGS
  // ─────────────────────────────────────────
  Widget _buildQuickSettingsCard() {
    final items = [
      {'icon': Icons.settings_outlined, 'label': 'Settings'},
      {'icon': Icons.notifications_outlined, 'label': 'Notifications'},
      {'icon': Icons.lock_outline_rounded, 'label': 'Privacy & Security'},
      {'icon': Icons.help_outline_rounded, 'label': 'Help & Support'},
    ];

    return _SectionCard(
      title: 'Quick Settings',
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Column(
            children: [
              GestureDetector(
                onTap: () {},
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  child: Row(
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        size: 20,
                        color: const Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          item['label'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1A1A2E),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: Color(0xFFD1D5DB),
                      ),
                    ],
                  ),
                ),
              ),
              if (i < items.length - 1)
                const _Divider(),
            ],
          );
        }),
      ),
    );
  }

  // Stats moved inside _buildProfileHeader()

  // ─────────────────────────────────────────
  // STATS ROW
  // ─────────────────────────────────────────
  Widget _buildStatsRow() {
    return Row(
      children: [
        _StatBox(value: '12', label: 'Sessions'),
        const SizedBox(width: 10),
        _StatBox(value: '8', label: 'Goals'),
        const SizedBox(width: 10),
        _StatBox(value: '45', label: 'Tasks Done'),
      ],
    );
  }

  // ─────────────────────────────────────────
  // LOG OUT
  // ─────────────────────────────────────────
  Widget _buildLogOutButton() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFFEF4444).withOpacity(0.25), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SignInScreen(),
            ),
          );
        },
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout_rounded,
                color: Color(0xFFEF4444), size: 18),
            SizedBox(width: 8),
            Text(
              'Log Out',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // BOTTOM NAV
  // ─────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.task_alt_rounded, 'label': 'Tasks'},
      {'icon': Icons.track_changes_rounded, 'label': 'Goals'},
      {'icon': Icons.video_camera_front_outlined, 'label': 'Sessions'},
      {'icon': Icons.person_rounded, 'label': 'Profile'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final selected = _selectedNavIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedNavIndex = i),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 64,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Active tab has teal circle bg
                      Container(
                        width: 40,
                        height: 30,
                        decoration: selected
                            ? BoxDecoration(
                          color: const Color(0xFF1EAABB),
                          borderRadius: BorderRadius.circular(20),
                        )
                            : null,
                        child: Icon(
                          items[i]['icon'] as IconData,
                          size: 20,
                          color: selected
                              ? Colors.white
                              : const Color(0xFFB0B8C1),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          color: selected
                              ? const Color(0xFF1EAABB)
                              : const Color(0xFFB0B8C1),
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────
// HEADER STAT (inside teal card)
// ─────────────────────────────────────────────────────────────────
class _HeaderStat extends StatelessWidget {
  final String value;
  final String label;

  const _HeaderStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _HeaderStatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white.withOpacity(0.3),
    );
  }
}
// ─────────────────────────────────────────────────────────────────
// SECTION CARD
// ─────────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9CA3AF),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// INFO ROW
// ─────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1A1A2E),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// DIVIDER
// ─────────────────────────────────────────────────────────────────
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 0.8,
      color: Color(0xFFF3F4F6),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// STAT BOX
// ─────────────────────────────────────────────────────────────────
class _StatBox extends StatelessWidget {
  final String value;
  final String label;

  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9CA3AF),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}