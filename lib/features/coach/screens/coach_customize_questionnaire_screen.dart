
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CoachCustomizeQuestionnaireScreen extends StatefulWidget {
  const CoachCustomizeQuestionnaireScreen({super.key});

  @override
  State<CoachCustomizeQuestionnaireScreen> createState() =>
      _CoachCustomizeQuestionnaireScreenState();
}

class _CoachCustomizeQuestionnaireScreenState
    extends State<CoachCustomizeQuestionnaireScreen> {
  // Title controller
  final _titleController =
  TextEditingController(text: 'Pre-Session Check-In');

  // Question text controllers
  final List<TextEditingController> _questionControllers = [
    TextEditingController(text: 'How are you feeling today?'),
    TextEditingController(text: 'What would you like to focus on?'),
    TextEditingController(text: 'Rate your current motivation level'),
  ];

  // Selected answer-type per question (index into _answerTypes)
  final List<String> _selectedTypes = [
    'Multiple Choice',
    'Multiple Choice',
    'Scale 1–10',
  ];

  static const List<String> _answerTypes = [
    'Multiple Choice',
    'Short Answer',
    'Scale 1–10',
    'Yes / No',
    'Long Answer',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    for (final c in _questionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // ─── Add / Remove question ────────────────────────────────────────────────

  void _addQuestion() {
    setState(() {
      _questionControllers.add(TextEditingController());
      _selectedTypes.add(_answerTypes.first);
    });
  }

  void _removeQuestion(int index) {
    if (_questionControllers.length <= 1) return;
    setState(() {
      _questionControllers[index].dispose();
      _questionControllers.removeAt(index);
      _selectedTypes.removeAt(index);
    });
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  void _sendToClient(BuildContext context) {
    _showSnack(context, 'Questionnaire sent to client');
  }

  void _showPreview(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PreviewSheet(
        title: _titleController.text,
        questions: List.generate(
          _questionControllers.length,
              (i) => _QuestionPreview(
            text: _questionControllers[i].text,
            type: _selectedTypes[i],
          ),
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(child: _buildScrollBody(context)),
        _buildBottomActions(context),
      ],
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFF3E8FF), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20 ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: const SizedBox(
              width: 36,
              height: 36,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: Color(0xFF101828),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Customize Questionnaire',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF101828),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Scrollable body ──────────────────────────────────────────────────────

  Widget _buildScrollBody(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.95, -1.0),
          end: Alignment(0.95, 1.0),
          colors: [
            Color(0xFFFAF5FF),
            Color(0xFFEFF6FF),
            Color(0xFFFDF2F8),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          // ── Title card ──────────────────────────────────────────────────
          _buildTitleCard(),
          const SizedBox(height: 20),
          // ── Questions section header ─────────────────────────────────────
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Questions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF101828),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _showPreview(context),
                child: Row(
                  children: const [
                    Icon(Icons.visibility_outlined,
                        size: 16, color: AppColors.primary),
                    SizedBox(width: 6),
                    Text(
                      'Show Preview',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // ── Question cards (dynamic) ─────────────────────────────────────
          ...List.generate(_questionControllers.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _QuestionCard(
                index: i,
                controller: _questionControllers[i],
                selectedType: _selectedTypes[i],
                answerTypes: _answerTypes,
                onTypeChanged: (val) =>
                    setState(() => _selectedTypes[i] = val),
                onDelete: () => _removeQuestion(i),
              ),
            );
          }),
          // ── Add Question button ──────────────────────────────────────────
          GestureDetector(
            onTap: _addQuestion,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: const Alignment(-0.75, -1.0),
                  end: const Alignment(0.75, 1.0),
                  colors: [
                    const Color(0xFF2F8F9D).withOpacity(0.2),
                    const Color(0xFF20A8BC).withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, size: 20, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    'Add Question',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Title card ────────────────────────────────────────────────────────────

  Widget _buildTitleCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(21, 21, 21, 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3E8FF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Questionnaire Title',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF364153),
            ),
          ),
          const SizedBox(height: 8),
          _PurpleInput(controller: _titleController, hint: 'Enter title'),
        ],
      ),
    );
  }

  // ─── Bottom action bar ─────────────────────────────────────────────────────

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 21, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xF2FFFFFF),
        border: Border(
          top: BorderSide(color: Color(0xFFF3E8FF), width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Send to Client
          GestureDetector(
            onTap: () => _sendToClient(context),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Color(0xFFEFF6FF),
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Send to Client',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFEFF6FF),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Question Card ────────────────────────────────────────────────────────────

class _QuestionCard extends StatelessWidget {
  final int index;
  final TextEditingController controller;
  final String selectedType;
  final List<String> answerTypes;
  final ValueChanged<String> onTypeChanged;
  final VoidCallback onDelete;

  const _QuestionCard({
    required this.index,
    required this.controller,
    required this.selectedType,
    required this.answerTypes,
    required this.onTypeChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(21, 21, 21, 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3E8FF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                    (_) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: List.generate(
                      2,
                          (__) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: const Color(0xFF9CA3AF),
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Main content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Number badge + label row
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Question ${index + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6A7282),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Question text input (purple style)
                _PurpleInput(
                  controller: controller,
                  hint: 'Enter your question...',
                ),
                const SizedBox(height: 8),
                // Answer type dropdown (blue style)
                _AnswerTypeDropdown(
                  value: selectedType,
                  items: answerTypes,
                  onChanged: onTypeChanged,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Delete button
          GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: const Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Purple-tinted Text Input ─────────────────────────────────────────────────

class _PurpleInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _PurpleInput({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF101828),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 16,
          color: const Color(0x000a0a0a).withOpacity(0.5),
        ),
        filled: true,
        fillColor: const Color(0xFFFAF5FF),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFF3E8FF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFF3E8FF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
          const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

// ─── Blue-tinted Answer Type Dropdown ─────────────────────────────────────────

class _AnswerTypeDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _AnswerTypeDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              size: 20, color: Color(0xFF6A7282)),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF364153),
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(14),
          items: items
              .map(
                (t) => DropdownMenuItem(
              value: t,
              child: Text(t),
            ),
          )
              .toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
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
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 32),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title.isEmpty ? 'Questionnaire Preview' : title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF101828),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close_rounded,
                      size: 22, color: Color(0xFF6A7282)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Preview as your client will see it',
              style: TextStyle(fontSize: 13, color: Color(0xFF6A7282)),
            ),
          ),
          const SizedBox(height: 20),
          Flexible(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              shrinkWrap: true,
              itemCount: questions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, i) {
                final q = questions[i];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF5FF),
                    borderRadius: BorderRadius.circular(14),
                    border:
                    Border.all(color: const Color(0xFFF3E8FF)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${i + 1}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              q.text.isEmpty
                                  ? 'Question ${i + 1}'
                                  : q.text,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF101828),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 40,
                        padding:
                        const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFFDBEAFE)),
                        ),
                        child: Row(
                          children: [
                            Text(
                              q.type,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6A7282),
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: Color(0xFF9CA3AF)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'Close Preview',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}