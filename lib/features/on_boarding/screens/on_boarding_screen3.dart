import 'package:flutter/material.dart';

import 'package:mindwell/features/on_boarding/screens/role_choosing_screen.dart';

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
      home: const OnboardingScreen3(),
    );
  }
}

class OnboardingScreen3 extends StatelessWidget {
  const OnboardingScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topHeight = size.height * 0.55;
    final outerCircle = size.width * 0.70;
    final innerCircle = size.width * 0.56;
    final iconSize = size.width * 0.30;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [

          // ── TOP SECTION ──────────────────────────────────────────
          Container(
            height: topHeight,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2F8F9D),
                  Color(0xFF1EAABB),
                  Color(0xFF1A7FA8),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer faint halo
                  Container(
                    width: outerCircle,
                    height: outerCircle,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.12),
                    ),
                  ),

                  // Inner circle
                  Container(
                    width: innerCircle,
                    height: innerCircle,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.25),
                    ),
                  ),

                  // Heart icon
                  CustomPaint(
                    size: Size(iconSize, iconSize),
                    painter: _HeartIconPainter(),
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
                    'Improve Your Well-Being',
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
                    'Track your mood, practice mindfulness, and build healthy habits that transform your mental wellness.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                      height: 1.65,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 28),

                  // Page dots — 3rd active
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Dot(active: false),
                      const SizedBox(width: 6),
                      _Dot(active: false),
                      const SizedBox(width: 6),
                      _Dot(active: true),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Get Started button
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
                              builder: (context) => const RoleChoosingScreen(),
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
                              'Get Started',
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

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page dot ─────────────────────────────────────────────────────
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

// ── Heart icon painter ────────────────────────────────────────────
// Draws a clean outlined heart with rounded curves — white stroke only
class _HeartIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    // Start at the bottom tip of the heart
    path.moveTo(w * 0.50, h * 0.88);

    // Left curve — bottom to left lobe
    path.cubicTo(
      w * 0.20, h * 0.65,  // control 1
      w * 0.02, h * 0.48,  // control 2
      w * 0.08, h * 0.30,  // end
    );

    // Left lobe top arc
    path.cubicTo(
      w * 0.12, h * 0.14,  // control 1
      w * 0.34, h * 0.10,  // control 2
      w * 0.50, h * 0.28,  // end (top center dip)
    );

    // Right lobe top arc
    path.cubicTo(
      w * 0.66, h * 0.10,  // control 1
      w * 0.88, h * 0.14,  // control 2
      w * 0.92, h * 0.30,  // end
    );

    // Right curve — right lobe to bottom tip
    path.cubicTo(
      w * 0.98, h * 0.48,  // control 1
      w * 0.80, h * 0.65,  // control 2
      w * 0.50, h * 0.88,  // end (bottom tip)
    );

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}