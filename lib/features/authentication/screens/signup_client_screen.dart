import 'package:flutter/material.dart';
import 'package:gradproject/features/authentication/screens/sign_in_screen.dart';
import 'package:gradproject/features/client/widgets/client_nav_bar.dart';
import '../../../core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';

// List of countries for the dropdown
const List<String> _kCountries = [
  'Afghanistan', 'Albania', 'Algeria', 'Andorra', 'Angola', 'Argentina',
  'Armenia', 'Australia', 'Austria', 'Azerbaijan', 'Bahamas', 'Bahrain',
  'Bangladesh', 'Belarus', 'Belgium', 'Belize', 'Benin', 'Bhutan',
  'Bolivia', 'Bosnia and Herzegovina', 'Botswana', 'Brazil', 'Brunei',
  'Bulgaria', 'Burkina Faso', 'Burundi', 'Cambodia', 'Cameroon', 'Canada',
  'Central African Republic', 'Chad', 'Chile', 'China', 'Colombia',
  'Comoros', 'Congo', 'Costa Rica', 'Croatia', 'Cuba', 'Cyprus',
  'Czech Republic', 'Denmark', 'Djibouti', 'Dominican Republic', 'Ecuador',
  'Egypt', 'El Salvador', 'Equatorial Guinea', 'Eritrea', 'Estonia',
  'Eswatini', 'Ethiopia', 'Fiji', 'Finland', 'France', 'Gabon', 'Gambia',
  'Georgia', 'Germany', 'Ghana', 'Greece', 'Guatemala', 'Guinea',
  'Guinea-Bissau', 'Guyana', 'Haiti', 'Honduras', 'Hungary', 'Iceland',
  'India', 'Indonesia', 'Iran', 'Iraq', 'Ireland', 'Israel', 'Italy',
  'Jamaica', 'Japan', 'Jordan', 'Kazakhstan', 'Kenya', 'Kuwait',
  'Kyrgyzstan', 'Laos', 'Latvia', 'Lebanon', 'Lesotho', 'Liberia',
  'Libya', 'Liechtenstein', 'Lithuania', 'Luxembourg', 'Madagascar',
  'Malawi', 'Malaysia', 'Maldives', 'Mali', 'Malta', 'Mauritania',
  'Mauritius', 'Mexico', 'Moldova', 'Monaco', 'Mongolia', 'Montenegro',
  'Morocco', 'Mozambique', 'Myanmar', 'Namibia', 'Nepal', 'Netherlands',
  'New Zealand', 'Nicaragua', 'Niger', 'Nigeria', 'North Korea',
  'North Macedonia', 'Norway', 'Oman', 'Pakistan', 'Palestine', 'Panama',
  'Papua New Guinea', 'Paraguay', 'Peru', 'Philippines', 'Poland',
  'Portugal', 'Qatar', 'Romania', 'Russia', 'Rwanda', 'Saudi Arabia',
  'Senegal', 'Serbia', 'Sierra Leone', 'Singapore', 'Slovakia', 'Slovenia',
  'Somalia', 'South Africa', 'South Korea', 'South Sudan', 'Spain',
  'Sri Lanka', 'Sudan', 'Sweden', 'Switzerland', 'Syria', 'Taiwan',
  'Tajikistan', 'Tanzania', 'Thailand', 'Togo', 'Trinidad and Tobago',
  'Tunisia', 'Turkey', 'Turkmenistan', 'Uganda', 'Ukraine',
  'United Arab Emirates', 'United Kingdom', 'United States', 'Uruguay',
  'Uzbekistan', 'Venezuela', 'Vietnam', 'Yemen', 'Zambia', 'Zimbabwe',
];

class SignupClientScreen extends StatefulWidget {
  const SignupClientScreen({super.key});

  @override
  State<SignupClientScreen> createState() => _SignupClientScreenState();
}

class _SignupClientScreenState extends State<SignupClientScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _countryController = TextEditingController();
  final _primaryGoalController = TextEditingController();

  bool _passwordVisible = false;
  bool _agreedToTerms = false;
  List<String> _filteredCountries = [];

  final LayerLink _countryLayerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _countryController.dispose();
    _primaryGoalController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _filterCountries(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredCountries = [];
      });
      _removeOverlay();
      return;
    }
    final filtered = _kCountries
        .where((c) => c.toLowerCase().startsWith(query.toLowerCase()))
        .toList();
    setState(() {
      _filteredCountries = filtered;
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
          link: _countryLayerLink,
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
                itemCount: _filteredCountries.length,
                itemBuilder: (context, index) {
                  final country = _filteredCountries[index];
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _countryController.text = country;
                      });
                      _removeOverlay();
                      FocusScope.of(context).unfocus();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Text(
                        country,
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
                  // Title
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0A0A0A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Join us and start your growth journey',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Step indicator
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
                          hintText: 'Sarah Johnson',
                          prefixIcon: Icons.person_outline,
                        ),
                        const SizedBox(height: 18),

                        // Email Address
                        _buildLabel('Email Address'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _emailController,
                          hintText: 'sarah@example.com',
                          prefixIcon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 18),

                        // Phone Number
                        _buildLabel('Phone Number'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _phoneController,
                          hintText: '+1 (555) 123-4567',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 18),

                        // Password
                        _buildLabel('Password'),
                        const SizedBox(height: 8),
                        _buildPasswordField(),
                        const SizedBox(height: 18),

                        // Country
                        _buildLabel('Country'),
                        const SizedBox(height: 8),
                        _buildCountryField(),
                        const SizedBox(height: 18),

                        // Primary Goal (Optional)
                        _buildPrimaryGoalLabel(),
                        const SizedBox(height: 8),
                        _buildPrimaryGoalField(),
                        const SizedBox(height: 24),

                        // Terms and conditions
                        _buildTermsRow(),
                        const SizedBox(height: 24),

                        // Continue button
                        _buildContinueButton(),
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

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Active step
        Container(
          width: 60,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        // Inactive step 2
        Container(
          width: 60,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        // Inactive step 3
        Container(
          width: 60,
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

  Widget _buildPrimaryGoalLabel() {
    return Row(
      children: [
        const Text(
          'Primary Goal',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0A0A0A),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '(Optional)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade500,
          ),
        ),
      ],
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
        color: Color(0x800A0A0A), // #0A0A0A at 50%
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

  Widget _buildCountryField() {
    return CompositedTransformTarget(
      link: _countryLayerLink,
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
          controller: _countryController,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF0A0A0A),
          ),
          onChanged: _filterCountries,
          onTap: () {
            if (_countryController.text.isNotEmpty) {
              _filterCountries(_countryController.text);
            }
          },
          decoration: _buildInputDecoration(
            hintText: '',
            prefixIcon: const Icon(
              Icons.language_outlined,
              size: 20,
              color: Color(0x800A0A0A),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryGoalField() {
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
        controller: _primaryGoalController,
        maxLines: 4,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF0A0A0A),
        ),
        decoration: InputDecoration(
          hintText: 'What do you want to achieve?',
          hintStyle: const TextStyle(
            fontSize: 16,
            color: Color(0x800A0A0A),
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(bottom: 64, left: 4),
            child: Icon(
              Icons.track_changes_outlined,
              size: 20,
              color: Color(0x800A0A0A),
            ),
          ),
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
        ),
      ),
    );
  }

  Widget _buildTermsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: _agreedToTerms,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: (val) {
              setState(() {
                _agreedToTerms = val ?? false;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF0A0A0A),
              ),
              children: [
                const TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms of Service',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return SizedBox(
      width: double.infinity, height: 52,
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
            width: 22, height: 22,
            child: CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2.5))
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Continue',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward, size: 18, color: Colors.white),
          ],
        ),
      ),
    );
  }

// Add this new method to _SignupClientScreenState:
  Future<void> _handleSignUp() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the Terms of Service.')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.signUpClient(
      fullName: _fullNameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      phone: _phoneController.text,
      country: _countryController.text.isEmpty
          ? null
          : _countryController.text,
      primaryGoal: _primaryGoalController.text.isEmpty
          ? null
          : _primaryGoalController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ClientNavBar()),
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