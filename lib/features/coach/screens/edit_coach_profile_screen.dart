// lib/features/coach/screens/edit_coach_profile_screen.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'coach_profile_screen.dart';

class EditCoachProfileScreen extends StatefulWidget {
  const EditCoachProfileScreen({super.key});

  @override
  State<EditCoachProfileScreen> createState() => _EditCoachProfileScreenState();
}

class _EditCoachProfileScreenState extends State<EditCoachProfileScreen> {
  // ── Controllers ───────────────────────────────────────────────────────────
  final _fullNameController       = TextEditingController(text: 'Dr. Rebecca Martinez');
  final _titleController          = TextEditingController(text: 'Life & Career Coach');
  final _emailController          = TextEditingController(text: 'rebecca.martinez@icoach.com');
  final _phoneController          = TextEditingController(text: '+1 (555) 387-6543');
  final _yearsExpController       = TextEditingController();
  final _countryController        = TextEditingController();
  final _timezoneController       = TextEditingController();
  final _aboutController          = TextEditingController();
  final _sessionDurationController = TextEditingController(text: '50');
  final _currencyController       = TextEditingController();
  final _videoPriceController     = TextEditingController(text: '120');
  final _audioPriceController     = TextEditingController(text: '100');
  final _packagePriceController   = TextEditingController(text: '440');

  // ── Chips state ───────────────────────────────────────────────────────────
  final List<String> _allCategories = [
    'Life Coaching', 'Career', 'Mindfulness',
    'Goal Setting', 'Stress Management', 'Leadership',
  ];
  final Set<String> _selectedCategories = {
    'Life Coaching', 'Career', 'Mindfulness', 'Goal Setting', 'Stress Management',
  };

  final List<String> _allLanguages = [
    'English', 'Spanish', 'French', 'German', 'Mandarin',
  ];
  final Set<String> _selectedLanguages = {'English', 'Spanish', 'French'};

  // ── Certifications ────────────────────────────────────────────────────────
  final List<Map<String, String>> _certs = [
    {'name': 'ICF Certified Professional Coach.pdf', 'status': 'Verified'},
    {'name': 'Mental Health First Aid.pdf',          'status': 'Verified'},
    {'name': 'CBT Practitioner Certificate.pdf',     'status': 'Pending'},
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _titleController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _yearsExpController.dispose();
    _countryController.dispose();
    _timezoneController.dispose();
    _aboutController.dispose();
    _sessionDurationController.dispose();
    _currencyController.dispose();
    _videoPriceController.dispose();
    _audioPriceController.dispose();
    _packagePriceController.dispose();
    super.dispose();
  }

  void _goBack() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const CoachProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: const Color(0xFFE2E8F0),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: Color(0xFF1A2533)),
          onPressed: _goBack,
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A2533),
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _goBack,
            child: Text(
              'Save',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            // ── Avatar ──────────────────────────────────────────────────────
            _AvatarSection(),
            const SizedBox(height: 20),

            // ── Basic Information ────────────────────────────────────────────
            _EditCard(
              title: 'Basic Information',
              child: Column(
                children: [
                  _EditField(label: 'Full Name',         controller: _fullNameController),
                  _EditField(label: 'Professional Title', controller: _titleController),
                  _EditField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    helperText: '✓ Verified. Contact support to change.',
                  ),
                  _EditField(
                    label: 'Phone Number',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Professional Details ─────────────────────────────────────────
            _EditCard(
              title: 'Professional Details',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Coaching Categories
                  const _FieldLabel(text: 'Coaching Categories'),
                  const SizedBox(height: 8),
                  _ChipSelector(
                    all: _allCategories,
                    selected: _selectedCategories,
                    onToggle: (val) => setState(() {
                      _selectedCategories.contains(val)
                          ? _selectedCategories.remove(val)
                          : _selectedCategories.add(val);
                    }),
                  ),
                  const SizedBox(height: 16),

                  // Years of Experience
                  _EditField(
                    label: 'Years of Experience',
                    controller: _yearsExpController,
                    keyboardType: TextInputType.number,
                  ),

                  // Languages Spoken
                  const _FieldLabel(text: 'Languages Spoken'),
                  const SizedBox(height: 8),
                  _ChipSelector(
                    all: _allLanguages,
                    selected: _selectedLanguages,
                    onToggle: (val) => setState(() {
                      _selectedLanguages.contains(val)
                          ? _selectedLanguages.remove(val)
                          : _selectedLanguages.add(val);
                    }),
                  ),
                  const SizedBox(height: 16),

                  // Country
                  _EditField(label: 'Country',   controller: _countryController),
                  _EditField(label: 'Time Zone', controller: _timezoneController),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── About Me ─────────────────────────────────────────────────────
            _EditCard(
              title: 'About Me',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This appears on your profile page. Make it engaging and personal.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF9EABB8)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _aboutController,
                    maxLines: 5,
                    maxLength: 500,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF1A2533)),
                    decoration: _inputDecoration(hint: ''),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Certifications & Documents ───────────────────────────────────
            _EditCard(
              title: 'Certifications & Documents',
              child: Column(
                children: [
                  ..._certs.map((cert) => _CertRow(cert: cert)),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.add, size: 18, color: AppColors.primary),
                      label: Text(
                        'Upload New Certificate',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Session & Pricing ────────────────────────────────────────────
            _EditCard(
              title: 'Session & Pricing',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This is what clients see when booking.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF9EABB8)),
                  ),
                  const SizedBox(height: 12),
                  _EditField(
                    label: 'Session Duration (minutes)',
                    controller: _sessionDurationController,
                    keyboardType: TextInputType.number,
                  ),
                  _EditField(
                    label: 'Currency',
                    controller: _currencyController,
                  ),
                  _PriceField(label: 'Video Session Price',    controller: _videoPriceController),
                  _PriceField(label: 'Audio Session Price',    controller: _audioPriceController),
                  _PriceField(label: 'Package (4 sessions)',   controller: _packagePriceController),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Availability ─────────────────────────────────────────────────
            _EditCard(
              title: 'Availability',
              trailing: Icon(Icons.calendar_today_outlined,
                  size: 16, color: AppColors.primary),
              child: SizedBox(
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
                    'Manage Availability & Schedule',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Save Changes button ──────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _goBack,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ── Cancel button ────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: _goBack,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5A6A7A),
                  ),
                ),
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
// Avatar Section
// ─────────────────────────────────────────────────────────────────────────────
class _AvatarSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFF5BB8C9),
              child: const Text(
                'DR',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.edit, size: 13, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Upload / Replace',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'This photo is visible to clients',
          style: TextStyle(fontSize: 11, color: Color(0xFF9EABB8)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cert Row
// ─────────────────────────────────────────────────────────────────────────────
class _CertRow extends StatelessWidget {
  final Map<String, String> cert;
  const _CertRow({required this.cert});

  @override
  Widget build(BuildContext context) {
    final isVerified = cert['status'] == 'Verified';
    return Padding(
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
            child: Icon(Icons.picture_as_pdf_outlined,
                size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cert['name']!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A2533),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  cert['status']!,
                  style: TextStyle(
                    fontSize: 11,
                    color: isVerified ? AppColors.primary : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined,
                size: 18, color: Color(0xFF9EABB8)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                size: 18, color: Color(0xFF9EABB8)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chip Selector
// ─────────────────────────────────────────────────────────────────────────────
class _ChipSelector extends StatelessWidget {
  final List<String> all;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const _ChipSelector({
    required this.all,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: all.map((item) {
        final isSelected = selected.contains(item);
        return GestureDetector(
          onTap: () => onToggle(item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : const Color(0xFFF0F4F8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF9EABB8),
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.close, size: 12, color: Colors.white),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Price Field
// ─────────────────────────────────────────────────────────────────────────────
class _PriceField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _PriceField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel(text: label),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A2533)),
            decoration: _inputDecoration(hint: '0').copyWith(
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 12, right: 4),
                child: Text(
                  '\$',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9EABB8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              prefixIconConstraints:
              const BoxConstraints(minWidth: 0, minHeight: 0),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────
class _EditCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _EditCard({required this.title, required this.child, this.trailing});

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
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? helperText;

  const _EditField({
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel(text: label),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A2533)),
            decoration: _inputDecoration(hint: ''),
          ),
          if (helperText != null) ...[
            const SizedBox(height: 4),
            Text(
              helperText!,
              style: TextStyle(fontSize: 11, color: AppColors.primary),
            ),
          ],
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A2533),
      ),
    );
  }
}

InputDecoration _inputDecoration({required String hint}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFB0BEC5)),
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColors.primary, width: 1.5),
    ),
  );
}