// lib/features/coach/screens/coach_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../authentication/screens/sign_in_screen.dart';
import 'edit_coach_profile_screen.dart';
import '../../../../core/widgets/user_photo.dart';

class CoachProfileScreen extends StatelessWidget {
  const CoachProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(user: user),
              const SizedBox(height: 12),
              _ProfileCard(user: user),
              const SizedBox(height: 16),
              _AboutMeCard(user: user),
              const SizedBox(height: 16),
              _ProfessionalInfoCard(user: user),
              const SizedBox(height: 16),
              _CertificationsCard(),
              const SizedBox(height: 16),
              _SessionPricingCard(user: user),
              const SizedBox(height: 16),
              _AvailabilityCard(user: user),
              const SizedBox(height: 16),
              _PerformanceCard(),
              const SizedBox(height: 16),
              _AccountSettingsCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final UserModel user;
  const _SectionHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'My Profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A2533)),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const EditCoachProfileScreen()),
          ),
          child: Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
        ),
      ],
    );
  }
}

// ── Profile Card ──────────────────────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  final UserModel user;
  const _ProfileCard({required this.user});

  String get _initials {
    final parts = user.fullName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?';
  }

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
          UserPhoto(
            photoUrl: user.photoUrl,
            initials: _initials,
            radius: 34,
            backgroundColor: const Color(0xFF5BB8C9),
          ),
          const SizedBox(height: 10),
          Text(
            user.fullName,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 2),
          Text(
            user.professionalTitle ?? user.coachingCategory ?? 'Coach',
            style: const TextStyle(fontSize: 13, color: Color(0xFFD4EEF2)),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.verified_outlined, size: 14, color: Colors.white),
                SizedBox(width: 4),
                Text('Verified Coach', style: TextStyle(fontSize: 12, color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Status', style: TextStyle(fontSize: 12, color: Colors.white)),
                const SizedBox(width: 10),
                _StatusToggle(initialValue: user.isAvailable ?? true),
                const SizedBox(width: 6),
                Text(
                  (user.isAvailable ?? true) ? 'Available' : 'Unavailable',
                  style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
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
  final bool initialValue;
  const _StatusToggle({required this.initialValue});

  @override
  State<_StatusToggle> createState() => _StatusToggleState();
}

class _StatusToggleState extends State<_StatusToggle> {
  late bool _available;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _available = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _saving
          ? null // prevent double-tap while saving
          : () async {
        final newValue = !_available;
        setState(() {
          _available = newValue;
          _saving = true;
        });

        await context
            .read<AuthProvider>()
            .updateProfile({'isAvailable': newValue});

        // ✅ refresh AuthProvider so the whole screen reflects the change
        await context.read<AuthProvider>().refreshUser();

        if (mounted) setState(() => _saving = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 20,
        decoration: BoxDecoration(
          color: _saving
              ? Colors.grey.shade400      // grey while saving
              : (_available ? const Color(0xFF4CAF50) : Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: _saving
            ? const Padding(
          padding: EdgeInsets.all(3),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : AnimatedAlign(
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

// ── About Me Card ─────────────────────────────────────────────────────────────
class _AboutMeCard extends StatefulWidget {
  final UserModel user;
  const _AboutMeCard({required this.user});

  @override
  State<_AboutMeCard> createState() => _AboutMeCardState();
}

class _AboutMeCardState extends State<_AboutMeCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final fullText = widget.user.bio ?? 'No bio added yet. Tap Edit Profile to add one.';
    final preview = fullText.length > 120 ? '${fullText.substring(0, 120)}...' : fullText;

    return _WhiteCard(
      title: 'About Me',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _expanded ? fullText : preview,
            style: const TextStyle(fontSize: 13, color: Color(0xFF5A6A7A), height: 1.55),
          ),
          if (fullText.length > 120) ...[
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Text(
                _expanded ? 'Show Less' : 'Read More',
                style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Professional Information Card ─────────────────────────────────────────────
class _ProfessionalInfoCard extends StatelessWidget {
  final UserModel user;
  const _ProfessionalInfoCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final categories = user.coachingCategories?.isNotEmpty == true
        ? user.coachingCategories!
        : (user.coachingCategory != null ? [user.coachingCategory!] : <String>[]);
    final languages = user.languages ?? [];

    return _WhiteCard(
      title: 'Professional Information',
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.workspace_premium_outlined,
            label: 'Experience',
            content: Text(
              user.yearsOfExperience != null ? '${user.yearsOfExperience} years' : '—',
              style: const TextStyle(fontSize: 13, color: Color(0xFF1A2533)),
            ),
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.category_outlined,
            label: 'Coaching Categories',
            content: categories.isEmpty
                ? const Text('—', style: TextStyle(fontSize: 13, color: Color(0xFF1A2533)))
                : Wrap(
              spacing: 6, runSpacing: 6,
              children: categories.map((c) => _Chip(c)).toList(),
            ),
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.language_outlined,
            label: 'Languages',
            content: Text(
              languages.isNotEmpty ? languages.join(', ') : '—',
              style: const TextStyle(fontSize: 13, color: Color(0xFF1A2533)),
            ),
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Location & Time Zone',
            content: Text(
              [user.coachCountry, user.timezone].where((e) => e != null && e.isNotEmpty).join(', ').isNotEmpty
                  ? [user.coachCountry, user.timezone].where((e) => e != null && e.isNotEmpty).join(', ')
                  : '—',
              style: const TextStyle(fontSize: 13, color: Color(0xFF1A2533)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Session & Pricing Card ────────────────────────────────────────────────────
class _SessionPricingCard extends StatelessWidget {
  final UserModel user;
  const _SessionPricingCard({required this.user});

  String _fmt(double? val) =>
      val != null ? '${user.currency ?? '\$'}${val.toStringAsFixed(0)}' : '—';

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      title: 'Session & Pricing',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('This is what clients see when booking.',
              style: TextStyle(fontSize: 12, color: Color(0xFF9EABB8))),
          const SizedBox(height: 12),
          _PricingRow(
            icon: Icons.access_time_outlined,
            label: 'Session Duration',
            value: user.sessionDuration != null ? '${user.sessionDuration} minutes' : '—',
          ),
          const SizedBox(height: 10),
          _PricingRow(icon: Icons.videocam_outlined, label: 'Video Session', value: '${_fmt(user.videoPrice)} / session'),
          const SizedBox(height: 10),
          _PricingRow(icon: Icons.headset_mic_outlined, label: 'Audio Session', value: '${_fmt(user.audioPrice)} / session'),
          const SizedBox(height: 10),
          _PricingRow(icon: Icons.inventory_2_outlined, label: 'Package (4 sessions)', value: _fmt(user.packagePrice)),
        ],
      ),
    );
  }
}

// ── Availability Card (unchanged logic, but reads isAvailable) ────────────────
class _AvailabilityCard extends StatefulWidget {
  final UserModel user;
  const _AvailabilityCard({required this.user});

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
      trailing: Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.primary),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _days.map((day) => GestureDetector(
              onTap: () => setState(() =>
              _selected.contains(day) ? _selected.remove(day) : _selected.add(day)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: _selected.contains(day) ? AppColors.primary : const Color(0xFFF0F4F8),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(day,
                    style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: _selected.contains(day) ? Colors.white : const Color(0xFF9EABB8),
                    )),
              ),
            )).toList(),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity, height: 44,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Manage Availability', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Performance, Certifications, AccountSettings — unchanged, paste yours here ─
// (keeping them short below for brevity)

class _CertificationsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final certs = user?.certifications ?? [];

    if (certs.isEmpty) {
      return _WhiteCard(
        title: 'Certifications & Credentials',
        child: const Text(
          'No certifications added yet. Tap Edit Profile to upload.',
          style: TextStyle(fontSize: 13, color: Color(0xFF9EABB8)),
        ),
      );
    }

    return _WhiteCard(
      title: 'Certifications & Credentials',
      child: Column(
        children: certs.map((cert) {
          final name = cert['name'] as String? ?? 'Certificate';
          final status = cert['status'] as String? ?? 'Pending';
          final sizeLabel = cert['sizeLabel'] as String? ?? '';
          final isVerified = status == 'Verified';
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(color: const Color(0xFFE8F5F7), borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.picture_as_pdf_outlined, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A2533))),
                  Row(children: [
                    Icon(
                      isVerified ? Icons.check_circle : Icons.access_time_rounded,
                      size: 12,
                      color: isVerified ? AppColors.primary : Colors.orange,
                    ),
                    const SizedBox(width: 3),
                    Text(status, style: TextStyle(fontSize: 11, color: isVerified ? AppColors.primary : Colors.orange)),
                    if (sizeLabel.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text('· $sizeLabel', style: const TextStyle(fontSize: 11, color: Color(0xFF9EABB8))),
                    ],
                  ]),
                ])),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF3A9BAD), Color(0xFF2F8F9D)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Your Performance',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: const [
          _StatItem(icon: Icons.people_outline, value: '42', label: 'Total\nClients'),
          _StatDivider(),
          _StatItem(icon: Icons.check_circle_outline, value: '238', label: 'Sessions\nDone'),
          _StatDivider(),
          _StatItem(icon: Icons.star_outline, value: '4.9', label: 'Avg\nRating'),
        ]),
      ]),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon; final String value; final String label;
  const _StatItem({required this.icon, required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Column(children: [
    Icon(icon, color: Colors.white, size: 22), const SizedBox(height: 6),
    Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
    const SizedBox(height: 2),
    Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Color(0xFFD4EEF2), height: 1.4)),
  ]);
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();
  @override
  Widget build(BuildContext context) =>
      Container(height: 50, width: 1, color: Colors.white.withValues(alpha: 0.25));
}

class _AccountSettingsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      title: 'Account & Settings',
      child: Column(children: [
        _SettingsTile(icon: Icons.edit_outlined, label: 'Edit Profile', onTap: () =>
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditCoachProfileScreen()))),
        _SettingsTile(icon: Icons.notifications_outlined, label: 'Notification Settings', onTap: () {}),
        _SettingsTile(icon: Icons.account_balance_wallet_outlined, label: 'Wallet & Payments', onTap: () {}),
        _SettingsTile(icon: Icons.lock_outline, label: 'Privacy & Security', onTap: () {}),
        const Divider(height: 1, color: Color(0xFFF0F4F8)),
        _SettingsTile(
          icon: Icons.logout, label: 'Logout', color: Colors.red,
          onTap: () async {
            await context.read<AuthProvider>().signOut();
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const SignInScreen()), (r) => false);
            }
          },
        ),
      ]),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  final Color? color;
  const _SettingsTile({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF1A2533);
    return InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(children: [
          Icon(icon, size: 20, color: c), const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(fontSize: 14, color: c, fontWeight: FontWeight.w500))),
          if (color == null) const Icon(Icons.chevron_right, size: 18, color: Color(0xFFB0BEC5)),
        ]),
      ),
    );
  }
}

// ── Shared Widgets ────────────────────────────────────────────────────────────
class _WhiteCard extends StatelessWidget {
  final String title; final Widget child; final Widget? trailing;
  const _WhiteCard({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A2533))),
        if (trailing != null) trailing!,
      ]),
      const SizedBox(height: 12), child,
    ]),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon; final String label; final Widget content;
  const _InfoRow({required this.icon, required this.label, required this.content});

  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, size: 17, color: const Color(0xFF9EABB8)), const SizedBox(width: 10),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9EABB8), fontWeight: FontWeight.w500)),
      const SizedBox(height: 4), content,
    ])),
  ]);
}

class _PricingRow extends StatelessWidget {
  final IconData icon; final String label; final String value;
  const _PricingRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 16, color: const Color(0xFF9EABB8)), const SizedBox(width: 8),
    Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF5A6A7A)))),
    Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A2533))),
  ]);
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: const Color(0xFFE8F5F7), borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
  );
}