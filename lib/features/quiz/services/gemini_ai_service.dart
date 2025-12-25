import 'package:dartz/dartz.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:guardiancare/core/constants/constants.dart';
import 'package:guardiancare/core/error/failures.dart';

/// Service that handles Gemini AI API interactions exclusively
/// 
/// This service is responsible for generating YouTube search terms
/// based on quiz categories using the Gemini AI API.
/// 
/// Requirements: 4.1, 4.5
abstract class GeminiAIService {
  /// Generates YouTube search terms for a given category
  /// 
  /// Returns [Either<Failure, List<String>>] containing:
  /// - [Right] with list of search terms on success
  /// - [Left] with [GeminiApiFailure] on error (no fallback logic)
  Future<Either<Failure, List<String>>> generateSearchTerms(String category);
}

/// Implementation of [GeminiAIService] using Flutter Gemini package
class GeminiAIServiceImpl implements GeminiAIService {
  final Gemini _gemini;

  /// Creates a [GeminiAIServiceImpl] with the provided Gemini instance
  /// 
  /// If no instance is provided, initializes Gemini with the API key
  /// and uses the singleton instance.
  GeminiAIServiceImpl({Gemini? gemini}) : _gemini = gemini ?? _initGemini();

  static Gemini _initGemini() {
    try {
      Gemini.init(apiKey: kGeminiApiKey);
    } catch (_) {
      // Gemini might already be initialized
    }
    return Gemini.instance;
  }

  @override
  Future<Either<Failure, List<String>>> generateSearchTerms(String category) async {
    if (category.isEmpty) {
      return const Left(GeminiApiFailure('Category cannot be empty'));
    }

    try {
      final promptText = _buildPrompt(category);
      // Using prompt instead of deprecated text method
      final response = await _gemini.prompt(parts: [Part.text(promptText)]);

      if (response == null || response.output == null) {
        return const Left(GeminiApiFailure('Gemini API returned null response'));
      }

      final searchTerms = _parseSearchTerms(response.output!);
      
      if (searchTerms.isEmpty) {
        return const Left(GeminiApiFailure('No valid search terms generated'));
      }

      return Right(searchTerms);
    } catch (e) {
      // No fallback logic - return failure on error as per Requirements 4.5
      return Left(GeminiApiFailure('Gemini API error: ${e.toString()}'));
    }
  }

  /// Builds the prompt for Gemini AI
  String _buildPrompt(String category) {
    return "Summarize the subtopics under the main topic '$category' for child safety "
        "and parenting into a single search term for YouTube. The term should effectively "
        "encompass the topic, consisting of 4-5 words, to yield highly relevant and accurate "
        "search results. Only provide 2 YouTube search terms, each separated by a new line, "
        "and nothing else. Search terms must not be in bullet point format. The search term "
        "should be highly relevant with child safety, parenting, and $category!";
  }

  /// Parses the Gemini response into a list of search terms
  List<String> _parseSearchTerms(String output) {
    return output
        .split('\n')
        .where((term) => term.trim().isNotEmpty)
        .map((term) => term.trim())
        .where((term) => !term.startsWith('-')) // Filter out bullet points
        .toList();
  }
}
