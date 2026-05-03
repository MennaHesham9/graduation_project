// lib/features/questionnaire/services/questionnaire_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/questionnaire_model.dart';
import '../../../core/services/notification_service.dart';

class QuestionnaireService {
  final FirebaseFirestore _db;
  final NotificationService _notif;

  QuestionnaireService({FirebaseFirestore? db, NotificationService? notif})
      : _db = db ?? FirebaseFirestore.instance,
        _notif = notif ?? NotificationService();

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('questionnaires');

  // ── Coach sends a new questionnaire to a client ───────────────────────────

  Future<String> sendQuestionnaire({
    required String coachId,
    required String coachName,
    required String clientId,
    required String clientName,
    required String title,
    required List<QuestionnaireQuestion> questions,
  }) async {
    final doc = _col.doc();

    final model = QuestionnaireModel(
      id: doc.id,
      coachId: coachId,
      clientId: clientId,
      coachName: coachName,
      clientName: clientName,
      title: title,
      questions: questions,
      status: 'sent',
      sentAt: DateTime.now(),
    );

    await doc.set(model.toMap());

    // Notify the client
    await _notif.sendNotification(
      toUid: clientId,
      title: '📋 New Pre-Session Questionnaire',
      body: '$coachName sent you a questionnaire to fill out before your session.',
      type: 'questionnaire_sent',
      relatedId: doc.id,
    );

    return doc.id;
  }

  // ── Coach edits an existing questionnaire (only if not yet answered) ───────

  Future<void> updateQuestionnaire({
    required String questionnaireId,
    required String title,
    required List<QuestionnaireQuestion> questions,
    required String clientId,
    required String coachName,
  }) async {
    await _col.doc(questionnaireId).update({
      'title': title,
      'questions': questions.map((q) => q.toMap()).toList(),
    });

    // Notify the client that questionnaire was updated
    await _notif.sendNotification(
      toUid: clientId,
      title: '✏️ Questionnaire Updated',
      body: '$coachName updated your pre-session questionnaire. Please review and answer.',
      type: 'questionnaire_updated',
      relatedId: questionnaireId,
    );
  }

  // ── Client submits answers ────────────────────────────────────────────────

  Future<void> submitAnswers({
    required String questionnaireId,
    required String clientId,
    required String clientName,
    required String coachId,
    required String coachName,
    required List<String> answers,
  }) async {
    final batch = _db.batch();

    // 1. Write answer sub-document
    final answerRef = _col.doc(questionnaireId).collection('answers').doc();
    batch.set(answerRef, QuestionnaireAnswer(
      id: answerRef.id,
      questionnaireId: questionnaireId,
      clientId: clientId,
      clientName: clientName,
      answers: answers,
      submittedAt: DateTime.now(),
    ).toMap());

    // 2. Mark parent questionnaire as answered
    batch.update(_col.doc(questionnaireId), {
      'status': 'answered',
      'answeredAt': Timestamp.fromDate(DateTime.now()),
    });

    await batch.commit();

    // 3. Notify the coach
    await _notif.sendNotification(
      toUid: coachId,
      title: '✅ Questionnaire Answered',
      body: '$clientName has answered the pre-session questionnaire.',
      type: 'questionnaire_answered',
      relatedId: questionnaireId,
    );
  }

  // ── Streams ───────────────────────────────────────────────────────────────

  /// All questionnaires sent by this coach (for a specific client)
  Stream<List<QuestionnaireModel>> streamForCoachClient({
    required String coachId,
    required String clientId,
  }) {
    return _col
        .where('coachId', isEqualTo: coachId)
        .where('clientId', isEqualTo: clientId)
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => QuestionnaireModel.fromMap(d.id, d.data()))
        .toList());
  }

  /// All questionnaires sent TO this client (for client sessions screen)
  Stream<List<QuestionnaireModel>> streamForClient(String clientId) {
    return _col
        .where('clientId', isEqualTo: clientId)
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => QuestionnaireModel.fromMap(d.id, d.data()))
        .toList());
  }

  /// Load the answers for a questionnaire (for coach to view)
  Future<QuestionnaireAnswer?> fetchAnswers(String questionnaireId) async {
    final snap = await _col
        .doc(questionnaireId)
        .collection('answers')
        .orderBy('submittedAt', descending: true)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    return QuestionnaireAnswer.fromMap(
        snap.docs.first.id, snap.docs.first.data());
  }

  /// Stream answers in real-time
  Stream<QuestionnaireAnswer?> streamAnswers(String questionnaireId) {
    return _col
        .doc(questionnaireId)
        .collection('answers')
        .orderBy('submittedAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      return QuestionnaireAnswer.fromMap(
          snap.docs.first.id, snap.docs.first.data());
    });
  }
}