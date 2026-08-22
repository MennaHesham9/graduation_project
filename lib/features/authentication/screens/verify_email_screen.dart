import 'package:flutter/material.dart';
import 'package:mindwell/core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'sign_in_screen.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email_outlined, size: 80, color: AppColors.primary),
              const SizedBox(height: 24),
              const Text('Verify your email', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text(
                'We sent a link to your email. Please click it to verify your account, then sign in.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                ),
                child: const Text('Go to Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}