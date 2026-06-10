// lib/features/coach/sessions/emotion_summary_screen.dart
//
// ── CHANGES ──────────────────────────────────────────────────────────────────
//
// NEW: Coach Notes section added below Key Insights.
//   • Pre-fills with any notes already saved on the session.
//   • "Save Notes" button persists to Firestore immediately.
//   • Works both right after a session AND when opened from Past Sessions.
//
// NEW: viewOnly mode — when opened from the Past Sessions card the screen
//   loads the EmotionSummary from Firestore rather than from the in-memory
//   EmotionProvider.  The notes field is still editable in both modes.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mindwell/features/coach/widgets/coach_nav_bar.dart';
import 'package:provider/provider.dart';

import '../../../core/models/emotion_summary.dart';
import '../../../core/providers/emotion_provider.dart';

/// Post-session screen shown to the coach.
///
/// Two modes:
///   • [viewOnly] == false (default) — reads EmotionSummary from the live
///     EmotionProvider (immediately after a session ends).
///   • [viewOnly] == true — loads the summary directly from Firestore
///     (used by Past Session cards on the coach-client profile).
class EmotionSummaryScreen extends StatefulWidget {
  final String bookingId;

  // Display metadata
  final String? clientName;
  final String? sessionCategory;
  final String? sessionDateLabel;

  /// When true the screen fetches data from Firestore instead of the provider.
  final bool viewOnly;

  const EmotionSummaryScreen({
    super.key,
    required this.bookingId,
    this.clientName,
    this.sessionCategory,
    this.sessionDateLabel,
    this.viewOnly = false,
  });

  @override
  State<EmotionSummaryScreen> createState() => _EmotionSummaryScreenState();
}

class _EmotionSummaryScreenState extends State<EmotionSummaryScreen> {
  // ── viewOnly state ─────────────────────────────────────────────────────────
  EmotionSummary? _loadedSummary;
  bool _loadingRemote = false;
  String? _loadError;

  // ── Notes state ────────────────────────────────────────────────────────────
  late final TextEditingController _notesController;
  bool _savingNotes = false;
  bool _notesSaved = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    if (widget.viewOnly) {
      _fetchFromFirestore();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // ── Fetch summary from Firestore (viewOnly mode) ───────────────────────────
  Future<void> _fetchFromFirestore() async {
    setState(() {
      _loadingRemote = true;
      _loadError = null;
    });
    try {
      final doc = await FirebaseFirestore.instance
          .collection('sessions')
          .doc(widget.bookingId)
          .get();
      final data = doc.data();
      if (data != null && data['emotionSummary'] != null) {
        final summary = EmotionSummary.fromMap(
            Map<String, dynamic>.from(data['emotionSummary'] as Map));
        _notesController.text = summary.coachNotes;
        setState(() => _loadedSummary = summary);
      } else {
        setState(() => _loadError = 'No emotion summary found for this session.');
      }
    } catch (e) {
      setState(() => _loadError = 'Could not load session summary: $e');
    } finally {
      setState(() => _loadingRemote = false);
    }
  }

  // ── Save notes to Firestore ────────────────────────────────────────────────
  Future<void> _saveNotes(EmotionSummary current) async {
    setState(() {
      _savingNotes = true;
      _notesSaved = false;
    });
    try {
      final updated = current.copyWith(coachNotes: _notesController.text.trim());
      await FirebaseFirestore.instance
          .collection('sessions')
          .doc(widget.bookingId)
          .update({'emotionSummary': updated.toMap()});
      // Also update local state so viewOnly mode reflects the save
      if (widget.viewOnly) {
        setState(() => _loadedSummary = updated);
      }
      setState(() => _notesSaved = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save notes: $e')),
        );
      }
    } finally {
      setState(() => _savingNotes = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (widget.viewOnly) {
      return _buildScaffold(context, _loadedSummary, _loadError);
    }

    return Consumer<EmotionProvider>(
      builder: (context, provider, _) {
        // Seed the notes controller once with any notes already on the provider
        if (_notesController.text.isEmpty &&
            (provider.sessionSummary?.coachNotes.isNotEmpty ?? false)) {
          _notesController.text = provider.sessionSummary!.coachNotes;
        }
        return _buildScaffold(
            context, provider.sessionSummary, provider.error);
      },
    );
  }

  Widget _buildScaffold(
      BuildContext context, EmotionSummary? summary, String? saveError) {
    if (_loadingRemote) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (summary == null && _loadError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Emotion Summary')),
        body: Center(child: Text(_loadError!)),
      );
    }

    if (summary == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Emotion Summary',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            Text(
              'Post-session analysis',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Save-error banner ────────────────────────────────────
            if (saveError != null) ...[
              _ErrorBanner(message: saveError),
              const SizedBox(height: 12),
            ],

            // ── Client info card ─────────────────────────────────────
            _ClientInfoCard(
              clientName: widget.clientName ?? 'Client',
              category: widget.sessionCategory ?? '',
              dateLabel: widget.sessionDateLabel ?? '',
            ),
            const SizedBox(height: 14),

            // ── Overall sentiment card ───────────────────────────────
            _SentimentCard(dominantEmotion: summary.dominantEmotion),
            const SizedBox(height: 14),

            // ── Emotion breakdown ────────────────────────────────────
            _BreakdownCard(percentages: summary.emotionPercentages),
            const SizedBox(height: 14),

            // ── Key insights ─────────────────────────────────────────
            const _InsightsCard(),
            const SizedBox(height: 14),

            // ── Coach Notes ──────────────────────────────────────────
            _CoachNotesCard(
              controller: _notesController,
              isSaving: _savingNotes,
              isSaved: _notesSaved,
              onSave: () => _saveNotes(summary),
            ),
            const SizedBox(height: 24),

            // ── Action buttons (only shown right after session) ──────
            if (!widget.viewOnly) ...[
              _ActionButtons(bookingId: widget.bookingId),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Coach Notes Card
// ─────────────────────────────────────────────────────────────────────────────

class _CoachNotesCard extends StatelessWidget {
  final TextEditingController controller;
  final bool isSaving;
  final bool isSaved;
  final VoidCallback onSave;

  const _CoachNotesCard({
    required this.controller,
    required this.isSaving,
    required this.isSaved,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.edit_note_rounded, size: 18, color: Color(0xFF2F8F9D)),
              SizedBox(width: 6),
              Text(
                'Coach Notes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Add private notes about this session. You can edit them any time.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: 5,
            minLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Write your observations, follow-up points, or anything relevant...',
              hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFFF8FFFE),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0F2F4)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0F2F4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF2F8F9D), width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isSaving ? null : onSave,
              icon: isSaving
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
                  : Icon(
                isSaved ? Icons.check_circle_outline : Icons.save_outlined,
                size: 18,
              ),
              label: Text(
                isSaving
                    ? 'Saving...'
                    : isSaved
                    ? 'Notes Saved'
                    : 'Save Notes',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSaved
                    ? const Color(0xFF34C759)
                    : const Color(0xFF2F8F9D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Unchanged sub-widgets (ErrorBanner, ClientInfoCard, SentimentCard,
// BreakdownCard, InsightsCard, ActionButtons)
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: Colors.orange.shade700, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Summary could not be saved to the cloud. Your data is shown below.',
              style: TextStyle(fontSize: 13, color: Colors.orange.shade900),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientInfoCard extends StatelessWidget {
  final String clientName;
  final String category;
  final String dateLabel;

  const _ClientInfoCard({
    required this.clientName,
    required this.category,
    required this.dateLabel,
  });

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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clientName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                if (category.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(category,
                      style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ],
                if (dateLabel.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(dateLabel,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF34C759),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Completed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SentimentCard extends StatelessWidget {
  final String dominantEmotion;
  const _SentimentCard({required this.dominantEmotion});

  _SentimentMeta _resolve(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
      case 'calm':
        return _SentimentMeta(
          label: 'Predominantly\nPositive',
          subtitle: '60% positive emotions detected throughout the session',
        );
      case 'sad':
      case 'tense':
        return _SentimentMeta(
          label: 'Predominantly\nNegative',
          subtitle: 'Higher negative emotion signals detected this session',
        );
      case 'distracted':
        return _SentimentMeta(
          label: 'Mostly\nDistracted',
          subtitle: 'Client appeared disengaged for much of the session',
        );
      default:
        return _SentimentMeta(
          label: 'Mixed\nSentiment',
          subtitle: 'A balanced mix of emotions detected this session',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final meta = _resolve(dominantEmotion);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2F8F9D), Color(0xFF1A6B78)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.auto_awesome, color: Colors.white70, size: 16),
              SizedBox(width: 6),
              Text(
                'Overall Sentiment',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            meta.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(meta.subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}

class _SentimentMeta {
  final String label;
  final String subtitle;
  const _SentimentMeta({required this.label, required this.subtitle});
}

class _BreakdownCard extends StatelessWidget {
  final Map<String, double> percentages;
  const _BreakdownCard({required this.percentages});

  static const Map<String, Color> _emotionColors = {
    'happy': Color(0xFFFFC300),
    'hopeful': Color(0xFF34C759),
    'calm': Color(0xFF5AC8FA),
    'anxious': Color(0xFFFF9500),
    'tense': Color(0xFFFF6B35),
    'sad': Color(0xFF5856D6),
    'distracted': Color(0xFFAF52DE),
    'neutral': Color(0xFF8E8E93),
    'frustrated': Color(0xFFD1D1D6),
  };

  Color _colorFor(String emotion) =>
      _emotionColors[emotion.toLowerCase()] ?? const Color(0xFF2F8F9D);

  @override
  Widget build(BuildContext context) {
    if (percentages.isEmpty) return const SizedBox.shrink();

    final sorted = percentages.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Emotion Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14),
          ...sorted.map((e) => _EmotionBar(
            label: e.key,
            value: e.value,
            color: _colorFor(e.key),
          )),
        ],
      ),
    );
  }
}

class _EmotionBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _EmotionBar({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _capitalize(label),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${(value * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _InsightsCard extends StatelessWidget {
  const _InsightsCard();

  static const List<String> _insights = [
    'Client showed increased positivity compared to last session (+12%)',
    'Anxiety levels remain elevated during career discussions',
    'Notable improvement in expressing hopeful emotions',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.trending_up_rounded, size: 18, color: Color(0xFF2F8F9D)),
              SizedBox(width: 6),
              Text(
                'Key Insights',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._insights.map((insight) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child:
                  Icon(Icons.circle, size: 8, color: Color(0xFF2F8F9D)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    insight,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final String bookingId;
  const _ActionButtons({required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CoachNavBar()),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black87,
              side: const BorderSide(color: Color(0xFFDEE2E6), width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text(
              'Back Home',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
