import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:gradproject/features/client/screens/sessions/assessments_screen.dart';
import '../../../core/constants/app_colors.dart';

class WheelOfLifeScreen extends StatefulWidget {
  const WheelOfLifeScreen({super.key});

  @override
  State<WheelOfLifeScreen> createState() => _WheelOfLifeScreenState();
}

class _WheelOfLifeScreenState extends State<WheelOfLifeScreen> {
  final List<_LifeArea> _areas = [
    _LifeArea(label: 'Career', value: 7),
    _LifeArea(label: 'Finance', value: 6),
    _LifeArea(label: 'Health', value: 8),
    _LifeArea(label: 'Relationships', value: 7),
    _LifeArea(label: 'Personal Growth', value: 9),
    _LifeArea(label: 'Fun & Recreation', value: 5),
    _LifeArea(label: 'Physical Environment', value: 7),
    _LifeArea(label: 'Contribution', value: 6),
  ];

  double get _average =>
      _areas.map((a) => a.value).reduce((a, b) => a + b) / _areas.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  children: [
                    _buildWheelCard(),
                    const SizedBox(height: 12),
                    ..._areas.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildSliderCard(entry.key),
                      );
                    }),
                    const SizedBox(height: 4),
                    _buildBalanceCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: const Color(0xFFF0F4F8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: const Icon(Icons.arrow_back_ios,
                    size: 18, color: Color(0xFF5A6A7A)),
              ),
              const SizedBox(width: 8),
              const Text(
                'Wheel of Life',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.only(left: 26),
            child: Text(
              'Rate each life area from 1 (low) to 10 (high)',
              style: TextStyle(fontSize: 12, color: Color(0xFF718096)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Wheel Card ────────────────────────────────────────────────────────────

  Widget _buildWheelCard() {
    return _SectionCard(
      child: SizedBox(
        height: 220,
        child: Center(
          child: CustomPaint(
            size: const Size(200, 200),
            painter: _WheelPainter(
              values: _areas.map((a) => a.value.toDouble()).toList(),
              primaryColor: AppColors.primary,
            ),
            child: SizedBox(
              width: 200,
              height: 200,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _average.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF2D3748),
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Average',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Slider Card ───────────────────────────────────────────────────────────

  Widget _buildSliderCard(int index) {
    final area = _areas[index];
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                area.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F4F8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${area.value}/10',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: const Color(0xFFE2E8F0),
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.1),
            ),
            child: Slider(
              value: area.value.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (v) {
                setState(() {
                  _areas[index] = _LifeArea(
                    label: area.label,
                    value: v.round(),
                  );
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('1', style: TextStyle(fontSize: 10, color: Color(0xFFA0AEC0))),
                Text('5', style: TextStyle(fontSize: 10, color: Color(0xFFA0AEC0))),
                Text('10', style: TextStyle(fontSize: 10, color: Color(0xFFA0AEC0))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Balance Card ──────────────────────────────────────────────────────────

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F6F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB2DDE5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Balance',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your overall life balance score is ${_average.toStringAsFixed(1)}/10. '
                'Focus on areas with lower scores for improvement.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('💡', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Tip: A balanced wheel rolls smoothly. Identify 1-2 areas to work on this month.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Save Button ───────────────────────────────────────────────────────────

  Widget _buildSaveButton() {
    return Container(
      color: const Color(0xFFF0F4F8),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AssessmentsScreen(),
              ),
            );
          },
          icon: const Icon(Icons.save_outlined, size: 17),
          label: const Text(
            'Save Assessment',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Wheel Painter ─────────────────────────────────────────────────────────────

class _WheelPainter extends CustomPainter {
  final List<double> values;
  final Color primaryColor;

  const _WheelPainter({required this.values, required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    final count = values.length;

    // Background circle
    final bgPaint = Paint()
      ..color = const Color(0xFFF0F4F8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, maxRadius, bgPaint);

    // Border circle
    final borderPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, maxRadius, borderPaint);

    // Inner guide circles
    final guidePaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (final fraction in [0.25, 0.5, 0.75]) {
      canvas.drawCircle(center, maxRadius * fraction, guidePaint);
    }

    // Filled polygon
    final points = <Offset>[];
    for (int i = 0; i < count; i++) {
      final angle = (2 * math.pi / count) * i - math.pi / 2;
      final radius = (values[i] / 10) * maxRadius;
      points.add(Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      ));
    }

    final fillPaint = Paint()
      ..color = primaryColor.withOpacity(0.12)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = primaryColor.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Dots at each value point
    final dotPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    for (final p in points) {
      canvas.drawCircle(p, 4.5, dotPaint);
      canvas.drawCircle(
          p,
          4.5,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5);
    }
  }

  @override
  bool shouldRepaint(_WheelPainter old) => old.values != values;
}

// ─── Supporting Widgets ────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

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
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─── Data Model ────────────────────────────────────────────────────────────────

class _LifeArea {
  final String label;
  final int value;
  const _LifeArea({required this.label, required this.value});
}