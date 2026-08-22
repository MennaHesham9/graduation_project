// lib/features/coach/widgets/coach_questionnaire_panel.dart
//
// Shown inside CoachClientProfileScreen. Lets the coach:
//   • Send a new questionnaire
//   • View answers for any answered questionnaire
//   • Edit a sent (not yet answered) questionnaire

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../client/models/coaching_request_model.dart';
import '../../questionnaire/models/questionnaire_model.dart';
import '../../questionnaire/services/questionnaire_service.dart';
import '../screens/coach_customize_questionnaire_screen.dart';

class CoachQuestionnairePanel extends StatelessWidget {
  final CoachingRequestModel client;

  const CoachQuestionnairePanel({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    final coachId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<List<QuestionnaireModel>>(
      stream: QuestionnaireService().streamForCoachClient(
        coachId: coachId,
        clientId: client.clientId,
      ),
      builder: (context, snap) {
        final questionnaires = snap.data ?? [];

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:0.8),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha:0.1),
                  blurRadius: 15, offset: const Offset(0, 10)),
              BoxShadow(color: Colors.black.withValues(alpha:0.1),
                  blurRadius: 6, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                    child: Row(
                      children: [
                        Icon(Icons.assignment_outlined,
                            size: 18, color: Color(0xFF6A7282)),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text('Pre-Session Questionnaire',
                              style: TextStyle(fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF101828)),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Send new questionnaire
                  GestureDetector(
                    onTap: () => _openSendScreen(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.send_rounded, size: 13, color: Colors.white),
                          SizedBox(width: 5),
                          Text('Send New',
                              style: TextStyle(fontSize: 12,
                                  color: Colors.white, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Loading
              if (snap.connectionState == ConnectionState.waiting)
                const Center(child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ))
              // Empty
              else if (questionnaires.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Icon(Icons.quiz_outlined, size: 40,
                          color: Colors.grey.shade300),
                      const SizedBox(height: 10),
                      const Text('No questionnaires sent yet',
                          style: TextStyle(fontSize: 14,
                              color: Color(0xFF6A7282))),
                      const SizedBox(height: 4),
                      Text('Tap "Send New" to create one for ${client.clientName}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12,
                              color: Color(0xFF9CA3AF))),
                    ],
                  ),
                )
              // List
              else
                ...questionnaires.map((q) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _QuestionnaireRow(
                    questionnaire: q,
                    onEdit: q.isAnswered
                        ? null
                        : () => _openEditScreen(context, q),
                    onViewAnswers: q.isAnswered
                        ? () => _showAnswers(context, q)
                        : null,
                  ),
                )),
            ],
          ),
        );
      },
    );
  }

  void _openSendScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CoachCustomizeQuestionnaireScreen(client: client),
      ),
    );
  }

  void _openEditScreen(BuildContext context, QuestionnaireModel existing) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CoachCustomizeQuestionnaireScreen(
          client: client,
          existing: existing,
        ),
      ),
    );
  }

  void _showAnswers(BuildContext context, QuestionnaireModel q) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AnswersSheet(questionnaire: q),
    );
  }
}

// ─── Single questionnaire row ─────────────────────────────────────────────────

class _QuestionnaireRow extends StatelessWidget {
  final QuestionnaireModel questionnaire;
  final VoidCallback? onEdit;
  final VoidCallback? onViewAnswers;

  const _QuestionnaireRow({
    required this.questionnaire,
    this.onEdit,
    this.onViewAnswers,
  });

  @override
  Widget build(BuildContext context) {
    final isAnswered = questionnaire.isAnswered;
    final dateStr = DateFormat('MMM d, yyyy').format(questionnaire.sentAt.toLocal());

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isAnswered
              ? const Color(0xFF00A63E).withValues(alpha:0.3)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: isAnswered
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isAnswered
                      ? Icons.check_circle_outline_rounded
                      : Icons.pending_outlined,
                  size: 20,
                  color: isAnswered
                      ? const Color(0xFF00A63E)
                      : const Color(0xFF155DFC),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(questionnaire.title,
                        style: const TextStyle(fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF101828)),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(
                      '${questionnaire.questions.length} questions · Sent $dateStr',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF6A7282)),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isAnswered
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isAnswered ? 'Answered' : 'Pending',
                  style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w500,
                    color: isAnswered
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFF54900),
                  ),
                ),
              ),
            ],
          ),

          // Action buttons
          if (onEdit != null || onViewAnswers != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (onViewAnswers != null)
                  Expanded(
                    child: GestureDetector(
                      onTap: onViewAnswers,
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00A63E).withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.visibility_outlined,
                                size: 15, color: Color(0xFF00A63E)),
                            SizedBox(width: 6),
                            Text('View Answers',
                                style: TextStyle(fontSize: 13,
                                    color: Color(0xFF00A63E),
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (onEdit != null)
                  Expanded(
                    child: GestureDetector(
                      onTap: onEdit,
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha:0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit_outlined,
                                size: 15, color: AppColors.primary),
                            SizedBox(width: 6),
                            Text('Edit',
                                style: TextStyle(fontSize: 13,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Answers bottom sheet ─────────────────────────────────────────────────────

class _AnswersSheet extends StatelessWidget {
  final QuestionnaireModel questionnaire;
  const _AnswersSheet({required this.questionnaire});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),

          // Title row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(questionnaire.title,
                          style: const TextStyle(fontSize: 18,
                              fontWeight: FontWeight.w700)),
                      Text(
                        'Answered by ${questionnaire.clientName}${questionnaire.answeredAt != null ? ' · ${DateFormat('MMM d').format(questionnaire.answeredAt!.toLocal())}' : ''}',
                        style: const TextStyle(fontSize: 13,
                            color: Color(0xFF6A7282)),
                      ),
                    ],
                  ),
                ),
                GestureDetector(onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close_rounded, size: 22,
                        color: Color(0xFF6A7282))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),

          // Answers list
          Flexible(
            child: StreamBuilder<QuestionnaireAnswer?>(
              stream: QuestionnaireService()
                  .streamAnswers(questionnaire.id),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ));
                }
                final answer = snap.data;
                if (answer == null) {
                  return const Center(child: Text('No answers found.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  itemCount: questionnaire.questions.length,
                  itemBuilder: (_, i) {
                    final q = questionnaire.questions[i];
                    final a = i < answer.answers.length
                        ? answer.answers[i]
                        : '—';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 22, height: 22,
                                  decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle),
                                  alignment: Alignment.center,
                                  child: Text('${i + 1}',
                                      style: const TextStyle(fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white)),
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(q.text,
                                    style: const TextStyle(fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF101828)))),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: const Color(0xFFDCFCE7)),
                              ),
                              child: Text(a.isEmpty ? '(No answer)' : a,
                                  style: const TextStyle(fontSize: 14,
                                      color: Color(0xFF101828), height: 1.5)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}