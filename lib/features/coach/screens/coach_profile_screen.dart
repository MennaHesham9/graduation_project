// lib/features/coach/screens/coach_profile_screen.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../authentication/screens/sign_in_screen.dart';
import 'edit_coach_profile_screen.dart';

class CoachProfileScreen extends StatelessWidget {
  const CoachProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────
              _SectionHeader(),
              const SizedBox(height: 12),

              // ── Profile Card ─────────────────────────────────────
              _ProfileCard(),
              const SizedBox(height: 16),

              // ── About Me ─────────────────────────────────────────
              _AboutMeCard(),
              const SizedBox(height: 16),

              // ── Professional Information ──────────────────────────
              _ProfessionalInfoCard(),
              const SizedBox(height: 16),

              // ── Certifications & Credentials ─────────────────────
              _CertificationsCard(),
              const SizedBox(height: 16),

              // ── Session & Pricing ─────────────────────────────────
              _SessionPricingCard(),
              const SizedBox(height: 16),

              // ── Availability ──────────────────────────────────────
              _AvailabilityCard(),
              const SizedBox(height: 16),

              // ── Your Performance ──────────────────────────────────
              _PerformanceCard(),
              const SizedBox(height: 16),

              // ── Account & Settings ────────────────────────────────
              _AccountSettingsCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'My Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A2533),
          ),
        ),
        Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile Card
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3A9BAD), Color(0xFF2F8F9D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 34,
            backgroundColor: const Color(0xFF5BB8C9),
            child: const Text(
              'DR',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Name
          const Text(
            'Dr. Rebecca Martinez',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),

          // Title
          const Text(
            'Life & Career Coach',
            style: TextStyle(fontSize: 13, color: Color(0xFFD4EEF2)),
          ),
          const SizedBox(height: 8),

          // Stars + reviews
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(
                4,
                    (_) => const Icon(Icons.star, size: 14, color: Colors.amber),
              ),
              const Icon(Icons.star_half, size: 14, color: Colors.amber),
              const SizedBox(width: 6),
              const Text(
                '4.9 (127 reviews)',
                style: TextStyle(fontSize: 12, color: Color(0xFFD4EEF2)),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Verified badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.verified_outlined, size: 14, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'Verified Coach',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Status row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Status',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
                const SizedBox(width: 10),
                _StatusToggle(),
                const SizedBox(width: 6),
                const Text(
                  'Available',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusToggle extends StatefulWidget {
  @override
  State<_StatusToggle> createState() => _StatusToggleState();
}

class _StatusToggleState extends State<_StatusToggle> {
  bool _available = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _available = !_available),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 20,
        decoration: BoxDecoration(
          color: _available ? const Color(0xFF4CAF50) : Colors.grey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment:
          _available ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// About Me Card
// ─────────────────────────────────────────────────────────────────────────────
class _AboutMeCard extends StatefulWidget {
  @override
  State<_AboutMeCard> createState() => _AboutMeCardState();
}

class _AboutMeCardState extends State<_AboutMeCard> {
  bool _expanded = false;

  static const _fullText =
      "I'm a certified life coach with a passion for helping individuals unlock their full potential "
      "and create meaningful, lasting change. My coaching approach is rooted in evidence-based "
      "techniques including CBT, mindfulness, and positive psychology. I specialize in career "
      "transitions, goal-setting, and building resilience.";

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      title: 'About Me',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _expanded ? _fullText : '${_fullText.substring(0, 120)}...',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF5A6A7A),
              height: 1.55,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Text(
              _expanded ? 'Show Less' : 'Read More',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Professional Information Card
// ─────────────────────────────────────────────────────────────────────────────
class _ProfessionalInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      title: 'Professional Information',
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.workspace_premium_outlined,
            label: 'Experience',
            content: const Text(
              '8+ years',
              style: TextStyle(fontSize: 13, color: Color(0xFF1A2533)),
            ),
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.category_outlined,
            label: 'Coaching Categories',
            content: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: const [
                _Chip('Life Coaching'),
                _Chip('Career'),
                _Chip('Relationships'),
                _Chip('Mindfulness'),
                _Chip('Goal Setting'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.language_outlined,
            label: 'Languages',
            content: const Text(
              'English, Spanish',
              style: TextStyle(fontSize: 13, color: Color(0xFF1A2533)),
            ),
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Location & Time Zone',
            content: const Text(
              'United States, EST (UTC-5)',
              style: TextStyle(fontSize: 13, color: Color(0xFF1A2533)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Certifications & Credentials Card
// ─────────────────────────────────────────────────────────────────────────────
class _CertificationsCard extends StatelessWidget {
  static const _certs = [
    'ICF Certified Professional Coach',
    'Mental Health First Aid',
    'CBT Practitioner Certificate',
  ];

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      title: 'Certifications & Credentials',
      child: Column(
        children: _certs
            .map(
              (cert) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5F7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.workspace_premium_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cert,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A2533),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.check_circle,
                              size: 12, color: AppColors.primary),
                          const SizedBox(width: 3),
                          Text(
                            'Verified',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'View',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
            .toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Session & Pricing Card
// ─────────────────────────────────────────────────────────────────────────────
class _SessionPricingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      title: 'Session & Pricing',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This is what clients see when booking.',
            style: TextStyle(fontSize: 12, color: Color(0xFF9EABB8)),
          ),
          const SizedBox(height: 12),
          _PricingRow(
            icon: Icons.access_time_outlined,
            label: 'Session Duration',
            value: '50 minutes',
          ),
          const SizedBox(height: 10),
          _PricingRow(
            icon: Icons.videocam_outlined,
            label: 'Video Session',
            value: '\$120 / session',
          ),
          const SizedBox(height: 10),
          _PricingRow(
            icon: Icons.headset_mic_outlined,
            label: 'Audio Session',
            value: '\$100 / session',
          ),
          const SizedBox(height: 10),
          _PricingRow(
            icon: Icons.inventory_2_outlined,
            label: 'Package (4 sessions)',
            value: '\$440',
          ),
        ],
      ),
    );
  }
}

class _PricingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _PricingRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9EABB8)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF5A6A7A)),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A2533),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Availability Card
// ─────────────────────────────────────────────────────────────────────────────
class _AvailabilityCard extends StatefulWidget {
  @override
  State<_AvailabilityCard> createState() => _AvailabilityCardState();
}

class _AvailabilityCardState extends State<_AvailabilityCard> {
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final Set<String> _selected = {'Tue', 'Wed', 'Thu', 'Fri'};

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      title: 'Availability',
      trailing: Icon(Icons.calendar_today_outlined,
          size: 16, color: AppColors.primary),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _days
                .map(
                  (day) => GestureDetector(
                onTap: () => setState(() {
                  if (_selected.contains(day)) {
                    _selected.remove(day);
                  } else {
                    _selected.add(day);
                  }
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _selected.contains(day)
                        ? AppColors.primary
                        : const Color(0xFFF0F4F8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _selected.contains(day)
                          ? Colors.white
                          : const Color(0xFF9EABB8),
                    ),
                  ),
                ),
              ),
            )
                .toList(),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Manage Availability',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Performance Card
// ─────────────────────────────────────────────────────────────────────────────
class _PerformanceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3A9BAD), Color(0xFF2F8F9D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Performance',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _StatItem(icon: Icons.people_outline, value: '42', label: 'Total\nClients'),
              _StatDivider(),
              _StatItem(icon: Icons.check_circle_outline, value: '238', label: 'Sessions\nDone'),
              _StatDivider(),
              _StatItem(icon: Icons.star_outline, value: '4.9', label: 'Avg\nRating'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFFD4EEF2),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 1,
      color: Colors.white.withOpacity(0.25),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Account & Settings Card
// ─────────────────────────────────────────────────────────────────────────────
class _AccountSettingsCard extends StatelessWidget {
  static const _items = [
    _SettingsItem(icon: Icons.edit_outlined, label: 'Edit Profile', isLogout: false),
    _SettingsItem(icon: Icons.notifications_outlined, label: 'Notification Settings', isLogout: false),
    _SettingsItem(icon: Icons.account_balance_wallet_outlined, label: 'Wallet & Payments', isLogout: false),
    _SettingsItem(icon: Icons.lock_outline, label: 'Privacy & Security', isLogout: false),
  ];

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      title: 'Account & Settings',
      child: Column(
        children: [
          ..._items.map((item) => _SettingsTile(item: item)),
          const Divider(height: 1, color: Color(0xFFF0F4F8)),
          _SettingsTile(
            item: const _SettingsItem(
              icon: Icons.logout,
              label: 'Logout',
              isLogout: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String label;
  final bool isLogout;
  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.isLogout,
  });
}

class _SettingsTile extends StatelessWidget {
  final _SettingsItem item;
  const _SettingsTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = item.isLogout ? Colors.red : const Color(0xFF1A2533);
    return InkWell(
      onTap: () {
        if (item.isLogout) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const SignInScreen()),
                (route) => false, // clears the entire back stack
          );
        } else if (item.label == 'Edit Profile') {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const EditCoachProfileScreen()),
          );
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            Icon(item.icon, size: 20, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (!item.isLogout)
              const Icon(Icons.chevron_right, size: 18, color: Color(0xFFB0BEC5)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared White Card wrapper
// ─────────────────────────────────────────────────────────────────────────────
class _WhiteCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _WhiteCard({
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A2533),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared Info Row
// ─────────────────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget content;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: const Color(0xFF9EABB8)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9EABB8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              content,
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chip
// ─────────────────────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}