import 'package:flutter/material.dart';

class CoachClientsScreen extends StatefulWidget {
  const CoachClientsScreen({super.key});

  @override
  State<CoachClientsScreen> createState() => _CoachClientsScreenState();
}

class _CoachClientsScreenState extends State<CoachClientsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  final List<_ClientVm> _clients = const [
    _ClientVm(
      name: 'Sarah Johnson',
      sessions: 12,
      status: _ClientStatus.active,
      progress: 0.75,
      nextSession: 'Today, 2:00 PM',
      avatarColor: Color(0xFFBFAE9A),
    ),
    _ClientVm(
      name: 'James Miller',
      sessions: 8,
      status: _ClientStatus.active,
      progress: 0.60,
      nextSession: 'Today, 4:00 PM',
      avatarColor: Color(0xFFC9C1B6),
    ),
    _ClientVm(
      name: 'Emma Davis',
      sessions: 15,
      status: _ClientStatus.active,
      progress: 0.85,
      nextSession: 'Today, 6:00 PM',
      avatarColor: Color(0xFFBDA08A),
    ),
    _ClientVm(
      name: 'Michael Brown',
      sessions: 5,
      status: _ClientStatus.paused,
      progress: 0.40,
      nextSession: 'Not scheduled',
      avatarColor: Color(0xFFC8B9A6),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    final sheetWidth = w < 420 ? w - 40 : 360.0;
    final topPadding = (h * 0.05).clamp(16.0, 36.0);

    const bg = Color(0xFFE9E9E9);
    const teal = Color(0xFF1B9AAA);

    final filtered = _clients.where((c) {
      if (_query.trim().isEmpty) return true;
      return c.name.toLowerCase().contains(_query.trim().toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: Container(
            width: sheetWidth,
            margin: EdgeInsets.only(top: topPadding, bottom: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Column(
                children: [
                  _Header(
                    controller: _searchController,
                    onBack: () => Navigator.maybePop(context),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFF4FAFF), Color(0xFFF8F4FF)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, i) {
                          final c = filtered[i];
                          return _ClientCard(
                            data: c,
                            accent: teal,
                            onChat: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Open chat with ${c.name}')),
                              );
                            },
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Open profile: ${c.name}')),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onBack;
  final ValueChanged<String> onChanged;

  const _Header({
    required this.controller,
    required this.onBack,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _CircleIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: onBack,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'My Clients',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.black.withValues(alpha: 0.86),
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _SearchField(
            controller: controller,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black.withValues(alpha: 0.78),
          ),
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Search clients...',
        hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black.withValues(alpha: 0.35),
            ),
        prefixIcon: Icon(Icons.search_rounded, size: 18, color: Colors.black.withValues(alpha: 0.35)),
        prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.10)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1B9AAA), width: 1.4),
        ),
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final _ClientVm data;
  final Color accent;
  final VoidCallback onChat;
  final VoidCallback onTap;

  const _ClientCard({
    required this.data,
    required this.accent,
    required this.onChat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (data.progress * 100).round();
    final isActive = data.status == _ClientStatus.active;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _Avatar(
                    color: data.avatarColor,
                    initials: _initials(data.name),
                  ),
                  const SizedBox(width: 12),
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
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              '${data.sessions}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black.withValues(alpha: 0.70),
                                  ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'sessions',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black.withValues(alpha: 0.45),
                                  ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isActive ? const Color(0xFF2ECC71) : Colors.black.withValues(alpha: 0.22),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isActive ? 'Active' : 'Paused',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: isActive
                                        ? const Color(0xFF2ECC71).withValues(alpha: 0.95)
                                        : Colors.black.withValues(alpha: 0.45),
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _ChatButton(onTap: onChat),
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
                  Icon(
                    Icons.trending_up_rounded,
                    size: 16,
                    color: const Color(0xFF2ECC71).withValues(alpha: 0.95),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$pct',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF2ECC71).withValues(alpha: 0.95),
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _ProgressBar(value: data.progress, color: accent),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF7FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD6ECFF)),
                ),
                child: Row(
                  children: [
                    Text(
                      'Next Session',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: Colors.black.withValues(alpha: 0.70),
                          ),
                    ),
                    const Spacer(),
                    Text(
                      data.nextSession,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: accent,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    final a = parts.first.isNotEmpty ? parts.first[0] : '';
    final b = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    return (a + b).toUpperCase();
  }
}

class _Avatar extends StatelessWidget {
  final Color color;
  final String initials;

  const _Avatar({
    required this.color,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.6,
                ),
          ),
        ),
        Positioned(
          left: 30,
          bottom: -4,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFF2ECC71),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChatButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ChatButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFFEAFBFF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFBEEFF7)),
          ),
          child: const Icon(
            Icons.chat_bubble_outline_rounded,
            size: 16,
            color: Color(0xFF1B9AAA),
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  final Color color;

  const _ProgressBar({
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 6,
        color: Colors.black.withValues(alpha: 0.08),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: value.clamp(0, 1),
          child: Container(color: color),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black.withValues(alpha: 0.10)),
          ),
          child: Icon(
            icon,
            size: 16,
            color: Colors.black.withValues(alpha: 0.78),
          ),
        ),
      ),
    );
  }
}

enum _ClientStatus { active, paused }

class _ClientVm {
  final String name;
  final int sessions;
  final _ClientStatus status;
  final double progress; // 0..1
  final String nextSession;
  final Color avatarColor;

  const _ClientVm({
    required this.name,
    required this.sessions,
    required this.status,
    required this.progress,
    required this.nextSession,
    required this.avatarColor,
  });
}