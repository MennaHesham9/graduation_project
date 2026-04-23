import 'package:flutter/material.dart';
import '../../authentication/screens/sign_in_screen.dart';
import 'on_boarding_screen3.dart';

void main() {
  runApp(const MindWellApp());
}

class MindWellApp extends StatelessWidget {
  const MindWellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindWell',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const OnboardingScreen2(),
    );
  }
}

class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topHeight = size.height * 0.52;

    // Circle sizes — outer halo and inner filled circle
    final outerCircle = size.width * 0.70;
    final innerCircle = size.width * 0.56;
    final iconSize    = size.width * 0.28;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [

          // ── TOP SECTION ──────────────────────────────────────────
          Container(
            height: topHeight,
            width: double.infinity,
            color: const Color(0xFF1EAABB),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [

                  // Outer faint halo ring
                  Container(
                    width: outerCircle,
                    height: outerCircle,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.12),
                    ),
                  ),

                  // Inner solid-ish circle (the main visible circle)
                  Container(
                    width: innerCircle,
                    height: innerCircle,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.25),
                    ),
                  ),

                  // Coach icon centered inside
                  CustomPaint(
                    size: Size(iconSize, iconSize),
                    painter: _CoachIconPainter(),
                  ),
                ],
              ),
            ),
          ),

          // ── BOTTOM SECTION ────────────────────────────────────────
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),

                  // Title
                  const Text(
                    'Connect with Certified Coaches',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                      letterSpacing: 0.1,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 14),

                  // Description
                  const Text(
                    'Access verified professional coaches who specialize in various areas to support your unique journey.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                      height: 1.65,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 28),

                  // Page dots — 2nd active
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Dot(active: false),
                      const SizedBox(width: 6),
                      _Dot(active: true),
                      const SizedBox(width: 6),
                      _Dot(active: false),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Next button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFF1EAABB),
                            Color(0xFF178A9A),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OnboardingScreen3(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Next',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.4,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Skip
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SignInScreen()),
                      );
                    },

                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page dot widget ──────────────────────────────────────────────
class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: active ? 26 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF1EAABB) : const Color(0xFFD1D5DB),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _CoachIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawCircle(
      Offset(w * 0.35, h * 0.28),
      w * 0.14,
      paint,
    );

    final body1 = Path();
    body1.moveTo(w * 0.18, h * 0.72);
    body1.quadraticBezierTo(
      w * 0.35, h * 0.58,
      w * 0.52, h * 0.72,
    );
    canvas.drawPath(body1, paint);

    canvas.drawCircle(
      Offset(w * 0.70, h * 0.34),
      w * 0.10,
      paint,
    );

    final body2 = Path();
    body2.moveTo(w * 0.58, h * 0.78);
    body2.quadraticBezierTo(
      w * 0.70, h * 0.68,
      w * 0.82, h * 0.78,
    );
    canvas.drawPath(body2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}