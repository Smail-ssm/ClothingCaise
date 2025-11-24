import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a temporary login token for QR code authentication
/// Tokens expire after a set duration for security
class LoginToken {
  final String id; // Firestore document ID
  final String userId; // User this token is for
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool used; // Whether the token has been used

  LoginToken({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.expiresAt,
    this.used = false,
  });

  /// Check if token is still valid
  bool get isValid => !used && DateTime.now().isBefore(expiresAt);

  factory LoginToken.fromJson(Map<String, dynamic> json, String id) {
    return LoginToken(
      id: id,
      userId: json['userId'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      expiresAt: (json['expiresAt'] as Timestamp).toDate(),
      used: json['used'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'used': used,
    };
  }
}
