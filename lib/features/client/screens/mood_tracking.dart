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
      home: const MoodTrackingScreen(),
    );
  }
}

class MoodTrackingScreen extends StatefulWidget {
  const MoodTrackingScreen({super.key});

  @override
  State<MoodTrackingScreen> createState() => _MoodTrackingScreenState();
}

class _MoodTrackingScreenState extends State<MoodTrackingScreen> {
  int _selectedMoodIndex = 3; // default: Good
  final TextEditingController _noteController = TextEditingController();

  final List<_MoodOption> _moods = const [
    _MoodOption(emoji: '😢', label: 'Very Sad', value: 0),
    _MoodOption(emoji: '😕', label: 'Sad', value: 1),
    _MoodOption(emoji: '😐', label: 'Neutral', value: 2),
    _MoodOption(emoji: '🙂', label: 'Good', value: 3),
    _MoodOption(emoji: '😊', label: 'Great', value: 4),
  ];

  final List<_MoodEntry> _recentEntries = const [
    _MoodEntry(emoji: '🙂', mood: 'Good', note: 'Had a productive day at work', date: 'Dec 3'),
    _MoodEntry(emoji: '😐', mood: 'Neutral', note: 'Feeling neutral, nothing special', date: 'Dec 2'),
    _MoodEntry(emoji: '😊', mood: 'Great', note: 'Great session with my coach!', date: 'Dec 1'),
    _MoodEntry(emoji: '😕', mood: 'Sad', note: 'Stressed about upcoming deadline', date: 'Nov 30'),
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        child: Column(
          children: [
            // ── APP BAR ──
            _buildAppBar(),

            // ── SCROLLABLE CONTENT ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mood selector card
                    _buildMoodSelectorCard(),
                    const SizedBox(height: 14),

                    // What's on your mind
                    _buildMindCard(),
                    const SizedBox(height: 14),

                    // Recent entries
                    _buildRecentEntries(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ── BOTTOM SAVE BUTTON ──
      bottomNavigationBar: _buildSaveButton(),
    );
  }

  // ─────────────────────────────────────────
  // APP BAR
  // ─────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: Color(0xFF1A1A2E)),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              const Text(
                'Mood Tracking',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 36),
            child: Text(
              'How are you feeling today?',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // MOOD SELECTOR CARD
  // ─────────────────────────────────────────
  Widget _buildMoodSelectorCard() {
    return _WhiteCard(
      child: Column(
        children: [
          const Text(
            'Select Your Mood',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 20),

          // Emoji row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_moods.length, (i) {
              final selected = _selectedMoodIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedMoodIndex = i),
                child: AnimatedScale(
                  scale: selected ? 1.25 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Column(
                    children: [
                      Text(
                        _moods[i].emoji,
                        style: TextStyle(
                          fontSize: selected ? 38 : 30,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _moods[i].label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: selected
                              ? const Color(0xFF1EAABB)
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 20),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF1EAABB),
              inactiveTrackColor: const Color(0xFFE5E7EB),
              thumbColor: const Color(0xFF1EAABB),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              trackHeight: 4,
            ),
            child: Slider(
              value: _selectedMoodIndex.toDouble(),
              min: 0,
              max: 4,
              divisions: 4,
              onChanged: (v) =>
                  setState(() => _selectedMoodIndex = v.round()),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // WHAT'S ON YOUR MIND
  // ─────────────────────────────────────────
  Widget _buildMindCard() {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What's on your mind?",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            maxLines: 4,
            style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E)),
            decoration: InputDecoration(
              hintText:
              'Share your thoughts, feelings,\nor what influenced your mood today...',
              hintStyle: const TextStyle(
                fontSize: 13,
                color: Color(0xFFB0B8C1),
                height: 1.6,
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                const BorderSide(color: Color(0xFFE5E7EB), width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                const BorderSide(color: Color(0xFFE5E7EB), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                    color: Color(0xFF1EAABB), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // RECENT ENTRIES
  // ─────────────────────────────────────────
  Widget _buildRecentEntries() {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Entries',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: const [
                    Icon(Icons.trending_up_rounded,
                        color: Color(0xFF1EAABB), size: 16),
                    SizedBox(width: 4),
                    Text(
                      'View Trends',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1EAABB),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Entry list
          Column(
            children: List.generate(_recentEntries.length, (i) {
              final entry = _recentEntries[i];
              return Column(
                children: [
                  _buildEntryRow(entry),
                  if (i < _recentEntries.length - 1)
                    const Divider(
                      height: 20,
                      thickness: 0.8,
                      color: Color(0xFFF3F4F6),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryRow(_MoodEntry entry) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Emoji in rounded square
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
          ),
          child: Center(
            child: Text(entry.emoji, style: const TextStyle(fontSize: 20)),
          ),
        ),
        const SizedBox(width: 12),

        // Mood + note
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.mood,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  Text(
                    entry.date,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                entry.note,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  // SAVE BUTTON
  // ─────────────────────────────────────────
  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
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
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.save_outlined,
                  color: Colors.white, size: 18),
              label: const Text(
                'Save Mood Entry',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// WHITE CARD
// ─────────────────────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────────
class _MoodOption {
  final String emoji;
  final String label;
  final int value;
  const _MoodOption({required this.emoji, required this.label, required this.value});
}

class _MoodEntry {
  final String emoji;
  final String mood;
  final String note;
  final String date;
  const _MoodEntry({required this.emoji, required this.mood, required this.note, required this.date});
}