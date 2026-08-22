// lib/core/data/dummy_notifications.dart

import 'package:flutter/material.dart';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String timeAgo;
  final bool isUnread;
  final Color iconColor;
  final IconData icon;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timeAgo,
    required this.isUnread,
    required this.iconColor,
    required this.icon,
  });
}

final List<NotificationItem> dummyNotifications = [
  NotificationItem(
    id: '1',
    title: 'Upcoming Session Reminder',
    body: 'Your session with Dr. Michael Chen starts in 1 hour',
    timeAgo: '1 hour ago',
    isUnread: true,
    iconColor: Color(0xFF2F8F9D),
    icon: Icons.videocam_rounded,
  ),
  NotificationItem(
    id: '2',
    title: 'Task Deadline',
    body: 'Complete your daily meditation practice',
    timeAgo: '2 hours ago',
    isUnread: true,
    iconColor: Color(0xFF4CAF50),
    icon: Icons.check_circle_rounded,
  ),
  NotificationItem(
    id: '3',
    title: 'New Message',
    body: 'Dr. Chen sent you a message',
    timeAgo: '3 hours ago',
    isUnread: false,
    iconColor: Color(0xFF2196F3),
    icon: Icons.chat_bubble_rounded,
  ),
  NotificationItem(
    id: '4',
    title: 'Goal Progress Update',
    body: 'You reached 75% on your communication goal!',
    timeAgo: '1 day ago',
    isUnread: false,
    iconColor: Color(0xFFFF9800),
    icon: Icons.track_changes_rounded,
  ),
  // NotificationItem(
  //   id: '5',
  //   title: 'Daily Mood Check',
  //   body: "Don't forget to log your mood today",
  //   timeAgo: '1 day ago',
  //   isUnread: false,
  //   iconColor: Color(0xFFE91E8C),
  //   icon: Icons.favorite_rounded,
  // ),
  // NotificationItem(
  //   id: '6',
  //   title: 'Session Completed',
  //   body: 'Session notes are now available',
  //   timeAgo: '2 days ago',
  //   isUnread: false,
  //   iconColor: Color(0xFF2F8F9D),
  //   icon: Icons.videocam_rounded,
  // ),
];