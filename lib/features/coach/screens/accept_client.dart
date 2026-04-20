import 'package:flutter/material.dart';

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
      home: const ClientRequestScreen(),
    );
  }
}

class ClientRequestScreen extends StatelessWidget {
  const ClientRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // ── CONTAINER 1: App Bar ──
            // width:375, height:69, padding-left:20,
            // background:#FFFFFFE5, border-bottom:1px solid #EFF6FF
            _buildAppBar(context),

            // ── CONTAINER 2: Scrollable content ──
            // background: linear-gradient(135deg, #FAF5FF 0%, #EFF6FF 50%, #FDF2F8 100%)
            // padding: 24px top, 20px left/right, gap:20
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    transform: GradientRotation(135 * 3.14159 / 180),
                    colors: [
                      Color(0xFFFAF5FF),
                      Color(0xFFEFF6FF),
                      Color(0xFFFDF2F8),
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileCard(),
                      const SizedBox(height: 20),
                      _buildGoalsCard(),
                      const SizedBox(height: 20),
                      _buildPreSessionCard(),
                      const SizedBox(height: 20),
                      _buildNoteCard(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // ── CONTAINER 3: Bottom action buttons ──
            // height:169, padding:21 top, 20 left/right, gap:12
            // background:#FFFFFFF2, border-top:1px solid #EFF6FF
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // APP BAR
  // ─────────────────────────────────────────
  // ── CONTAINER 1 ──
  // width:375, height:69, gap:12, padding-left:20
  // background:#FFFFFFE5, border-bottom:1px solid #EFF6FF
  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: 69,
      padding: const EdgeInsets.fromLTRB(8, 0, 20, 0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withOpacity(0.898), // #FFFFFFE5
        border: const Border(
          bottom: BorderSide(color: Color(0xFFEFF6FF), width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 18, color: Color(0xFF1A1A2E)),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Client Request',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // PROFILE CARD
  // ─────────────────────────────────────────
  Widget _buildProfileCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar row
          Row(
            children: [
              // Avatar circle with initials
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF1EAABB),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    'SA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Name + location + badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sarah Anderson',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Icon(Icons.location_on_outlined,
                            size: 13, color: Color(0xFF9CA3AF)),
                        SizedBox(width: 2),
                        Text(
                          'San Francisco, CA • 34',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // New Request badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFF1EAABB).withOpacity(0.4),
                            width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.circle,
                              size: 6, color: Color(0xFF1EAABB)),
                          SizedBox(width: 5),
                          Text(
                            'New Request',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF1EAABB),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFEFF6FF)),
          const SizedBox(height: 16),

          // Date + Focus row
          Row(
            children: [
              // Mar 18 - Requested Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Mar 18',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Requested Date',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // Vertical divider
              Container(
                width: 1,
                height: 36,
                color: const Color(0xFFF0F0F0),
              ),

              const SizedBox(width: 16),

              // Career - Primary Focus
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Career',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Primary Focus',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // CLIENT GOALS CARD
  // ─────────────────────────────────────────
  Widget _buildGoalsCard() {
    final goals = [
      'Improve productivity',
      'Reduce stress',
      'Better work-life balance',
    ];

    final focusAreas = [
      'Career Growth',
      'Mental Health',
      'Time Management',
    ];

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            children: const [
              Icon(Icons.track_changes_rounded,
                  color: Color(0xFF1EAABB), size: 20),
              SizedBox(width: 8),
              Text(
                'Client Goals',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Goal pills
          ...goals.map((g) => _GoalTile(label: g)),

          const SizedBox(height: 14),

          // Focus Areas label
          const Text(
            'Focus Areas',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),

          // Focus area chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: focusAreas.map((f) => _FocusChip(label: f)).toList(),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // PRE-SESSION ANSWERS CARD
  // ─────────────────────────────────────────
  Widget _buildPreSessionCard() {
    return _Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(Icons.description_outlined,
                  color: Color(0xFF1EAABB), size: 20),
              SizedBox(width: 8),
              Text(
                'Pre-Session Answers',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {},
            child: const Text(
              'View All',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF1EAABB),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // NOTE FROM CLIENT CARD
  // ─────────────────────────────────────────
  Widget _buildNoteCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Note from Client',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FFFE),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: const Color(0xFFEFF6FF), width: 1),
            ),
            child: const Text(
              '"I\'m really looking forward to working with you. I\'ve been following your work and believe your approach aligns well with what I need right now."',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF4B5563),
                fontWeight: FontWeight.w400,
                height: 1.6,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // ACCEPT BUTTON
  // ─────────────────────────────────────────
  Widget _buildAcceptButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF1EAABB), Color(0xFF178A9A)],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.check_circle_outline_rounded,
                  color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Accept Client',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // REJECT BUTTON
  // ─────────────────────────────────────────
  Widget _buildRejectButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.cancel_outlined,
                color: Color(0xFFEF4444), size: 20),
            SizedBox(width: 8),
            Text(
              'Reject Request',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── CONTAINER 3 ──
  // width:390, height:169, gap:12, padding:21 top, 20 left/right
  // background:#FFFFFFF2, border-top:1px solid #EFF6FF
  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 21, 20, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withOpacity(0.949), // #FFFFFFF2
        border: const Border(
          top: BorderSide(color: Color(0xFFEFF6FF), width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAcceptButton(),
          const SizedBox(height: 12),
          _buildRejectButton(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// REUSABLE CARD WRAPPER
// ─────────────────────────────────────────────────────────────────
class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

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
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// GOAL TILE  (teal-tinted pill row)
// ─────────────────────────────────────────────────────────────────
class _GoalTile extends StatelessWidget {
  final String label;

  const _GoalTile({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDFF),
        borderRadius: BorderRadius.circular(10),
        border:
        Border.all(color: const Color(0xFF1EAABB).withOpacity(0.15), width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF1A1A2E),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// FOCUS CHIP  (small rounded badge)
// ─────────────────────────────────────────────────────────────────
class _FocusChip extends StatelessWidget {
  final String label;

  const _FocusChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        border:
        Border.all(color: const Color(0xFF1EAABB).withOpacity(0.3), width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF1EAABB),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}