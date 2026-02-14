/// Backend-agnostic user model.
///
/// This model represents a user across any backend provider.
/// It contains only the essential user information that is common
/// across authentication providers.
///
/// ## Usage
/// ```dart
/// final user = BackendUser(
///   id: 'user123',
///   email: 'user@example.com',
///   displayName: 'John Doe',
/// );
/// ```
class BackendUser {
  const BackendUser({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.emailVerified = false,
    this.isAnonymous = false,
    this.createdAt,
    this.lastLoginAt,
    this.metadata = const {},
  });

  /// Create from JSON map
  factory BackendUser.fromJson(Map<String, dynamic> json) {
    return BackendUser(
      id: json['id'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
    );
  }

  /// Unique user identifier
  final String id;

  /// User's email address
  final String? email;

  /// User's display name
  final String? displayName;

  /// User's photo URL
  final String? photoUrl;

  /// User's phone number
  final String? phoneNumber;

  /// Whether the email has been verified
  final bool emailVerified;

  /// Whether this is an anonymous user
  final bool isAnonymous;

  /// When the user was created
  final DateTime? createdAt;

  /// When the user last logged in
  final DateTime? lastLoginAt;

  /// Additional metadata (provider-specific data)
  final Map<String, dynamic> metadata;

  /// Create a copy with updated fields
  BackendUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    bool? emailVerified,
    bool? isAnonymous,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? metadata,
  }) {
    return BackendUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailVerified: emailVerified ?? this.emailVerified,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (email != null) 'email': email,
      if (displayName != null) 'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      'emailVerified': emailVerified,
      'isAnonymous': isAnonymous,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (lastLoginAt != null) 'lastLoginAt': lastLoginAt!.toIso8601String(),
      if (metadata.isNotEmpty) 'metadata': metadata,
    };
  }

  @override
  String toString() =>
      'BackendUser(id: $id, email: $email, displayName: $displayName)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BackendUser &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Authentication credentials
class AuthCredentials {
  const AuthCredentials({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}

/// OAuth provider types
enum OAuthProvider {
  google,
  apple,
  facebook,
  twitter,
  github,
  microsoft,
}
