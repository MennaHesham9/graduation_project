// lib/features/client/screens/mood_tracking.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mood_provider.dart';
import '../models/mood_entry_model.dart';

// ── Mood palette ──────────────────────────────────────────────────────────────
class _MoodOption {
  final String emoji;
  final String label;
  final int value;
  const _MoodOption({required this.emoji, required this.label, required this.value});
}

const List<_MoodOption> _kMoods = [
  _MoodOption(emoji: '😢', label: 'Very Sad', value: 0),
  _MoodOption(emoji: '😕', label: 'Sad',      value: 1),
  _MoodOption(emoji: '😐', label: 'Neutral',  value: 2),
  _MoodOption(emoji: '🙂', label: 'Good',     value: 3),
  _MoodOption(emoji: '😊', label: 'Great',    value: 4),
];

// ─────────────────────────────────────────────────────────────────────────────
class MoodTrackingScreen extends StatefulWidget {
  const MoodTrackingScreen({super.key});

  @override
  State<MoodTrackingScreen> createState() => _MoodTrackingScreenState();
}

class _MoodTrackingScreenState extends State<MoodTrackingScreen> {
  int _selectedMoodIndex = 3;
  final TextEditingController _noteController = TextEditingController();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final mp = context.read<MoodProvider>();
    await mp.fetchEntries();
    final today = mp.todayEntry;
    if (today != null && mounted) {
      setState(() {
        _selectedMoodIndex = today.moodValue;
        _noteController.text = today.note;
      });
    }
    if (mounted) setState(() => _initialized = true);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final mood = _kMoods[_selectedMoodIndex];
    final mp   = context.read<MoodProvider>();
    final wasUpdate = mp.todayEntry != null;

    final ok = await mp.saveTodayEntry(
      moodValue: mood.value,
      moodLabel: mood.label,
      moodEmoji: mood.emoji,
      note:      _noteController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(ok ? Icons.check_circle_outline : Icons.error_outline,
              color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(ok
              ? (wasUpdate ? 'Mood entry updated!' : 'Mood entry saved!')
              : (mp.errorMsg ?? 'Failed to save.')),
        ]),
        backgroundColor: ok ? const Color(0xFF1EAABB) : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    if (!ok) mp.clearError();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        child: Column(children: [
          _buildAppBar(),
          Expanded(
            child: Consumer<MoodProvider>(
              builder: (ctx, mp, _) {
                if (mp.isLoading && !_initialized) {
                  return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF1EAABB)));
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (mp.todayEntry != null) _buildTodayBanner(mp.todayEntry!),
                      if (mp.todayEntry != null) const SizedBox(height: 12),
                      _buildMoodSelectorCard(),
                      const SizedBox(height: 14),
                      _buildMindCard(),
                      const SizedBox(height: 14),
                      _buildRecentEntries(mp),
                      const SizedBox(height: 80),
                    ],
                  ),
                );
              },
            ),
          ),
        ]),
      ),
      bottomNavigationBar: _buildSaveButton(),
    );
  }

  Widget _buildAppBar() => Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 8),
        const Text('Mood Tracking',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E))),
      ]),
      const Padding(
        padding: EdgeInsets.only(left: 36),
        child: Text('How are you feeling today?',
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
      ),
    ]),
  );

  Widget _buildTodayBanner(MoodEntry entry) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFFE8F8FA),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF1EAABB).withValues(alpha:0.3)),
    ),
    child: Row(children: [
      const Icon(Icons.info_outline, size: 16, color: Color(0xFF1EAABB)),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          "You already logged today's mood (${entry.moodEmoji} ${entry.moodLabel}). "
              'Saving will update it.',
          style: const TextStyle(fontSize: 12, color: Color(0xFF1EAABB)),
        ),
      ),
    ]),
  );

  Widget _buildMoodSelectorCard() => _WhiteCard(
    child: Column(children: [
      const Text('Select Your Mood',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E))),
      const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_kMoods.length, (i) {
          final selected = _selectedMoodIndex == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedMoodIndex = i),
            child: AnimatedScale(
              scale: selected ? 1.25 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Column(children: [
                Text(_kMoods[i].emoji,
                    style: TextStyle(fontSize: selected ? 38 : 30)),
                const SizedBox(height: 6),
                Text(_kMoods[i].label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected
                          ? const Color(0xFF1EAABB)
                          : const Color(0xFF9CA3AF),
                    )),
              ]),
            ),
          );
        }),
      ),
      const SizedBox(height: 20),
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor:   const Color(0xFF1EAABB),
          inactiveTrackColor: const Color(0xFFE5E7EB),
          thumbColor:         const Color(0xFF1EAABB),
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          trackHeight: 4,
        ),
        child: Slider(
          value: _selectedMoodIndex.toDouble(),
          min: 0, max: 4, divisions: 4,
          onChanged: (v) => setState(() => _selectedMoodIndex = v.round()),
        ),
      ),
    ]),
  );

  Widget _buildMindCard() => _WhiteCard(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("What's on your mind?",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E))),
      const SizedBox(height: 12),
      TextField(
        controller: _noteController,
        maxLines: 4,
        style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E)),
        decoration: InputDecoration(
          hintText: "Share your thoughts, feelings,\nor what influenced your mood today...",
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFB0B8C1), height: 1.6),
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          contentPadding: const EdgeInsets.all(14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF1EAABB), width: 1.5)),
        ),
      ),
    ]),
  );

  Widget _buildRecentEntries(MoodProvider mp) {
    final entries = mp.entries;
    return _WhiteCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Recent Entries',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E))),
          const Row(children: [
            Icon(Icons.trending_up_rounded, color: Color(0xFF1EAABB), size: 16),
            SizedBox(width: 4),
            Text('View Trends',
                style: TextStyle(fontSize: 13, color: Color(0xFF1EAABB),
                    fontWeight: FontWeight.w500)),
          ]),
        ]),
        const SizedBox(height: 14),
        if (entries.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('No entries yet. Save your first mood!',
                  style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
            ),
          )
        else
          Column(
            children: List.generate(entries.length, (i) => Column(children: [
              _buildEntryRow(entries[i], mp),
              if (i < entries.length - 1)
                const Divider(height: 20, thickness: 0.8, color: Color(0xFFF3F4F6)),
            ])),
          ),
      ]),
    );
  }

  Widget _buildEntryRow(MoodEntry entry, MoodProvider mp) {
    final isToday = mp.todayEntry?.id == entry.id;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isToday ? const Color(0xFF1EAABB) : const Color(0xFFE5E7EB),
            width: isToday ? 1.5 : 1,
          ),
        ),
        child: Center(child: Text(entry.moodEmoji, style: const TextStyle(fontSize: 20))),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Text(entry.moodLabel,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E))),
              if (isToday) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1EAABB).withValues(alpha:0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Today',
                      style: TextStyle(fontSize: 10, color: Color(0xFF1EAABB),
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ]),
            Text(entry.displayDate,
                style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
          ]),
          if (entry.note.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(entry.note,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          ],
        ]),
      ),
      GestureDetector(
        onTap: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Delete Entry'),
              content: Text('Remove the entry for ${entry.displayDate}?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete',
                        style: TextStyle(color: Colors.redAccent))),
              ],
            ),
          );
          if (confirm == true && mounted) {
            await mp.deleteEntry(entry.id);
            if (isToday) setState(() { _selectedMoodIndex = 3; _noteController.clear(); });
          }
        },
        child: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: Icon(Icons.delete_outline, size: 18, color: Color(0xFFCBD5E1)),
        ),
      ),
    ]);
  }

  Widget _buildSaveButton() => Consumer<MoodProvider>(
    builder: (ctx, mp, _) {
      final isUpdate = mp.todayEntry != null;
      return Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.06),
              blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity, height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: mp.isSaving
                      ? [Colors.grey.shade400, Colors.grey.shade400]
                      : const [Color(0xFF1EAABB), Color(0xFF178A9A)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: ElevatedButton.icon(
                onPressed: mp.isSaving ? null : _save,
                icon: mp.isSaving
                    ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                    : Icon(isUpdate ? Icons.edit_outlined : Icons.save_outlined,
                    color: Colors.white, size: 18),
                label: Text(
                  mp.isSaving ? 'Saving...'
                      : isUpdate ? 'Update Mood Entry' : 'Save Mood Entry',
                  style: const TextStyle(color: Colors.white, fontSize: 15,
                      fontWeight: FontWeight.w600, letterSpacing: 0.3),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor:     Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────
class _WhiteCard extends StatelessWidget {
  final Widget child;
  const _WhiteCard({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.04),
          blurRadius: 10, offset: const Offset(0, 2))],
    ),
    child: child,
  );
}