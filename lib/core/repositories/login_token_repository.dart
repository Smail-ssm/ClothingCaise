import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/login_token.dart';

/// Repository for managing login tokens used in QR code authentication
class LoginTokenRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'login_tokens';
  final _uuid = const Uuid();

  /// Create a new login token for a user
  /// Token expires after the specified duration (default: 5 minutes)
  Future<LoginToken> createToken({
    required String userId,
    Duration expiresIn = const Duration(minutes: 5),
  }) async {
    final now = DateTime.now();
    final token = LoginToken(
      id: _uuid.v4(),
      userId: userId,
      createdAt: now,
      expiresAt: now.add(expiresIn),
      used: false,
    );

    await _firestore.collection(_collection).doc(token.id).set(token.toJson());

    // Auto-delete expired tokens after 1 hour
    _cleanupExpiredTokens();

    return token;
  }

  /// Get a token by ID
  Future<LoginToken?> getToken(String tokenId) async {
    final doc = await _firestore.collection(_collection).doc(tokenId).get();
    if (!doc.exists) return null;
    return LoginToken.fromJson(doc.data()!, doc.id);
  }

  /// Mark a token as used
  Future<void> markTokenAsUsed(String tokenId) async {
    await _firestore.collection(_collection).doc(tokenId).update({
      'used': true,
    });
  }

  /// Delete a token
  Future<void> deleteToken(String tokenId) async {
    await _firestore.collection(_collection).doc(tokenId).delete();
  }

  /// Clean up expired tokens (older than 1 hour)
  Future<void> _cleanupExpiredTokens() async {
    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));

    final snapshot = await _firestore
        .collection(_collection)
        .where('expiresAt', isLessThan: Timestamp.fromDate(oneHourAgo))
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
