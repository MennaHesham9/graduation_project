// lib/features/coach/screens/presession_questionnaire_screen.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PresessionQuestionnaireScreen extends StatefulWidget {
  const PresessionQuestionnaireScreen({super.key});

  @override
  State<PresessionQuestionnaireScreen> createState() =>
      _PresessionQuestionnaireScreenState();
}

class _PresessionQuestionnaireScreenState
    extends State<PresessionQuestionnaireScreen> {

  // ── Template selection ────────────────────────────────────────────────────
  int _selectedTemplate = 0;

  final List<_TemplateData> _templates = const [
    _TemplateData(
      title: 'Standard Coaching Questionnaire',
      questionCount: 8,
      questions: [
        'How are you feeling today?',
        'What would you like to focus on in this session?',
        'Have you completed the tasks from our last session?',
        'What challenges have you faced this week?',
        'What wins would you like to celebrate?',
        'What support do you need from me today?',
        'How would you rate your energy levels (1–10)?',
        'Is there anything else you would like to share?',
      ],
    ),
    _TemplateData(
      title: 'Weekly Reflection',
      questionCount: 5,
      questions: [
        'What went well this week?',
        'What could have gone better?',
        'What did you learn about yourself?',
        'What is your top priority for next week?',
        'How are you feeling emotionally right now?',
      ],
    ),
    _TemplateData(
      title: 'Custom Questionnaire',
      questionCount: 6,
      questions: [
        'What is your current goal?',
        'What obstacles are in your way?',
        'What resources do you have available?',
        'How motivated are you feeling (1–10)?',
        'What action will you take before our next session?',
        'Any other thoughts you would like to share?',
      ],
    ),
  ];

  // ── Send settings ─────────────────────────────────────────────────────────
  bool _sendImmediately = true;

  void _onSend() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Questionnaire sent!'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ────────────────────────────────────────────────────
            _AppBar(onBack: () => Navigator.of(context).pop()),

            // ── Scrollable body ────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Sending To card ──────────────────────────────────
                    _WhiteCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sending to',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9EABB8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              // Avatar
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: AppColors.primary,
                                child: const Text(
                                  'MJ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Michael Johnson',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1A2533),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: const [
                                      Icon(Icons.calendar_today_outlined,
                                          size: 12,
                                          color: Color(0xFF9EABB8)),
                                      SizedBox(width: 4),
                                      Text(
                                        'Next session: Thu, Mar 20 • 2:00 PM',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF9EABB8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Select Template ──────────────────────────────────
                    _WhiteCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.description_outlined,
                                  size: 16, color: AppColors.primary),
                              const SizedBox(width: 6),
                              const Text(
                                'Select Template',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A2533),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Template options
                          ...List.generate(_templates.length, (index) {
                            final t = _templates[index];
                            final selected = _selectedTemplate == index;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedTemplate = index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? const Color(0xFFE8F5F7)
                                      : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.primary
                                        : const Color(0xFFE2E8F0),
                                    width: selected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            t.title,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: selected
                                                  ? AppColors.primary
                                                  : const Color(0xFF1A2533),
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            '${t.questionCount} questions',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF9EABB8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (selected)
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.check,
                                            size: 13, color: Colors.white),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }),

                          // Create custom template
                          GestureDetector(
                            onTap: () {},
                            child: Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add,
                                      size: 14, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Create Custom Template',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Questions Preview ────────────────────────────────
                    _WhiteCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Questions Preview',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A2533),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Text(
                                  'Edit',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Show first 4 questions of selected template
                          ...List.generate(
                            _templates[_selectedTemplate].questions
                                .take(4)
                                .length,
                                (index) {
                              final q = _templates[_selectedTemplate]
                                  .questions[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF0F9FA),
                                          borderRadius:
                                          BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          q,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF1A2533),
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          // "and X more" hint if template has >4 questions
                          if (_templates[_selectedTemplate].questionCount > 4)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Center(
                                child: Text(
                                  '+ ${_templates[_selectedTemplate].questionCount - 4} more questions',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Send Settings ────────────────────────────────────
                    _WhiteCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.settings_outlined,
                                  size: 16, color: AppColors.primary),
                              const SizedBox(width: 6),
                              const Text(
                                'Send Settings',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A2533),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Send Immediately',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1A2533),
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Client will receive it right away',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF9EABB8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _Toggle(
                                value: _sendImmediately,
                                onChanged: (val) =>
                                    setState(() => _sendImmediately = val),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Send Questionnaire button ─────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _onSend,
                        icon: const Icon(Icons.send_rounded, size: 18),
                        label: const Text(
                          'Send Questionnaire',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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
                    const SizedBox(height: 10),

                    // ── Cancel button ─────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5A6A7A),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App Bar
// ─────────────────────────────────────────────────────────────────────────────
class _AppBar extends StatelessWidget {
  final VoidCallback onBack;
  const _AppBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4F8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: Color(0xFF1A2533),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Send Pre-Session Questionnaire',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A2533),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated Toggle
// ─────────────────────────────────────────────────────────────────────────────
class _Toggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _Toggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 46,
        height: 26,
        decoration: BoxDecoration(
          color: value ? AppColors.primary : const Color(0xFFD1D9E0),
          borderRadius: BorderRadius.circular(13),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// White Card wrapper
// ─────────────────────────────────────────────────────────────────────────────
class _WhiteCard extends StatelessWidget {
  final Widget child;
  const _WhiteCard({required this.child});

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
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Template data model
// ─────────────────────────────────────────────────────────────────────────────
class _TemplateData {
  final String title;
  final int questionCount;
  final List<String> questions;

  const _TemplateData({
    required this.title,
    required this.questionCount,
    required this.questions,
  });
}