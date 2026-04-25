// lib/features/client/profile/edit_client_profile.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/profile_provider.dart';
import '../../../core/providers/auth_provider.dart';

class EditClientProfile extends StatefulWidget {
  const EditClientProfile({super.key});

  @override
  State<EditClientProfile> createState() => _EditClientProfileState();
}

class _EditClientProfileState extends State<EditClientProfile> {
  final _fullNameController = TextEditingController();
  final _emailController    = TextEditingController();
  final _phoneController    = TextEditingController();
  final _countryController  = TextEditingController();
  final _dobController      = TextEditingController();
  final _languageController = TextEditingController();
  final _timezoneController = TextEditingController();
  final _goalsController    = TextEditingController();

  bool _showPhotoToCoach     = true;
  bool _allowMoodTracking    = true;
  bool _allowSessionAnalysis = false;

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-fill fields from existing profile (runs once)
    if (!_initialized) {
      final profile = context.read<ProfileProvider>().profile;
      if (profile != null) {
        _fullNameController.text = profile.fullName;
        _emailController.text    = profile.email;
        _phoneController.text    = profile.phone;
        _countryController.text  = profile.country ?? '';
        _dobController.text      = profile.dateOfBirth ?? '';
        _languageController.text = profile.language ?? '';
        _timezoneController.text = profile.timezone ?? '';
        _goalsController.text    = profile.primaryGoal ?? '';
        _showPhotoToCoach        = profile.showPhotoToCoach;
        _allowMoodTracking       = profile.allowMoodTracking;
        _allowSessionAnalysis    = profile.allowSessionAnalysis;
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _dobController.dispose();
    _languageController.dispose();
    _timezoneController.dispose();
    _goalsController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final profileProvider = context.read<ProfileProvider>();

    final success = await profileProvider.updateProfile(
      fullName:             _fullNameController.text,
      phone:                _phoneController.text,
      country:              _countryController.text,
      dateOfBirth:          _dobController.text,
      language:             _languageController.text,
      timezone:             _timezoneController.text,
      primaryGoal:          _goalsController.text,
      showPhotoToCoach:     _showPhotoToCoach,
      allowMoodTracking:    _allowMoodTracking,
      allowSessionAnalysis: _allowSessionAnalysis,
    );

    if (!mounted) return;
    await context.read<AuthProvider>().refreshUser();
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(profileProvider.errorMessage ?? 'Failed to save.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<ProfileProvider>().isSaving;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: const Color(0xFFE2E8F0),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF1A2533)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Edit Profile',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A2533))),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: isSaving ? null : _saveChanges,
            child: isSaving
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('Save',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Avatar ───────────────────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Consumer<ProfileProvider>(
                        builder: (context, pp, _) {
                          final photoUrl = pp.profile?.photoUrl;
                          final initials = pp.profile?.initials ?? '?';
                          return CircleAvatar(
                            radius: 38,
                            backgroundColor: const Color(0xFF7EC8D3),
                            backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                                ? NetworkImage(photoUrl) as ImageProvider
                                : null,
                            child: (photoUrl == null || photoUrl.isEmpty)
                                ? Text(initials,
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white))
                                : null,
                          );
                        },
                      ),
                      Container(
                        width: 26, height: 26,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded, size: 13, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      // TODO: implement photo picker
                    },
                    child: Text('Change photo',
                        style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Personal Information ─────────────────────────────────────────
            _SectionLabel(text: 'Personal Information'),
            const SizedBox(height: 12),
            _EditCard(
              child: Column(
                children: [
                  _EditField(label: 'Full Name', controller: _fullNameController),
                  _EditField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    helperText: '✓ Verified email. Contact support to change.',
                    enabled: false,
                  ),
                  _EditField(label: 'Phone Number', controller: _phoneController, keyboardType: TextInputType.phone),
                  _EditField(label: 'Country', controller: _countryController),
                  _EditField(
                    label: 'Date of Birth (Optional)',
                    controller: _dobController,
                    keyboardType: TextInputType.datetime,
                    helperText: '🔒 Your privacy is important. This is only visible to you.',
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Preferences ──────────────────────────────────────────────────
            _SectionLabel(text: 'Preferences'),
            const SizedBox(height: 12),
            _EditCard(
              child: Column(
                children: [
                  _EditField(label: 'Language', controller: _languageController),
                  _EditField(
                    label: 'Time Zone',
                    controller: _timezoneController,
                    helperText: '🌐 Auto-detected, but you can change it here.',
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: const [
                          Expanded(
                            child: Text('Notification Preferences',
                                style: TextStyle(fontSize: 14, color: Color(0xFF1A2533), fontWeight: FontWeight.w500)),
                          ),
                          Icon(Icons.chevron_right, size: 18, color: Color(0xFFB0BEC5)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Personal Goals ───────────────────────────────────────────────
            _SectionLabel(text: 'Personal Goals'),
            const SizedBox(height: 4),
            const Text(
              'Share what you\'re currently working on. This helps personalize your coaching experience.',
              style: TextStyle(fontSize: 12, color: Color(0xFF9EABB8)),
            ),
            const SizedBox(height: 12),
            _EditCard(
              child: TextField(
                controller: _goalsController,
                maxLines: 4,
                style: const TextStyle(fontSize: 14, color: Color(0xFF1A2533)),
                decoration: const InputDecoration(
                  hintText: 'What are you currently working on?',
                  hintStyle: TextStyle(fontSize: 13, color: Color(0xFFB0BEC5)),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Privacy & Visibility ─────────────────────────────────────────
            _SectionLabel(text: 'Privacy & Visibility'),
            const SizedBox(height: 12),
            _EditCard(
              child: Column(
                children: [
                  _ToggleRow(
                    title: 'Show profile photo to coach',
                    subtitle: 'Your coach can see your profile picture',
                    value: _showPhotoToCoach,
                    onChanged: (v) => setState(() => _showPhotoToCoach = v),
                  ),
                  const Divider(height: 20, color: Color(0xFFF0F4F8)),
                  _ToggleRow(
                    title: 'Allow mood tracking insights',
                    subtitle: 'Share mood data with your coach',
                    value: _allowMoodTracking,
                    onChanged: (v) => setState(() => _allowMoodTracking = v),
                  ),
                  const Divider(height: 20, color: Color(0xFFF0F4F8)),
                  _ToggleRow(
                    title: 'Allow session emotion analysis',
                    subtitle: 'AI-powered insights during sessions',
                    value: _allowSessionAnalysis,
                    onChanged: (v) => setState(() => _allowSessionAnalysis = v),
                    showInfo: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Save Button ──────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isSaving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: isSaving
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Cancel',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF5A6A7A))),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REUSABLE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A2533)));
}

class _EditCard extends StatelessWidget {
  final Widget child;
  const _EditCard({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: child,
    );
  }
}

class _EditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? helperText;
  final bool enabled;
  final bool isLast;

  const _EditField({
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.helperText,
    this.enabled = true,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5A6A7A))),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            enabled: enabled,
            style: TextStyle(fontSize: 14, color: enabled ? const Color(0xFF1A2533) : const Color(0xFF9EABB8)),
            decoration: InputDecoration(
              filled: true,
              fillColor: enabled ? const Color(0xFFF8FAFC) : const Color(0xFFF0F4F8),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFEDF0F3))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
            ),
          ),
          if (helperText != null) ...[
            const SizedBox(height: 5),
            Text(helperText!,
                style: TextStyle(fontSize: 11, color: enabled ? AppColors.primary : const Color(0xFF9EABB8))),
          ],
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showInfo;

  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.showInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(title,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A2533))),
                  if (showInfo) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.info_outline, size: 14, color: Color(0xFFB0BEC5)),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF9EABB8))),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _Toggle(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _Toggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _Toggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 46, height: 26,
        decoration: BoxDecoration(
          color: value ? AppColors.primary : const Color(0xFFD1D9E0),
          borderRadius: BorderRadius.circular(13),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20, height: 20,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}