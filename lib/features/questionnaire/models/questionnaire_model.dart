// lib/features/questionnaire/models/questionnaire_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// ─── Answer type enum ─────────────────────────────────────────────────────────

enum QuestionType {
  multipleChoice,
  shortAnswer,
  scale,
  yesNo,
  longAnswer;

  String get label {
    switch (this) {
      case QuestionType.multipleChoice: return 'Multiple Choice';
      case QuestionType.shortAnswer:   return 'Short Answer';
      case QuestionType.scale:         return 'Scale 1–10';
      case QuestionType.yesNo:         return 'Yes / No';
      case QuestionType.longAnswer:    return 'Long Answer';
    }
  }

  static QuestionType fromLabel(String label) {
    return QuestionType.values.firstWhere(
          (e) => e.label == label,
      orElse: () => QuestionType.shortAnswer,
    );
  }
}

// ─── Single question ──────────────────────────────────────────────────────────

class QuestionnaireQuestion {
  final String text;
  final QuestionType type;

  const QuestionnaireQuestion({required this.text, required this.type});

  factory QuestionnaireQuestion.fromMap(Map<String, dynamic> map) {
    return QuestionnaireQuestion(
      text: map['text'] ?? '',
      type: QuestionType.fromLabel(map['type'] ?? ''),
    );
  }

  Map<String, dynamic> toMap() => {
    'text': text,
    'type': type.label,
  };
}

// ─── Questionnaire document ───────────────────────────────────────────────────
//
// Firestore path: questionnaires/{id}
// Fields:
//   coachId, clientId, coachName, clientName,
//   title, questions[], status, sentAt, answeredAt

class QuestionnaireModel {
  final String id;
  final String coachId;
  final String clientId;
  final String coachName;
  final String clientName;
  final String title;
  final List<QuestionnaireQuestion> questions;
  /// 'sent' | 'answered'
  final String status;
  final DateTime sentAt;
  final DateTime? answeredAt;

  const QuestionnaireModel({
    required this.id,
    required this.coachId,
    required this.clientId,
    required this.coachName,
    required this.clientName,
    required this.title,
    required this.questions,
    required this.status,
    required this.sentAt,
    this.answeredAt,
  });

  bool get isAnswered => status == 'answered';

  factory QuestionnaireModel.fromMap(String id, Map<String, dynamic> map) {
    return QuestionnaireModel(
      id: id,
      coachId: map['coachId'] ?? '',
      clientId: map['clientId'] ?? '',
      coachName: map['coachName'] ?? '',
      clientName: map['clientName'] ?? '',
      title: map['title'] ?? 'Pre-Session Questionnaire',
      questions: (map['questions'] as List<dynamic>? ?? [])
          .map((q) => QuestionnaireQuestion.fromMap(q as Map<String, dynamic>))
          .toList(),
      status: map['status'] ?? 'sent',
      sentAt: (map['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      answeredAt: (map['answeredAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'coachId': coachId,
    'clientId': clientId,
    'coachName': coachName,
    'clientName': clientName,
    'title': title,
    'questions': questions.map((q) => q.toMap()).toList(),
    'status': status,
    'sentAt': Timestamp.fromDate(sentAt),
    'answeredAt': answeredAt != null ? Timestamp.fromDate(answeredAt!) : null,
  };
}

// ─── Answer document ──────────────────────────────────────────────────────────
//
// Firestore path: questionnaires/{questionnaireId}/answers/{answerId}
// One document per submission.

class QuestionnaireAnswer {
  final String id;
  final String questionnaireId;
  final String clientId;
  final String clientName;
  /// Parallel list to QuestionnaireModel.questions
  final List<String> answers;
  final DateTime submittedAt;

  const QuestionnaireAnswer({
    required this.id,
    required this.questionnaireId,
    required this.clientId,
    required this.clientName,
    required this.answers,
    required this.submittedAt,
  });

  factory QuestionnaireAnswer.fromMap(String id, Map<String, dynamic> map) {
    return QuestionnaireAnswer(
      id: id,
      questionnaireId: map['questionnaireId'] ?? '',
      clientId: map['clientId'] ?? '',
      clientName: map['clientName'] ?? '',
      answers: List<String>.from(map['answers'] ?? []),
      submittedAt: (map['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'questionnaireId': questionnaireId,
    'clientId': clientId,
    'clientName': clientName,
    'answers': answers,
    'submittedAt': Timestamp.fromDate(submittedAt),
  };
}