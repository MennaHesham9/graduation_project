// lib/features/coach/screens/coach_customize_questionnaire_screen.dart
//
// Coach builds / edits a pre-session questionnaire and sends it to one client.
// Pass [existingId] + [existingModel] to load an existing questionnaire for editing.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/notification_service.dart';
import '../../questionnaire/models/questionnaire_model.dart';
import '../../questionnaire/services/questionnaire_service.dart';
import '../../client/models/coaching_request_model.dart';

class CoachCustomizeQuestionnaireScreen extends StatefulWidget {
  /// Pass a client to send the questionnaire directly to them.
  final CoachingRequestModel? client;

  /// If editing an existing questionnaire, supply it here.
  final QuestionnaireModel? existing;

  const CoachCustomizeQuestionnaireScreen({
    super.key,
    this.client,
    this.existing,
  });

  @override
  State<CoachCustomizeQuestionnaireScreen> createState() =>
      _CoachCustomizeQuestionnaireScreenState();
}

class _CoachCustomizeQuestionnaireScreenState
    extends State<CoachCustomizeQuestionnaireScreen> {
  final _service = QuestionnaireService();

  late final TextEditingController _titleController;
  late final List<TextEditingController> _questionControllers;
  late final List<String> _selectedTypes;
  /// Parallel list of choice lists, one per question.
  /// Only used when selectedType is 'Multiple Choice'.
  late final List<List<TextEditingController>> _choiceControllers;
  bool _isSending = false;

  static const List<String> _answerTypes = [
    'Multiple Choice',
    'Short Answer',
    'Scale 1–10',
    'Yes / No',
    'Long Answer',
  ];

  @override
  void initState() {
    super.initState();
    final ex = widget.existing;
    _titleController = TextEditingController(
        text: ex?.title ?? 'Pre-Session Check-In');
    if (ex != null && ex.questions.isNotEmpty) {
      _questionControllers =
          ex.questions.map((q) => TextEditingController(text: q.text)).toList();
      _selectedTypes = ex.questions.map((q) => q.type.label).toList();
      _choiceControllers = ex.questions.map((q) {
        if (q.choices.isNotEmpty) {
          return q.choices.map((c) => TextEditingController(text: c)).toList();
        }
        return <TextEditingController>[
          TextEditingController(),
          TextEditingController(),
        ];
      }).toList();
    } else {
      _questionControllers = [
        TextEditingController(text: 'How are you feeling today?'),
        TextEditingController(text: 'What would you like to focus on?'),
        TextEditingController(text: 'Rate your current motivation level'),
      ];
      _selectedTypes = ['Multiple Choice', 'Multiple Choice', 'Scale 1–10'];
      _choiceControllers = [
        [TextEditingController(), TextEditingController()],
        [TextEditingController(), TextEditingController()],
        <TextEditingController>[],
      ];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (final c in _questionControllers) c.dispose();
    for (final list in _choiceControllers) {
      for (final c in list) c.dispose();
    }
    super.dispose();
  }

  // ── Add / remove ──────────────────────────────────────────────────────────

  void _addQuestion() => setState(() {
    _questionControllers.add(TextEditingController());
    _selectedTypes.add(_answerTypes.first);
    _choiceControllers.add([TextEditingController(), TextEditingController()]);
  });

  void _removeQuestion(int i) {
    if (_questionControllers.length <= 1) return;
    setState(() {
      _questionControllers[i].dispose();
      _questionControllers.removeAt(i);
      _selectedTypes.removeAt(i);
      for (final c in _choiceControllers[i]) c.dispose();
      _choiceControllers.removeAt(i);
    });
  }

  void _addChoice(int questionIndex) {
    setState(() => _choiceControllers[questionIndex].add(TextEditingController()));
  }

  void _removeChoice(int questionIndex, int choiceIndex) {
    if (_choiceControllers[questionIndex].length <= 2) return;
    setState(() {
      _choiceControllers[questionIndex][choiceIndex].dispose();
      _choiceControllers[questionIndex].removeAt(choiceIndex);
    });
  }

  // ── Build questions list ──────────────────────────────────────────────────

  List<QuestionnaireQuestion> _buildQuestions() {
    return List.generate(_questionControllers.length, (i) {
      final isMultiple = _selectedTypes[i] == 'Multiple Choice';
      final choices = isMultiple
          ? _choiceControllers[i]
              .map((c) => c.text.trim())
              .where((s) => s.isNotEmpty)
              .toList()
          : <String>[];
      return QuestionnaireQuestion(
        text: _questionControllers[i].text.trim(),
        type: QuestionType.fromLabel(_selectedTypes[i]),
        choices: choices,
      );
    });
  }

  // ── Send ──────────────────────────────────────────────────────────────────

  Future<void> _send(BuildContext context) async {
    final client = widget.client;
    if (client == null) {
      _snack(context, 'No client selected', isError: true);
      return;
    }
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _snack(context, 'Please enter a title', isError: true);
      return;
    }
    final questions = _buildQuestions();
    if (questions.any((q) => q.text.isEmpty)) {
      _snack(context, 'Please fill in all questions', isError: true);
      return;
    }
    for (int i = 0; i < questions.length; i++) {
      if (questions[i].type == QuestionType.multipleChoice &&
          questions[i].choices.length < 2) {
        _snack(context, 'Question ${i + 1}: Add at least 2 choices', isError: true);
        return;
      }
    }

    setState(() => _isSending = true);
    try {
      final coachId = FirebaseAuth.instance.currentUser!.uid;
      // Fetch coach name from Firestore users doc
      final coachDoc = await FirebaseAuth.instance.currentUser != null
          ? null
          : null;
      // Use display name as fallback
      final coachName =
          FirebaseAuth.instance.currentUser?.displayName ?? 'Your Coach';

      if (widget.existing != null) {
        // Editing mode
        await _service.updateQuestionnaire(
          questionnaireId: widget.existing!.id,
          title: title,
          questions: questions,
          clientId: client.clientId,
          coachName: coachName,
        );
        if (mounted) {
          _snack(context, 'Questionnaire updated & client notified');
          Navigator.pop(context, true);
        }
      } else {
        // New questionnaire
        await _service.sendQuestionnaire(
          coachId: coachId,
          coachName: client.coachName.isNotEmpty ? client.coachName : coachName,
          clientId: client.clientId,
          clientName: client.clientName,
          title: title,
          questions: questions,
        );
        if (mounted) {
          _snack(context, 'Questionnaire sent to ${client.clientName}!');
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) _snack(context, 'Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _snack(BuildContext context, String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red.shade600 : AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 3),
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context, isEditing),
          Expanded(child: _buildScrollBody(context)),
          _buildBottomBar(context, isEditing),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isEditing) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.9),
        border: const Border(bottom: BorderSide(color: Color(0xFFF3E8FF))),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: Color(0xFF101828)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Edit Questionnaire' : 'Send Questionnaire',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600,
                      color: Color(0xFF101828)),
                ),
                if (widget.client != null)
                  Text(
                    'For: ${widget.client!.clientName}',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6A7282)),
                  ),
              ],
            ),
          ),
          // Preview button
          GestureDetector(
            onTap: () => _showPreview(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.visibility_outlined, size: 16, color: AppColors.primary),
                  SizedBox(width: 4),
                  Text('Preview', style: TextStyle(fontSize: 13, color: AppColors.primary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollBody(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.95, -1.0),
          end: Alignment(0.95, 1.0),
          colors: [Color(0xFFFAF5FF), Color(0xFFEFF6FF), Color(0xFFFDF2F8)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          // Title card
          _buildTitleCard(),
          const SizedBox(height: 20),
          // Section header
          Row(
            children: [
              const Expanded(
                child: Text('Questions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                        color: Color(0xFF101828))),
              ),
              Text('${_questionControllers.length} question${_questionControllers.length == 1 ? '' : 's'}',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF6A7282))),
            ],
          ),
          const SizedBox(height: 16),
          // Question cards
          ...List.generate(_questionControllers.length, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _QuestionCard(
              index: i,
              controller: _questionControllers[i],
              selectedType: _selectedTypes[i],
              answerTypes: _answerTypes,
              choiceControllers: _choiceControllers[i],
              onTypeChanged: (val) => setState(() => _selectedTypes[i] = val),
              onDelete: () => _removeQuestion(i),
              onAddChoice: () => _addChoice(i),
              onRemoveChoice: (ci) => _removeChoice(i, ci),
            ),
          )),
          // Add question button
          GestureDetector(
            onTap: _addQuestion,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  const Color(0xFF2F8F9D).withValues(alpha:0.15),
                  const Color(0xFF20A8BC).withValues(alpha:0.15),
                ]),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha:0.3)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, size: 20, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Add Question',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,
                          color: AppColors.primary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3E8FF)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha:0.08), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Questionnaire Title',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                  color: Color(0xFF364153))),
          const SizedBox(height: 8),
          _PurpleInput(controller: _titleController, hint: 'Enter title'),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isEditing) {
    return Container(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Color(0xF2FFFFFF),
        border: Border(top: BorderSide(color: Color(0xFFF3E8FF))),
      ),
      child: SizedBox(
        height: 56,
        child: ElevatedButton.icon(
          onPressed: _isSending ? null : () => _send(context),
          icon: _isSending
              ? const SizedBox(
              width: 18, height: 18,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Icon(isEditing ? Icons.save_rounded : Icons.send_rounded,
              size: 18),
          label: Text(
            _isSending
                ? 'Saving...'
                : isEditing
                ? 'Save & Notify Client'
                : 'Send to ${widget.client?.clientName ?? 'Client'}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
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

  void _showPreview(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PreviewSheet(
        title: _titleController.text,
        questions: List.generate(_questionControllers.length, (i) =>
            _QuestionPreview(text: _questionControllers[i].text, type: _selectedTypes[i])),
      ),
    );
  }
}

// ─── Question Card widget ─────────────────────────────────────────────────────

class _QuestionCard extends StatelessWidget {
  final int index;
  final TextEditingController controller;
  final String selectedType;
  final List<String> answerTypes;
  final List<TextEditingController> choiceControllers;
  final ValueChanged<String> onTypeChanged;
  final VoidCallback onDelete;
  final VoidCallback onAddChoice;
  final ValueChanged<int> onRemoveChoice;

  const _QuestionCard({
    required this.index,
    required this.controller,
    required this.selectedType,
    required this.answerTypes,
    required this.choiceControllers,
    required this.onTypeChanged,
    required this.onDelete,
    required this.onAddChoice,
    required this.onRemoveChoice,
  });

  @override
  Widget build(BuildContext context) {
    final isMultiple = selectedType == 'Multiple Choice';
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3E8FF)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha:0.08),
              blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle dots
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (_) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(children: List.generate(2, (__) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  width: 3, height: 3,
                  decoration: BoxDecoration(
                      color: const Color(0xFF9CA3AF),
                      borderRadius: BorderRadius.circular(1.5)),
                ))),
              )),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24, height: 24,
                      decoration: const BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text('${index + 1}',
                          style: const TextStyle(fontSize: 12,
                              fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                    const SizedBox(width: 8),
                    Text('Question ${index + 1}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6A7282))),
                  ],
                ),
                const SizedBox(height: 10),
                _PurpleInput(controller: controller, hint: 'Enter your question...'),
                const SizedBox(height: 8),
                _AnswerTypeDropdown(
                    value: selectedType,
                    items: answerTypes,
                    onChanged: onTypeChanged),

                // ── Multiple Choice fields ──────────────────────────────
                if (isMultiple) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Choices',
                          style: TextStyle(fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6A7282))),
                      const Spacer(),
                      GestureDetector(
                        onTap: onAddChoice,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha:0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.add_rounded,
                                  size: 14, color: AppColors.primary),
                              SizedBox(width: 4),
                              Text('Add Choice',
                                  style: TextStyle(fontSize: 12,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(choiceControllers.length, (ci) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 20, height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary, width: 1.5),
                          ),
                          child: Center(
                            child: Text(String.fromCharCode(65 + ci),
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _PurpleInput(
                            controller: choiceControllers[ci],
                            hint: 'Choice ${ci + 1}',
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: choiceControllers.length > 2
                              ? () => onRemoveChoice(ci)
                              : null,
                          child: Icon(Icons.remove_circle_outline_rounded,
                              size: 18,
                              color: choiceControllers.length > 2
                                  ? Colors.red.shade300
                                  : Colors.grey.shade300),
                        ),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 36, height: 36,
              alignment: Alignment.center,
              child: const Icon(Icons.delete_outline_rounded,
                  size: 20, color: Color(0xFF9CA3AF)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared input widgets ─────────────────────────────────────────────────────

class _PurpleInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  const _PurpleInput({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 15, color: Color(0xFF101828)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 15, color: Color(0xFF9CA3AF)),
        filled: true,
        fillColor: const Color(0xFFFAF5FF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFF3E8FF))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFF3E8FF))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      ),
    );
  }
}

class _AnswerTypeDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  const _AnswerTypeDropdown(
      {required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              size: 20, color: Color(0xFF6A7282)),
          style: const TextStyle(fontSize: 14, color: Color(0xFF364153)),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(14),
          items: items.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: (val) { if (val != null) onChanged(val); },
        ),
      ),
    );
  }
}

// ─── Preview Sheet ────────────────────────────────────────────────────────────

class _QuestionPreview {
  final String text;
  final String type;
  const _QuestionPreview({required this.text, required this.type});
}

class _PreviewSheet extends StatelessWidget {
  final String title;
  final List<_QuestionPreview> questions;
  const _PreviewSheet({required this.title, required this.questions});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(child: Text(title.isEmpty ? 'Questionnaire Preview' : title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
                GestureDetector(onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close_rounded, size: 22, color: Color(0xFF6A7282))),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Align(alignment: Alignment.centerLeft,
                child: Text('Preview as your client will see it',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6A7282)))),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              shrinkWrap: true,
              itemCount: questions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final q = questions[i];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF5FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFF3E8FF)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(width: 22, height: 22,
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: Text('${i + 1}', style: const TextStyle(fontSize: 11,
                              fontWeight: FontWeight.w700, color: Colors.white))),
                      const SizedBox(width: 8),
                      Expanded(child: Text(q.text.isEmpty ? 'Question ${i + 1}' : q.text,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                    ]),
                    const SizedBox(height: 8),
                    Container(height: 38, padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFDBEAFE))),
                        child: Row(children: [
                          Text(q.type, style: const TextStyle(fontSize: 13, color: Color(0xFF6A7282))),
                          const Spacer(),
                          const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF9CA3AF)),
                        ])),
                  ]),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.of(context).padding.bottom + 16),
            child: SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white, elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('Close Preview',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}