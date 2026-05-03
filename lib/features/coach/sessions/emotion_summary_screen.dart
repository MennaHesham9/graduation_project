// lib/features/coach/sessions/emotion_summary_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/emotion_provider.dart';

/// Post-session screen shown to the coach immediately after the call ends.
///
/// Displays:
///   • Dominant emotion card
///   • Breakdown bar chart (one row per detected emotion)
///   • "Done" button that clears the navigation stack back to home
///
/// The screen is coach-only. The client never sees this data unless you
/// explicitly build a sharing flow.
class EmotionSummaryScreen extends StatelessWidget {
  final String bookingId;

  const EmotionSummaryScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return Consumer<EmotionProvider>(
      builder: (context, provider, _) {
        final summary = provider.sessionSummary;

        // Should not happen in normal flow, but guard defensively.
        if (summary == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Surface save error non-intrusively — the summary is still shown.
        final saveError = provider.error;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Session Summary'),
            backgroundColor: const Color(0xFF2F8F9D),
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false, // session is over; no back
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Save-error banner ──────────────────────────────────
                if (saveError != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
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
                            'Summary could not be saved to the cloud. '
                                'Your data is shown below.',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.orange.shade900),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Dominant emotion card ──────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2F8F9D).withValues(alpha:0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFF2F8F9D).withValues(alpha:0.3)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Client was mostly',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        summary.dominantEmotion.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2F8F9D),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Based on ${summary.totalReadings} readings',
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── Breakdown ─────────────────────────────────────────
                const Text(
                  'Emotion Breakdown',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Percentage of session time in each state',
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),

                if (summary.emotionPercentages.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No emotion data was collected.',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  )
                else
                  ...(() {
                    final entries = summary.emotionPercentages.entries.toList();
                    entries.sort((a, b) => b.value.compareTo(a.value));
                    return entries.map((entry) => _EmotionBar(
                      label: entry.key,
                      value: entry.value,
                    ));
                  })(),

                const SizedBox(height: 36),

                // ── Done ──────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F8F9D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Done',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmotionBar extends StatelessWidget {
  final String label;
  final double value; // 0.0–1.0

  const _EmotionBar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _capitalize(label),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                '${(value * 100).toStringAsFixed(0)}%',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF2F8F9D)),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}