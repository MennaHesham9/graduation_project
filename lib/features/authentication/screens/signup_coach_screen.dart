import 'package:flutter/material.dart';
import 'package:mindwell/features/authentication/screens/sign_in_screen.dart';
import 'package:mindwell/features/authentication/screens/verify_email_screen.dart';
import '../../../core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../coach/widgets/coach_nav_bar.dart';
import '../../../core/services/certification_service.dart';

const List<String> _kCoachingCategories = [
  'Business Coaching', 'Career Coaching', 'Executive Coaching',
  'Financial Coaching', 'Health & Wellness Coaching', 'Leadership Coaching',
  'Life Coaching', 'Mental Health Coaching', 'Mindfulness Coaching',
  'Nutrition Coaching', 'Performance Coaching', 'Relationship Coaching',
  'Sales Coaching', 'Spiritual Coaching', 'Sports Coaching',
  'Stress Management Coaching',
];

class SignupCoachScreen extends StatefulWidget {
  const SignupCoachScreen({super.key});

  @override
  State<SignupCoachScreen> createState() => _SignupCoachScreenState();
}

class _SignupCoachScreenState extends State<SignupCoachScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController           = TextEditingController();
  final _emailController              = TextEditingController();
  final _passwordController           = TextEditingController();
  final _coachingCategoryController   = TextEditingController();
  final _yearsOfExperienceController  = TextEditingController();

  bool _passwordVisible = false;
  List<String> _filteredCategories = [];

  final List<CertFile> _uploadedFiles = [];
  final CertificationService _certService = CertificationService();

  final LayerLink _categoryLayerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  // ── Validators ──────────────────────────────────────────────────────────────
  String? _validateFullName(String? val) {
    if (val == null || val.trim().isEmpty) return 'Full name is required';
    if (val.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? _validateEmail(String? val) {
    if (val == null || val.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    if (!emailRegex.hasMatch(val.trim())) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? val) {
    if (val == null || val.isEmpty) return 'Password is required';
    if (val.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateCategory(String? val) {
    if (val == null || val.trim().isEmpty) return 'Coaching category is required';
    return null;
  }

  String? _validateYearsOfExp(String? val) {
    if (val == null || val.trim().isEmpty) return 'Years of experience is required';
    final n = int.tryParse(val.trim());
    if (n == null || n < 0 || n > 60) return 'Enter a valid number (0–60)';
    return null;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _coachingCategoryController.dispose();
    _yearsOfExperienceController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _filterCategories(String query) {
    if (query.isEmpty) {
      setState(() => _filteredCategories = []);
      _removeOverlay();
      return;
    }
    final filtered = _kCoachingCategories
        .where((c) => c.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() => _filteredCategories = filtered);
    filtered.isNotEmpty ? _showOverlay() : _removeOverlay();
  }

  void _showOverlay() {
    _removeOverlay();
    _overlayEntry = _buildOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _buildOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 64,
        child: CompositedTransformFollower(
          link: _categoryLayerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 56),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _filteredCategories.length,
                itemBuilder: (context, index) {
                  final category = _filteredCategories[index];
                  return InkWell(
                    onTap: () {
                      setState(
                              () => _coachingCategoryController.text = category);
                      _removeOverlay();
                      FocusScope.of(context).unfocus();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Text(category,
                          style: const TextStyle(
                              fontSize: 14, color: Color(0xFF0A0A0A))),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleFilePick() async {
    final cert = await _certService.pickCertification();
    if (cert == null) return;

    if (cert.isOversized) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${cert.name} is too large (${cert.sizeLabel}). Max 500 KB per file.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _uploadedFiles.add(cert));
  }

  void _removeFile(int index) =>
      setState(() => _uploadedFiles.removeAt(index));

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.signUpCoach(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: '',
      coachingCategory: _coachingCategoryController.text.isEmpty
          ? null
          : _coachingCategoryController.text,
      yearsOfExperience: _yearsOfExperienceController.text.isEmpty
          ? null
          : _yearsOfExperienceController.text,
    );

    if (!mounted) return;

    if (success && _uploadedFiles.isNotEmpty) {
      // Save certifications after account creation
      await auth.updateCertifications(
        _uploadedFiles.map((c) => c.toMap()).toList(),
      );
    }

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const VerifyEmailScreen()),
            (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Sign up failed.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          _removeOverlay();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildTopIcon(),
                  const SizedBox(height: 16),
                  const Text('Join as Coach',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0A0A0A))),
                  const SizedBox(height: 6),
                  const Text('Share your expertise and help others grow',
                      style:
                      TextStyle(fontSize: 16, color: Colors.black54)),
                  const SizedBox(height: 20),
                  _buildStepIndicator(),
                  const SizedBox(height: 28),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.07),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Full Name'),
                        const SizedBox(height: 8),
                        _buildValidatedField(
                          controller: _fullNameController,
                          hintText: 'Dr. Michael Chen',
                          prefixIcon: Icons.person_outline,
                          validator: _validateFullName,
                        ),
                        const SizedBox(height: 18),

                        _buildLabel('Professional Email'),
                        const SizedBox(height: 8),
                        _buildValidatedField(
                          controller: _emailController,
                          hintText: 'michael@coaching.com',
                          prefixIcon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 18),

                        _buildLabel('Password'),
                        const SizedBox(height: 8),
                        _buildPasswordField(),
                        const SizedBox(height: 18),

                        _buildLabel('Coaching Category'),
                        const SizedBox(height: 8),
                        _buildCategoryField(),
                        const SizedBox(height: 18),

                        _buildLabel('Years of Experience'),
                        const SizedBox(height: 8),
                        _buildValidatedField(
                          controller: _yearsOfExperienceController,
                          hintText: 'e.g., 5',
                          prefixIcon: Icons.workspace_premium_outlined,
                          keyboardType: TextInputType.number,
                          validator: _validateYearsOfExp,
                        ),
                        const SizedBox(height: 18),

                        _buildLabel('Certifications & Credentials'),
                        const SizedBox(height: 8),
                        _buildUploadArea(),
                        const SizedBox(height: 12),

                        ..._uploadedFiles.asMap().entries.map(
                              (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildUploadedFileItem(
                                entry.value, entry.key),
                          ),
                        ),

                        const SizedBox(height: 24),
                        _buildSubmitButton(),
                        const SizedBox(height: 18),
                        _buildSignInRow(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Builders ──────────────────────────────────────────────────────────────

  Widget _buildTopIcon() => Container(
    width: 72,
    height: 72,
    decoration: BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.35),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: const Icon(Icons.workspace_premium_outlined,
        color: Colors.white, size: 36),
  );

  Widget _buildStepIndicator() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _stepBar(active: true),
      const SizedBox(width: 6),
      _stepBar(active: true),
      const SizedBox(width: 6),
      _stepBar(active: false),
      const SizedBox(width: 6),
      _stepBar(active: false),
    ],
  );

  Widget _stepBar({required bool active}) => Container(
    width: 50,
    height: 3,
    decoration: BoxDecoration(
      color: active ? AppColors.primary : Colors.grey.shade300,
      borderRadius: BorderRadius.circular(2),
    ),
  );

  Widget _buildLabel(String text) => Text(text,
      style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF0A0A0A)));

  InputDecoration _inputDecoration({
    required String hintText,
    required Widget prefixIcon,
    Widget? suffixIcon,
  }) =>
      InputDecoration(
        hintText: hintText,
        hintStyle:
        const TextStyle(fontSize: 16, color: Color(0x800A0A0A)),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        errorStyle:
        const TextStyle(fontSize: 12, color: Colors.redAccent),
      );

  Widget _buildValidatedField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    required String? Function(String?) validator,
  }) =>
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: const TextStyle(fontSize: 16, color: Color(0xFF0A0A0A)),
          decoration: _inputDecoration(
            hintText: hintText,
            prefixIcon: Icon(prefixIcon,
                size: 20, color: const Color(0x800A0A0A)),
          ),
        ),
      );

  Widget _buildPasswordField() => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: TextFormField(
      controller: _passwordController,
      obscureText: !_passwordVisible,
      validator: _validatePassword,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: const TextStyle(fontSize: 16, color: Color(0xFF0A0A0A)),
      decoration: _inputDecoration(
        hintText: 'Create a strong password',
        prefixIcon: const Icon(Icons.lock_outline,
            size: 20, color: Color(0x800A0A0A)),
        suffixIcon: IconButton(
          icon: Icon(
            _passwordVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 20,
            color: const Color(0x800A0A0A),
          ),
          onPressed: () =>
              setState(() => _passwordVisible = !_passwordVisible),
        ),
      ),
    ),
  );

  Widget _buildCategoryField() => CompositedTransformTarget(
    link: _categoryLayerLink,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _coachingCategoryController,
        validator: _validateCategory,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: _filterCategories,
        onTap: () {
          if (_coachingCategoryController.text.isNotEmpty) {
            _filterCategories(_coachingCategoryController.text);
          }
        },
        style:
        const TextStyle(fontSize: 16, color: Color(0xFF0A0A0A)),
        decoration: _inputDecoration(
          hintText: 'Type to search category...',
          prefixIcon: const Icon(Icons.work_outline,
              size: 20, color: Color(0x800A0A0A)),
        ),
      ),
    ),
  );

  Widget _buildUploadArea() => GestureDetector(
    onTap: () => _handleFilePick(),
    child: Container(
      width: double.infinity,
      padding:
      const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
        Border.all(color: Colors.grey.shade300, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.upload_outlined,
              size: 32, color: Colors.grey.shade500),
          const SizedBox(height: 10),
          Text('Click to upload certificates',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700)),
          const SizedBox(height: 4),
          Text('PDF, JPG, PNG up to 10MB',
              style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade400)),
        ],
      ),
    ),
  );

  Widget _buildUploadedFileItem(CertFile file, int index) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.insert_drive_file_outlined,
                size: 22, color: Colors.blue.shade400),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(file.name,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0A0A0A))),
                  Text(file.sizeLabel,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade400)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _removeFile(index),
              child: Icon(Icons.close,
                  size: 20, color: Colors.grey.shade400),
            ),
          ],
        ),
      );

  Widget _buildSubmitButton() {
    final isLoading = context.watch<AuthProvider>().isLoading;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleSignUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: isLoading
            ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2.5))
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.workspace_premium_outlined,
                size: 18, color: Colors.white),
            SizedBox(width: 8),
            Text('Submit for Verification',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInRow() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text('Already have an account?',
          style: TextStyle(fontSize: 16, color: Color(0xFF0A0A0A))),
      const SizedBox(width: 4),
      GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SignInScreen()),
        ),
        child: Text('Sign in',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary)),
      ),
    ],
  );
}