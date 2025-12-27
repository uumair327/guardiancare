import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
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
/// 
/// Includes fallback mechanism when Gemini API fails to ensure
/// recommendations are always generated.
class GeminiAIServiceImpl implements GeminiAIService {
  final Gemini _gemini;
  final bool _useFallback;

  /// Creates a [GeminiAIServiceImpl] with the provided Gemini instance
  /// 
  /// If no instance is provided, initializes Gemini with the API key
  /// and uses the singleton instance.
  /// 
  /// [useFallback] - If true, generates fallback search terms when API fails.
  /// Defaults to true for production use.
  GeminiAIServiceImpl({
    Gemini? gemini,
    bool useFallback = true,
  })  : _gemini = gemini ?? _initGemini(),
        _useFallback = useFallback;

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
      debugPrint('🤖 Calling Gemini API for category: $category');
      
      // Using prompt method with Part.text for flutter_gemini 3.0.0
      final response = await _gemini.prompt(parts: [Part.text(promptText)]);

      if (response == null || response.output == null) {
        debugPrint('⚠️ Gemini API returned null response');
        return _handleFallback(category, 'Gemini API returned null response');
      }

      final searchTerms = _parseSearchTerms(response.output!);
      
      if (searchTerms.isEmpty) {
        debugPrint('⚠️ No valid search terms generated from Gemini');
        return _handleFallback(category, 'No valid search terms generated');
      }

      debugPrint('✅ Gemini generated ${searchTerms.length} search terms: $searchTerms');
      return Right(searchTerms);
    } catch (e) {
      debugPrint('❌ Gemini API error: $e');
      return _handleFallback(category, 'Gemini API error: ${e.toString()}');
    }
  }

  /// Handles fallback when Gemini API fails
  Either<Failure, List<String>> _handleFallback(String category, String errorMessage) {
    if (_useFallback) {
      final fallbackTerms = _generateFallbackSearchTerms(category);
      debugPrint('🔄 Using fallback search terms: $fallbackTerms');
      return Right(fallbackTerms);
    }
    return Left(GeminiApiFailure(errorMessage));
  }

  /// Generates fallback search terms when Gemini API fails
  List<String> _generateFallbackSearchTerms(String category) {
    final sanitizedCategory = category.toLowerCase().trim();
    return [
      'child safety $sanitizedCategory parenting tips',
      'parenting guide $sanitizedCategory children education',
    ];
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
        .where((term) => !term.startsWith('*')) // Filter out asterisk bullets
        .where((term) => term.length > 3) // Filter out very short terms
        .toList();
  }
}
