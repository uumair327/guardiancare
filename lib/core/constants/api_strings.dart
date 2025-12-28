/// API-related string constants for the GuardianCare application.
///
/// This class provides a single source of truth for all API-related strings
/// including base URLs, endpoints, query parameters, and HTTP headers.
///
/// ## Purpose
/// - Centralizes all API configuration strings
/// - Simplifies API endpoint management
/// - Prevents typos in API URLs and parameters
/// - Enables easy API configuration changes
///
/// ## Categories
/// - **Base URLs**: API base URLs for external services
/// - **YouTube Endpoints**: YouTube Data API endpoints
/// - **Query Parameters**: Common query parameter names
/// - **Query Parameter Values**: Common parameter values
/// - **Content Types**: HTTP content type headers
/// - **Headers**: HTTP header names
/// - **Authorization Prefixes**: Auth header prefixes
/// - **HTTP Methods**: HTTP method names
/// - **Response Fields**: Common API response field names
///
/// ## Usage Example
/// ```dart
/// import 'package:guardiancare/core/constants/constants.dart';
///
/// // Building a YouTube API URL
/// final url = Uri.parse('${ApiStrings.youtubeApiBase}${ApiStrings.youtubeSearch}')
///     .replace(queryParameters: {
///       ApiStrings.paramPart: ApiStrings.partSnippet,
///       ApiStrings.paramQuery: searchTerm,
///       ApiStrings.paramType: ApiStrings.typeVideo,
///       ApiStrings.paramMaxResults: '10',
///       ApiStrings.paramKey: apiKey,
///     });
///
/// // Setting HTTP headers
/// final headers = {
///   ApiStrings.headerContentType: ApiStrings.contentTypeJson,
///   ApiStrings.headerAuthorization: '${ApiStrings.bearerPrefix}$token',
/// };
///
/// // Making an HTTP request
/// final response = await http.get(url, headers: headers);
/// ```
///
/// ## Best Practices
/// - Always use ApiStrings for API-related strings
/// - Never hardcode API URLs or parameters in code
/// - Use constants for query parameter names and values
/// - Update this file when API endpoints change
///
/// See also:
/// - [FirebaseStrings] for Firebase-specific constants
/// - [AppStrings] for app-level constants
class ApiStrings {
  ApiStrings._();

  // ==================== Base URLs ====================
  static const String youtubeApiBase = 'https://www.googleapis.com/youtube/v3';
  static const String geminiApiBase = 'https://generativelanguage.googleapis.com';

  // ==================== YouTube Endpoints ====================
  static const String youtubeSearch = '/search';
  static const String youtubeVideos = '/videos';
  static const String youtubeChannels = '/channels';
  static const String youtubePlaylistItems = '/playlistItems';

  // ==================== Query Parameters ====================
  static const String paramPart = 'part';
  static const String paramQuery = 'q';
  static const String paramKey = 'key';
  static const String paramMaxResults = 'maxResults';
  static const String paramType = 'type';
  static const String paramId = 'id';
  static const String paramPageToken = 'pageToken';
  static const String paramOrder = 'order';
  static const String paramChannelId = 'channelId';
  static const String paramPlaylistId = 'playlistId';
  static const String paramVideoId = 'videoId';

  // ==================== Query Parameter Values ====================
  static const String partSnippet = 'snippet';
  static const String partContentDetails = 'contentDetails';
  static const String partStatistics = 'statistics';
  static const String typeVideo = 'video';
  static const String typeChannel = 'channel';
  static const String typePlaylist = 'playlist';
  static const String orderDate = 'date';
  static const String orderRating = 'rating';
  static const String orderRelevance = 'relevance';
  static const String orderViewCount = 'viewCount';

  // ==================== Content Types ====================
  static const String contentTypeJson = 'application/json';
  static const String contentTypeFormUrlEncoded = 'application/x-www-form-urlencoded';
  static const String contentTypeMultipart = 'multipart/form-data';

  // ==================== Headers ====================
  static const String headerContentType = 'Content-Type';
  static const String headerAuthorization = 'Authorization';
  static const String headerAccept = 'Accept';
  static const String headerUserAgent = 'User-Agent';
  static const String headerApiKey = 'X-API-Key';

  // ==================== Authorization Prefixes ====================
  static const String bearerPrefix = 'Bearer ';
  static const String basicPrefix = 'Basic ';

  // ==================== HTTP Methods ====================
  static const String methodGet = 'GET';
  static const String methodPost = 'POST';
  static const String methodPut = 'PUT';
  static const String methodPatch = 'PATCH';
  static const String methodDelete = 'DELETE';

  // ==================== Response Fields ====================
  static const String fieldItems = 'items';
  static const String fieldNextPageToken = 'nextPageToken';
  static const String fieldPrevPageToken = 'prevPageToken';
  static const String fieldPageInfo = 'pageInfo';
  static const String fieldTotalResults = 'totalResults';
  static const String fieldResultsPerPage = 'resultsPerPage';
}
