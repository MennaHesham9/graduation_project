import 'package:flutter/material.dart';

class SelectPlanScreen extends StatefulWidget {
  const SelectPlanScreen({super.key});

  @override
  State<SelectPlanScreen> createState() => _SelectPlanScreenState();
}

class _SelectPlanScreenState extends State<SelectPlanScreen> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    final sheetWidth = w < 420 ? w - 40 : 360.0;
    final topPadding = (h * 0.06).clamp(18.0, 40.0);

    const teal = Color(0xFF1B9AAA);

    final plans = <_PlanData>[
      const _PlanData(
        title: 'Single Session',
        subtitle: 'Perfect for trying out coaching',
        price: 75,
        priceNote: 'total',
        perSession: null,
        sessions: 1,
        validity: 'Valid for 90 days',
        mostPopular: false,
        savingsText: null,
      ),
      const _PlanData(
        title: '4 Session Package',
        subtitle: 'Most popular choice for beginners',
        price: 280,
        priceNote: 'total',
        perSession: '\$70 per session',
        sessions: 4,
        validity: 'Valid for 90 days',
        mostPopular: true,
        savingsText: 'Save \$20 compared to individual\nsessions',
      ),
      const _PlanData(
        title: '8 Session Package',
        subtitle: 'Best value for committed growth',
        price: 520,
        priceNote: 'total',
        perSession: '\$65 per session',
        sessions: 8,
        validity: 'Valid for 90 days',
        mostPopular: false,
        savingsText: 'Save \$80 compared to individual\nsessions',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            width: sheetWidth,
            margin: EdgeInsets.only(top: topPadding, bottom: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
                    child: Row(
                      children: [
                        _CircleIconButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () => Navigator.maybePop(context),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select a Plan',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black.withValues(alpha: 0.86),
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Choose the best plan for your journey',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black.withValues(alpha: 0.45),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.03),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: Column(
                        children: [
                          for (int i = 0; i < plans.length; i++) ...[
                            _PlanCard(
                              data: plans[i],
                              selected: _selectedIndex == i,
                              accent: teal,
                              onTap: () => setState(() => _selectedIndex = i),
                            ),
                            if (i != plans.length - 1) const SizedBox(height: 14),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          final chosen = plans[_selectedIndex].title;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Selected: $chosen')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: teal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
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
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black.withValues(alpha: 0.10)),
          ),
          child: Icon(
            icon,
            size: 16,
            color: Colors.black.withValues(alpha: 0.78),
          ),
        ),
      ),
    );
  }
}

class _PlanData {
  final String title;
  final String subtitle;
  final int price;
  final String priceNote;
  final String? perSession;
  final int sessions;
  final String validity;
  final bool mostPopular;
  final String? savingsText;

  const _PlanData({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.priceNote,
    required this.perSession,
    required this.sessions,
    required this.validity,
    required this.mostPopular,
    required this.savingsText,
  });
}

class _PlanCard extends StatelessWidget {
  final _PlanData data;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  const _PlanCard({
    required this.data,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF2F80ED);

    final borderColor = selected ? accent : Colors.transparent;
    final shadowAlpha = selected ? 0.14 : 0.10;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Ink(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: shadowAlpha),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.title,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black.withValues(alpha: 0.82),
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              data.subtitle,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black.withValues(alpha: 0.45),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      if (selected)
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: accent, width: 1.5),
                          ),
                          child: Icon(Icons.check_rounded, size: 16, color: accent),
                        )
                      else
                        const SizedBox(width: 22, height: 22),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${data.price}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: Colors.black.withValues(alpha: 0.86),
                              height: 0.95,
                            ),
                      ),
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          data.priceNote,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.black.withValues(alpha: 0.45),
                              ),
                        ),
                      ),
                    ],
                  ),
                  if (data.perSession != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      data.perSession!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: blue,
                          ),
                    ),
                  ],
                  if (data.savingsText != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFFCF3),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFBFECCD)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.bolt_rounded,
                            size: 16,
                            color: const Color(0xFF2ECC71).withValues(alpha: 0.95),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              data.savingsText!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF2A7B4B),
                                    height: 1.15,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    height: 1,
                    color: Colors.black.withValues(alpha: 0.06),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        '${data.sessions} Session${data.sessions == 1 ? '' : 's'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.black.withValues(alpha: 0.55),
                            ),
                      ),
                      const Spacer(),
                      Text(
                        data.validity,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.black.withValues(alpha: 0.40),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (data.mostPopular)
          Positioned(
            top: -10,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFF7A3D),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department_rounded, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    'Most Popular',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

