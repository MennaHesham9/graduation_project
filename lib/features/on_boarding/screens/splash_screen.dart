import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'on_boarding_screen1.dart';


class MindWellApp extends StatelessWidget {
  const MindWellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindWell',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'sans-serif',
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _spinnerController;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _textFade;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const OnboardingScreen(),
        ),
      );
    });

    // Logo entrance animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    // Spinner rotation
    _spinnerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    // Start logo animation after a short delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _logoController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _spinnerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // Teal radial gradient background matching the screenshot
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2F8F9D),
              Color(0xFF20A8BC),
              Color(0xFF1E6091),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // ── Main centered content ──
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo card
                    AnimatedBuilder(
                      animation: _logoController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _logoFade.value,
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: child,
                          ),
                        );
                      },
                      child: _LogoCard(),
                    ),

                    const SizedBox(height: 28),

                    // App name
                    AnimatedBuilder(
                      animation: _logoController,
                      builder: (context, child) => Opacity(
                        opacity: _textFade.value,
                        child: child,
                      ),
                      child: const Text(
                        'MindWell',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Tagline
                    AnimatedBuilder(
                      animation: _logoController,
                      builder: (context, child) => Opacity(
                        opacity: _textFade.value,
                        child: child,
                      ),
                      child: const Text(
                        'Your Growth Journey Starts Here.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Bottom loading indicator ──
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) => Opacity(
                    opacity: _textFade.value,
                    child: child,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Custom spinner matching the screenshot style
                      AnimatedBuilder(
                        animation: _spinnerController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _spinnerController.value * 2 * math.pi,
                            child: child,
                          );
                        },
                        child: const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white70),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Loading your experience...',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The white rounded card containing the MindWell logo icon
class _LogoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Image.asset(
          'assets/images/logo.jpeg',
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// ignore: unused_element — kept for reference if needed
class _MindWellIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // ── Teal fill color (matches the logo) ──
    final fillPaint = Paint()
      ..color = const Color(0xFF2AA8B0)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = const Color(0xFF1A8A9A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final outlinePaint = Paint()
      ..color = const Color(0xFF2AA8B0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // ── LEFT HAND ──
    final leftHand = Path();
    // Palm base (left side)
    leftHand.moveTo(w * 0.04, h * 0.95);
    leftHand.quadraticBezierTo(w * 0.0, h * 0.78, w * 0.08, h * 0.65);
    leftHand.quadraticBezierTo(w * 0.10, h * 0.58, w * 0.14, h * 0.54);
    // Fingers (left hand, curving inward)
    leftHand.lineTo(w * 0.12, h * 0.42);
    leftHand.quadraticBezierTo(w * 0.11, h * 0.36, w * 0.15, h * 0.35);
    leftHand.quadraticBezierTo(w * 0.19, h * 0.34, w * 0.20, h * 0.40);
    leftHand.lineTo(w * 0.21, h * 0.48);
    leftHand.lineTo(w * 0.22, h * 0.38);
    leftHand.quadraticBezierTo(w * 0.22, h * 0.32, w * 0.26, h * 0.31);
    leftHand.quadraticBezierTo(w * 0.30, h * 0.30, w * 0.31, h * 0.37);
    leftHand.lineTo(w * 0.31, h * 0.46);
    leftHand.lineTo(w * 0.33, h * 0.38);
    leftHand.quadraticBezierTo(w * 0.33, h * 0.32, w * 0.37, h * 0.31);
    leftHand.quadraticBezierTo(w * 0.41, h * 0.31, w * 0.41, h * 0.38);
    leftHand.lineTo(w * 0.40, h * 0.50);
    // Palm continues
    leftHand.quadraticBezierTo(w * 0.42, h * 0.52, w * 0.44, h * 0.58);
    leftHand.quadraticBezierTo(w * 0.46, h * 0.70, w * 0.36, h * 0.78);
    leftHand.quadraticBezierTo(w * 0.28, h * 0.84, w * 0.22, h * 0.95);
    leftHand.close();
    canvas.drawPath(leftHand, fillPaint);
    canvas.drawPath(leftHand, strokePaint);

    // ── RIGHT HAND (mirrored) ──
    canvas.save();
    canvas.scale(-1, 1);
    canvas.translate(-w, 0);
    canvas.drawPath(leftHand, fillPaint);
    canvas.drawPath(leftHand, strokePaint);
    canvas.restore();

    // ── HEART (left half) ──
    final heart = Path();
    heart.moveTo(w * 0.50, h * 0.52);
    // Left lobe
    heart.cubicTo(
      w * 0.50, h * 0.40,
      w * 0.34, h * 0.38,
      w * 0.34, h * 0.26,
    );
    heart.cubicTo(
      w * 0.34, h * 0.16,
      w * 0.44, h * 0.12,
      w * 0.50, h * 0.20,
    );
    // Right lobe
    heart.cubicTo(
      w * 0.56, h * 0.12,
      w * 0.66, h * 0.16,
      w * 0.66, h * 0.26,
    );
    heart.cubicTo(
      w * 0.66, h * 0.38,
      w * 0.50, h * 0.40,
      w * 0.50, h * 0.52,
    );
    canvas.drawPath(heart, fillPaint);
    canvas.drawPath(heart, strokePaint);

    // Heart veins / lines (left side of heart)
    final veinPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(w * 0.44, h * 0.22),
      Offset(w * 0.40, h * 0.34),
      veinPaint,
    );
    canvas.drawLine(
      Offset(w * 0.40, h * 0.34),
      Offset(w * 0.44, h * 0.40),
      veinPaint,
    );
    canvas.drawLine(
      Offset(w * 0.40, h * 0.34),
      Offset(w * 0.37, h * 0.38),
      veinPaint,
    );

    // ── BRAIN (right half of the combined icon) ──
    final brain = Path();
    // Right brain hemisphere outline
    brain.moveTo(w * 0.50, h * 0.52);
    brain.cubicTo(w * 0.52, h * 0.42, w * 0.58, h * 0.40, w * 0.62, h * 0.34);
    brain.cubicTo(w * 0.68, h * 0.26, w * 0.72, h * 0.18, w * 0.66, h * 0.13);
    brain.cubicTo(w * 0.76, h * 0.12, w * 0.80, h * 0.20, w * 0.78, h * 0.28);
    brain.cubicTo(w * 0.84, h * 0.22, w * 0.86, h * 0.32, w * 0.80, h * 0.36);
    brain.cubicTo(w * 0.86, h * 0.38, w * 0.84, h * 0.46, w * 0.78, h * 0.46);
    brain.cubicTo(w * 0.80, h * 0.54, w * 0.74, h * 0.56, w * 0.68, h * 0.52);
    brain.cubicTo(w * 0.64, h * 0.58, w * 0.56, h * 0.56, w * 0.50, h * 0.52);
    brain.close();
    canvas.drawPath(brain, outlinePaint);

    // Brain fold lines (characteristic wrinkles)
    final foldPaint = Paint()
      ..color = const Color(0xFF2AA8B0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round;

    // Top fold
    final fold1 = Path();
    fold1.moveTo(w * 0.60, h * 0.18);
    fold1.cubicTo(w * 0.62, h * 0.22, w * 0.66, h * 0.22, w * 0.68, h * 0.18);
    canvas.drawPath(fold1, foldPaint);

    // Middle fold
    final fold2 = Path();
    fold2.moveTo(w * 0.56, h * 0.28);
    fold2.cubicTo(w * 0.60, h * 0.32, w * 0.64, h * 0.30, w * 0.66, h * 0.26);
    canvas.drawPath(fold2, foldPaint);

    // Lower fold
    final fold3 = Path();
    fold3.moveTo(w * 0.58, h * 0.38);
    fold3.cubicTo(w * 0.62, h * 0.42, w * 0.68, h * 0.40, w * 0.70, h * 0.36);
    canvas.drawPath(fold3, foldPaint);

    // Outer fold
    final fold4 = Path();
    fold4.moveTo(w * 0.70, h * 0.24);
    fold4.cubicTo(w * 0.74, h * 0.28, w * 0.76, h * 0.32, w * 0.74, h * 0.38);
    canvas.drawPath(fold4, foldPaint);

    // Center dividing line between heart and brain
    final divider = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(w * 0.50, h * 0.14),
      Offset(w * 0.50, h * 0.52),
      divider,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}