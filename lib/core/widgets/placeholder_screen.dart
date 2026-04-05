import 'package:flutter/material.dart';

class PlaceholderScreen extends StatelessWidget {
  final String name;

  const PlaceholderScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Text(
          name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2F8F9D),
          ),
        ),
      ),
    );
  }
}

// 