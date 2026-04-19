// lib/core/screens/notification_screen.dart

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../data/dummy_notifications.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // In a real app this would come from a provider/API.
  // For now we copy the dummy list so we can mutate it (mark read, etc.)
  late final List<NotificationItem> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List.from(dummyNotifications);
  }

  int get _unreadCount => _notifications.where((n) => n.isUnread).length;

  void _markAllRead() {
    setState(() {
      for (int i = 0; i < _notifications.length; i++) {
        _notifications[i] = NotificationItem(
          id:         _notifications[i].id,
          title:      _notifications[i].title,
          body:       _notifications[i].body,
          timeAgo:    _notifications[i].timeAgo,
          isUnread:   false,
          iconColor:  _notifications[i].iconColor,
          icon:       _notifications[i].icon,
        );
      }
    });
  }

  void _markOneRead(int index) {
    if (!_notifications[index].isUnread) return;
    setState(() {
      final n = _notifications[index];
      _notifications[index] = NotificationItem(
        id:        n.id,
        title:     n.title,
        body:      n.body,
        timeAgo:   n.timeAgo,
        isUnread:  false,
        iconColor: n.iconColor,
        icon:      n.icon,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──────────────────────────────────────────────
            _NotifAppBar(
              unreadCount: _unreadCount,
              onBack: () => Navigator.of(context).pop(),
              onMarkAllRead: _unreadCount > 0 ? _markAllRead : null,
            ),

            const SizedBox(height: 12),

            // ── List ─────────────────────────────────────────────────
            Expanded(
              child: _notifications.isEmpty
                  ? _EmptyState()
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 4),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  return _NotificationCard(
                    item: _notifications[index],
                    onTap: () => _markOneRead(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App Bar
// ─────────────────────────────────────────────────────────────────────────────
class _NotifAppBar extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onBack;
  final VoidCallback? onMarkAllRead;

  const _NotifAppBar({
    required this.unreadCount,
    required this.onBack,
    this.onMarkAllRead,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4F8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: Color(0xFF1A2533),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Title
          const Expanded(
            child: Text(
              'Notifications',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A2533),
              ),
            ),
          ),

          // Unread badge  OR  "Mark all read" tap
          if (unreadCount > 0)
            GestureDetector(
              onTap: onMarkAllRead,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4F8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'All read',
                style: TextStyle(
                  color: Color(0xFF9EABB8),
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

// ─────────────────────────────────────────────────────────────────────────────
// Notification Card
// ─────────────────────────────────────────────────────────────────────────────
class _NotificationCard extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;

  const _NotificationCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.isUnread
              ? Colors.white
              : Colors.white.withOpacity(0.75),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isUnread
                ? const Color(0xFFE2EEF0)
                : const Color(0xFFF0F4F8),
          ),
          boxShadow: item.isUnread
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon bubble
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: item.iconColor,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(item.icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: item.isUnread
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: const Color(0xFF1A2533),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.body,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF5A6A7A),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.timeAgo,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9EABB8),
                    ),
                  ),
                ],
              ),
            ),

            // Unread dot
            if (item.isUnread)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 6),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5F7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 38,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Notifications',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A2533),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "You're all caught up!",
            style: TextStyle(fontSize: 13, color: Color(0xFF9EABB8)),
          ),
        ],
      ),
    );
  }
}