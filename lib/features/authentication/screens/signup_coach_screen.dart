import 'package:flutter/material.dart';
import 'package:gradproject/features/authentication/screens/sign_in_screen.dart';
import 'package:gradproject/features/coach/widgets/coach_nav_bar.dart';
import '../../../core/constants/app_colors.dart';

// Coaching categories for dropdown
const List<String> _kCoachingCategories = [
  'Business Coaching',
  'Career Coaching',
  'Executive Coaching',
  'Financial Coaching',
  'Health & Wellness Coaching',
  'Leadership Coaching',
  'Life Coaching',
  'Mental Health Coaching',
  'Mindfulness Coaching',
  'Nutrition Coaching',
  'Performance Coaching',
  'Relationship Coaching',
  'Sales Coaching',
  'Spiritual Coaching',
  'Sports Coaching',
  'Stress Management Coaching',
];

class SignupCoachScreen extends StatefulWidget {
  const SignupCoachScreen({super.key});

  @override
  State<SignupCoachScreen> createState() => _SignupCoachScreenState();
}

class _SignupCoachScreenState extends State<SignupCoachScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _coachingCategoryController = TextEditingController();
  final _yearsOfExperienceController = TextEditingController();

  bool _passwordVisible = false;
  List<String> _filteredCategories = [];

  // Uploaded files mock list
  final List<Map<String, String>> _uploadedFiles = [
    {'name': 'Coaching_Certificate.pdf', 'size': '2.4 MB'},
  ];

  final LayerLink _categoryLayerLink = LayerLink();
  OverlayEntry? _overlayEntry;

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
      setState(() {
        _filteredCategories = [];
      });
      _removeOverlay();
      return;
    }
    final filtered = _kCoachingCategories
        .where((c) => c.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      _filteredCategories = filtered;
    });
    if (filtered.isNotEmpty) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
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
                      setState(() {
                        _coachingCategoryController.text = category;
                      });
                      _removeOverlay();
                      FocusScope.of(context).unfocus();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF0A0A0A),
                        ),
                      ),
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

  void _handleFilePick() {
    // In a real app: use file_picker package
    // Simulating a file being added for demo purposes
    setState(() {
      _uploadedFiles.add({'name': 'New_Certificate.pdf', 'size': '1.2 MB'});
    });
  }

  void _removeFile(int index) {
    setState(() {
      _uploadedFiles.removeAt(index);
    });
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
                  // Teal icon badge
                  _buildTopIcon(),
                  const SizedBox(height: 16),

                  // Title
                  const Text(
                    'Join as Coach',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0A0A0A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Share your expertise and help others grow',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Step indicator (step 2 active)
                  _buildStepIndicator(),

                  const SizedBox(height: 28),

                  // White card
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
                        // Full Name
                        _buildLabel('Full Name'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _fullNameController,
                          hintText: 'Dr. Michael Chen',
                          prefixIcon: Icons.person_outline,
                        ),
                        const SizedBox(height: 18),

                        // Professional Email
                        _buildLabel('Professional Email'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _emailController,
                          hintText: 'michael@coaching.com',
                          prefixIcon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 18),

                        // Password
                        _buildLabel('Password'),
                        const SizedBox(height: 8),
                        _buildPasswordField(),
                        const SizedBox(height: 18),

                        // Coaching Category
                        _buildLabel('Coaching Category'),
                        const SizedBox(height: 8),
                        _buildCategoryField(),
                        const SizedBox(height: 18),

                        // Years of Experience
                        _buildLabel('Years of Experience'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _yearsOfExperienceController,
                          hintText: 'e.g., 5',
                          prefixIcon: Icons.workspace_premium_outlined,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 18),

                        // Certifications & Credentials
                        _buildLabel('Certifications & Credentials'),
                        const SizedBox(height: 8),
                        _buildUploadArea(),
                        const SizedBox(height: 12),

                        // Uploaded files list
                        ..._uploadedFiles.asMap().entries.map(
                              (entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _buildUploadedFileItem(
                                    entry.value, entry.key),
                              ),
                            ),

                        const SizedBox(height: 24),

                        // Submit button
                        _buildSubmitButton(),
                        const SizedBox(height: 18),

                        // Sign in row
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

  Widget _buildTopIcon() {
    return Container(
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
      child: const Icon(
        Icons.workspace_premium_outlined,
        color: Colors.white,
        size: 36,
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Step 1 - completed/active
        Container(
          width: 50,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        // Step 2 - active
        Container(
          width: 50,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        // Step 3 - inactive
        Container(
          width: 50,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        // Step 4 - inactive
        Container(
          width: 50,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF0A0A0A),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required Widget prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontSize: 16,
        color: Color(0x800A0A0A),
      ),
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
  }) {
    return Container(
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
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF0A0A0A),
        ),
        decoration: _buildInputDecoration(
          hintText: hintText,
          prefixIcon: Icon(
            prefixIcon,
            size: 20,
            color: const Color(0x800A0A0A),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
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
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF0A0A0A),
        ),
        decoration: _buildInputDecoration(
          hintText: 'Create a strong password',
          prefixIcon: const Icon(
            Icons.lock_outline,
            size: 20,
            color: Color(0x800A0A0A),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _passwordVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 20,
              color: const Color(0x800A0A0A),
            ),
            onPressed: () {
              setState(() {
                _passwordVisible = !_passwordVisible;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryField() {
    return CompositedTransformTarget(
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
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF0A0A0A),
          ),
          onChanged: _filterCategories,
          onTap: () {
            if (_coachingCategoryController.text.isNotEmpty) {
              _filterCategories(_coachingCategoryController.text);
            }
          },
          decoration: _buildInputDecoration(
            hintText: '',
            prefixIcon: const Icon(
              Icons.work_outline,
              size: 20,
              color: Color(0x800A0A0A),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadArea() {
    return GestureDetector(
      onTap: _handleFilePick,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1.2,
          ),
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
            Icon(
              Icons.upload_outlined,
              size: 32,
              color: Colors.grey.shade500,
            ),
            const SizedBox(height: 10),
            Text(
              'Click to upload certificates',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'PDF, JPG, PNG up to 10MB',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadedFileItem(Map<String, String> file, int index) {
    return Container(
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
          Icon(
            Icons.insert_drive_file_outlined,
            size: 22,
            color: Colors.blue.shade400,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file['name'] ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0A0A0A),
                  ),
                ),
                Text(
                  file['size'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _removeFile(index),
            child: Icon(
              Icons.check_circle_outline,
              size: 22,
              color: Colors.green.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          // Handle submit for verification
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CoachNavBar(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.workspace_premium_outlined,
              size: 18,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              'Submit for Verification',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF0A0A0A),
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () {
            // Navigate to sign in
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SignInScreen(),
              ),
            );
          },
          child: Text(
            'Sign in',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}