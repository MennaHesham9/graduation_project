// lib/features/questionnaire/screens/client_answer_questionnaire_screen.dart
//
// Shown to the client when they tap a pending questionnaire notification
// or the banner in client_sessions_screen.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../models/questionnaire_model.dart';
import '../services/questionnaire_service.dart';

class ClientAnswerQuestionnaireScreen extends StatefulWidget {
  final QuestionnaireModel questionnaire;

  const ClientAnswerQuestionnaireScreen({
    super.key,
    required this.questionnaire,
  });

  @override
  State<ClientAnswerQuestionnaireScreen> createState() =>
      _ClientAnswerQuestionnaireScreenState();
}

class _ClientAnswerQuestionnaireScreenState
    extends State<ClientAnswerQuestionnaireScreen> {
  final _service = QuestionnaireService();
  late final List<TextEditingController> _controllers;
  // For scale questions: integer 1-10
  late final List<int> _scaleValues;
  // For yes/no questions
  late final List<bool?> _yesNoValues;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final q = widget.questionnaire.questions;
    _controllers = List.generate(q.length, (_) => TextEditingController());
    _scaleValues = List.generate(q.length, (_) => 5);
    _yesNoValues = List.generate(q.length, (_) => null);
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  // ── Collect answers ───────────────────────────────────────────────────────

  List<String> _collectAnswers() {
    final q = widget.questionnaire.questions;
    return List.generate(q.length, (i) {
      switch (q[i].type) {
        case QuestionType.scale:
          return _scaleValues[i].toString();
        case QuestionType.yesNo:
          return _yesNoValues[i] == null
              ? ''
              : _yesNoValues[i]!
              ? 'Yes'
              : 'No';
        default:
          return _controllers[i].text.trim();
      }
    });
  }

  bool _hasUnanswered() {
    final answers = _collectAnswers();
    return answers.any((a) => a.isEmpty);
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (_hasUnanswered()) {
      _snack('Please answer all questions', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      // Fetch client name from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final clientName =
          (userDoc.data()?['name'] as String?) ?? user.displayName ?? 'Client';

      await _service.submitAnswers(
        questionnaireId: widget.questionnaire.id,
        clientId: user.uid,
        clientName: clientName,
        coachId: widget.questionnaire.coachId,
        coachName: widget.questionnaire.coachName,
        answers: _collectAnswers(),
      );

      if (mounted) {
        _snack('Answers submitted! Your coach has been notified.');
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) _snack('Error submitting: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red.shade600 : AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final q = widget.questionnaire;
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context, q),
          Expanded(child: _buildBody(context, q)),
          _buildSubmitBar(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, QuestionnaireModel q) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2F8F9D), Color(0xFF20A8BC)],
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha:0.15),
              blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20, right: 20, bottom: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 16, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              const Text('Pre-Session Questionnaire',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ],
          ),
          const SizedBox(height: 16),
          Text(q.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Text('From ${q.coachName} · ${q.questions.length} questions',
              style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha:0.8))),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, QuestionnaireModel q) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.95, -1.0),
          end: Alignment(0.95, 1.0),
          colors: [Color(0xFFFAF5FF), Color(0xFFEFF6FF), Color(0xFFFDF2F8)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        itemCount: q.questions.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildQuestionCard(i, q.questions[i]),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int i, QuestionnaireQuestion q) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.85),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha:0.08),
              blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question number + text
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28, height: 28,
                decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text('${i + 1}',
                    style: const TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w700, color: Colors.white)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(q.text,
                        style: const TextStyle(fontSize: 15,
                            fontWeight: FontWeight.w500, color: Color(0xFF101828))),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(q.type.label,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF155DFC))),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Answer widget based on type
          _buildAnswerWidget(i, q.type),
        ],
      ),
    );
  }

  Widget _buildAnswerWidget(int i, QuestionType type) {
    switch (type) {
      case QuestionType.scale:
        return _buildScaleWidget(i);
      case QuestionType.yesNo:
        return _buildYesNoWidget(i);
      case QuestionType.longAnswer:
        return _buildTextField(i, maxLines: 5, hint: 'Write your answer here...');
      case QuestionType.shortAnswer:
        return _buildTextField(i, maxLines: 2, hint: 'Short answer...');
      case QuestionType.multipleChoice:
        return _buildTextField(i, maxLines: 2, hint: 'Your response...');
    }
  }

  Widget _buildTextField(int i,
      {required int maxLines, required String hint}) {
    return TextField(
      controller: _controllers[i],
      maxLines: maxLines,
      minLines: maxLines > 2 ? 3 : 1,
      style: const TextStyle(fontSize: 15, color: Color(0xFF101828)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      ),
    );
  }

  Widget _buildScaleWidget(int i) {
    final value = _scaleValues[i];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('1', style: TextStyle(fontSize: 13, color: Color(0xFF6A7282))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('$value',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
            const Text('10', style: TextStyle(fontSize: 13, color: Color(0xFF6A7282))),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: 1, max: 10, divisions: 9,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.primary.withValues(alpha:0.2),
          onChanged: (v) => setState(() => _scaleValues[i] = v.round()),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Very Low', style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
            Text('Very High', style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
          ],
        ),
      ],
    );
  }

  Widget _buildYesNoWidget(int i) {
    final selected = _yesNoValues[i];
    return Row(
      children: [
        Expanded(child: _YesNoChip(
          label: 'Yes',
          isSelected: selected == true,
          color: const Color(0xFF00A63E),
          bgColor: const Color(0xFFDCFCE7),
          onTap: () => setState(() => _yesNoValues[i] = true),
        )),
        const SizedBox(width: 12),
        Expanded(child: _YesNoChip(
          label: 'No',
          isSelected: selected == false,
          color: const Color(0xFFDC2626),
          bgColor: const Color(0xFFFEF2F2),
          onTap: () => setState(() => _yesNoValues[i] = false),
        )),
      ],
    );
  }

  Widget _buildSubmitBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: SizedBox(
        height: 56,
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _submit,
          icon: _isSubmitting
              ? const SizedBox(width: 18, height: 18,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.check_circle_outline_rounded, size: 20),
          label: Text(_isSubmitting ? 'Submitting...' : 'Submit Answers',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    );
  }
}

// ─── Yes/No chip ──────────────────────────────────────────────────────────────

class _YesNoChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _YesNoChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? bgColor : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE5E7EB),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected)
              Icon(Icons.check_circle_rounded, size: 18, color: color),
            if (isSelected) const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? color : const Color(0xFF6A7282),
                )),
          ],
        ),
      ),
    );
  }
}