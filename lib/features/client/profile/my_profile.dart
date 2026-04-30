import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/widgets/user_photo.dart';
import '../../authentication/screens/sign_in_screen.dart';
import 'client_settings_screen.dart';
import 'edit_client_profile.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch profile on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchProfile();
    });
  }

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
          child: Consumer<ProfileProvider>(
            builder: (context, profileProvider, _) {
              final profile = profileProvider.profile;
              final isLoading = profileProvider.isLoading;

              return Column(
                children: [
                  Expanded(
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF2F8F9D),
                            ),
                          )
                        : SingleChildScrollView(
                            child: Stack(
                              children: [
                                _buildProfileHeader(context, profile),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 340, 16, 16),
                                  child: Column(
                                    children: [
                                      _buildPersonalInfoCard(profile),
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
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // PROFILE HEADER  (dynamic)
  // ─────────────────────────────────────────
  Widget _buildProfileHeader(BuildContext context, dynamic profile) {
    final String displayName = profile?.fullName ?? 'Loading...';
    final String memberLabel = profile?.memberSinceLabel ?? '';
    final String? photoUrl = profile?.photoUrl as String?;
    final String initials = profile?.initials ?? '';

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
          BoxShadow(color: Color(0x1A000000), blurRadius: 10, spreadRadius: -6, offset: Offset(0, 8)),
          BoxShadow(color: Color(0x1A000000), blurRadius: 25, spreadRadius: -5, offset: Offset(0, 20)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
                  ),
                ),
                const Text('My Profile',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditClientProfile()),
                    );
                    // Refresh profile data after returning from edit
                    if (mounted) context.read<ProfileProvider>().fetchProfile();
                  },
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.edit_square, size: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 140, height: 140,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: UserPhoto.square(
                    photoUrl: photoUrl,
                    initials: initials,
                    size: 128,
                    borderRadius: 22,
                    backgroundColor: const Color(0xFF7EC8D3),
                    initialsStyle: const TextStyle(
                        fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
              Positioned(
                bottom: -2, right: -2,
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: const Icon(Icons.edit_rounded, size: 16, color: Color(0xFF6B7280)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(displayName,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: 0.2)),

          const SizedBox(height: 6),

          if (memberLabel.isNotEmpty)
            Text(memberLabel,
                style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildInitialsAvatar(String initials) {
    return Container(
      color: const Color(0xFF7EC8D3),
      alignment: Alignment.center,
      child: Text(
        initials.isNotEmpty ? initials : '?',
        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white),
      ),
    );
  }

  // ─────────────────────────────────────────
  // PERSONAL INFORMATION  (dynamic)
  // ─────────────────────────────────────────
  Widget _buildPersonalInfoCard(dynamic profile) {
    final String email = profile?.email ?? '—';
    final String phone = (profile?.phone != null && (profile!.phone as String).isNotEmpty) ? profile.phone : '—';
    final String location = (profile?.country != null && (profile!.country as String).isNotEmpty) ? profile.country! : '—';

    return _SectionCard(
      title: 'Personal Information',
      child: Column(
        children: [
          _InfoRow(icon: Icons.mail_outline_rounded, iconColor: const Color(0xFF8B5CF6), label: 'Email', value: email),
          const _Divider(),
          _InfoRow(icon: Icons.phone_outlined, iconColor: const Color(0xFF1EAABB), label: 'Phone', value: phone),
          const _Divider(),
          _InfoRow(icon: Icons.location_on_outlined, iconColor: const Color(0xFF22C55E), label: 'Location', value: location),
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
                onTap: () {
                  if (item['label'] == 'Settings') {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const Scaffold(body: ClientSettingsScreen())));
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  child: Row(
                    children: [
                      Icon(item['icon'] as IconData, size: 20, color: const Color(0xFF6B7280)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(item['label'] as String,
                            style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E), fontWeight: FontWeight.w400)),
                      ),
                      const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFFD1D5DB)),
                    ],
                  ),
                ),
              ),
              if (i < items.length - 1) const _Divider(),
            ],
          );
        }),
      ),
    );
  }

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
        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.25), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: TextButton(
        onPressed: () async {
          await context.read<AuthProvider>().signOut();
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const SignInScreen()),
            (route) => false,
          );
        },
        style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 18),
            SizedBox(width: 8),
            Text('Log Out', style: TextStyle(color: Color(0xFFEF4444), fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REUSABLE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF), letterSpacing: 0.3)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.iconColor, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 16, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w400)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 16, color: Color(0xFF1A1A2E), fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 0.8, color: Color(0xFFF3F4F6));
}

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
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}