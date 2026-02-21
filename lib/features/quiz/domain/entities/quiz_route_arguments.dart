import 'package:guardiancare/features/quiz/data/models/question_model.dart';
import 'package:guardiancare/features/quiz/domain/entities/question_entity.dart';

/// Value object encapsulating all data passed to the quiz-questions route.
///
/// Having an explicit VO (rather than passing a raw `List`) allows:
/// - Type-safe route navigation: `context.push('/quiz-questions', extra: QuizRouteArguments(...))`
/// - JSON round-tripping via [GoRouter]'s `extraCodec`, which is required
///   on Flutter Web where the browser History API serialises `extra` as JSON.
///
/// Follows the Value Object pattern from Domain-Driven Design.
final class QuizRouteArguments {
  const QuizRouteArguments({required this.questions});

  /// Deserialise from the [Map] restored from the browser's History API.
  factory QuizRouteArguments.fromJson(Map<String, dynamic> json) {
    final raw = json['questions'] as List<dynamic>? ?? [];
    final questions = raw
        .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
        .cast<QuestionEntity>()
        .toList();
    return QuizRouteArguments(questions: questions);
  }

  final List<QuestionEntity> questions;

  // ── JSON serialisation ──────────────────────────────────────────────────────

  /// Serialise to a JSON-compatible [Map] stored in the browser's History API.
  Map<String, dynamic> toJson() => {
        'questions':
            questions.map((q) => QuestionModel.fromEntity(q).toJson()).toList(),
      };

  /// Runtime-safe cast from an unknown `extra` value.
  ///
  /// Handles both cases:
  /// - Fresh navigation → already a [QuizRouteArguments] (returned as-is)
  /// - Web history restore → a [Map<String, dynamic>] (decoded via [fromJson])
  static QuizRouteArguments fromExtra(Object? extra) {
    if (extra is QuizRouteArguments) return extra;
    if (extra is Map<String, dynamic>) {
      return QuizRouteArguments.fromJson(extra);
    }
    throw ArgumentError(
      'QuizRouteArguments.fromExtra: unexpected type ${extra.runtimeType}',
    );
  }
}
