// lib/features/coach/screens/accept_client.dart
//
// The original file was a standalone Figma-prototype with hardcoded dummy
// data and its own `void main()`.  It has been replaced.
//
// The production Accept-Client screen lives in:
//   client_request_detail_screen.dart  →  ClientRequestDetailScreen
//
// Navigation is handled by CoachClientsScreen (coach_clients_screen.dart):
//   _openDetail(req, coachName) → pushes ClientRequestDetailScreen
//
// This file is kept as a clean re-export so that any stale import of
// 'accept_client.dart' still resolves without a compile error.

export 'client_request_detail_screen.dart';