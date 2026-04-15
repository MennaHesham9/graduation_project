import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CoachClientsScreen extends StatelessWidget {
  const CoachClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF4F6F8);

    final clients = const <_ClientCardData>[
      _ClientCardData(
        name: 'Sarah Johnson',
        sessions: 12,
        status: 'Active',
        statusColor: Color(0xFF22C55E),
        progress: 0.75,
        nextSessionLeft: 'Next Session',
        nextSessionRight: 'Today, 2:00 PM',
      ),
      _ClientCardData(
        name: 'James Miller',
        sessions: 8,
        status: 'Active',
        statusColor: Color(0xFF22C55E),
        progress: 0.60,
        nextSessionLeft: 'Next Session',
        nextSessionRight: 'Today, 4:00 PM',
      ),
      _ClientCardData(
        name: 'Emma Davis',
        sessions: 15,
        status: 'Active',
        statusColor: Color(0xFF22C55E),
        progress: 0.85,
        nextSessionLeft: 'Next Session',
        nextSessionRight: 'Today, 6:00 PM',
      ),
      _ClientCardData(
        name: 'Michael Brown',
        sessions: 5,
        status: 'Paused',
        statusColor: Color(0xFF9CA3AF),
        progress: 0.40,
        nextSessionLeft: 'Next Session',
        nextSessionRight: 'Not scheduled',
      ),
    ];

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(
              title: 'My Clients',
              onFilter: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filter')),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: _SearchField(
                hintText: 'Search clients...',
                onChanged: (_) {},
              ),
            ),
            const SizedBox(height: 2),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: clients.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) => _ClientCard(data: clients[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onFilter;

  const _TopBar({
    required this.title,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: Colors.black.withValues(alpha: 0.76),
              ),
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.black.withValues(alpha: 0.82),
                  ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onFilter,
              borderRadius: BorderRadius.circular(999),
              child: Ink(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  size: 18,
                  color: Colors.black.withValues(alpha: 0.72),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black.withValues(alpha: 0.78),
          ),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        hintText: hintText,
        hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black.withValues(alpha: 0.35),
            ),
        prefixIcon: Icon(Icons.search_rounded, color: Colors.black.withValues(alpha: 0.35), size: 20),
        prefixIconConstraints: const BoxConstraints(minWidth: 42, minHeight: 40),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
    );
  }
}

class _ClientCardData {
  final String name;
  final int sessions;
  final String status;
  final Color statusColor;
  final double progress;
  final String nextSessionLeft;
  final String nextSessionRight;

  const _ClientCardData({
    required this.name,
    required this.sessions,
    required this.status,
    required this.statusColor,
    required this.progress,
    required this.nextSessionLeft,
    required this.nextSessionRight,
  });
}

class _ClientCard extends StatelessWidget {
  final _ClientCardData data;

  const _ClientCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final pct = (data.progress * 100).round();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          children: [
            Row(
              children: [
                _Avatar(name: data.name),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Colors.black.withValues(alpha: 0.82),
                            ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _MiniStat(
                            icon: Icons.calendar_today_outlined,
                            text: '${data.sessions}\nSessions',
                          ),
                          const SizedBox(width: 10),
                          _StatusPill(
                            text: data.status,
                            color: data.statusColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Open chat with ${data.name}')),
                    ),
                    borderRadius: BorderRadius.circular(999),
                    child: Ink(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF7F8),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFBFE9ED)),
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Overall Progress',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.black.withValues(alpha: 0.55),
                      ),
                ),
                const Spacer(),
                Text(
                  '$pct',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF22C55E),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Container(
                height: 6,
                color: Colors.black.withValues(alpha: 0.07),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: data.progress.clamp(0, 1),
                  child: Container(
                    color: const Color(0xFF2EC4B6),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF7F8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFE9ED)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Text(
                    data.nextSessionLeft,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    data.nextSessionRight,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;

  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().split(' ').where((p) => p.isNotEmpty).take(2).map((p) => p[0]).join();
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      alignment: Alignment.center,
      child: Text(
        initials.toUpperCase(),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.black.withValues(alpha: 0.55),
            ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniStat({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.black.withValues(alpha: 0.38)),
        const SizedBox(width: 6),
        Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.black.withValues(alpha: 0.55),
                height: 1.1,
              ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusPill({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}