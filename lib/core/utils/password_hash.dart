import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Utility class for secure password hashing using SHA-256 with salt
class PasswordHash {
  /// Hash a password with a random salt
  /// Returns a string in format: salt:hash
  static String hashPassword(String password) {
    // Generate a random salt (in production, use a more secure random generator)
    final salt = DateTime.now().millisecondsSinceEpoch.toString();

    // Combine password and salt
    final combined = password + salt;

    // Hash using SHA-256
    final bytes = utf8.encode(combined);
    final digest = sha256.convert(bytes);

    // Return salt:hash format
    return '$salt:$digest';
  }

  /// Verify a password against a stored hash
  /// storedHash should be in format: salt:hash
  static bool verifyPassword(String password, String storedHash) {
    try {
      final parts = storedHash.split(':');
      if (parts.length != 2) return false;

      final salt = parts[0];
      final hash = parts[1];

      // Hash the provided password with the stored salt
      final combined = password + salt;
      final bytes = utf8.encode(combined);
      final digest = sha256.convert(bytes);

      // Compare hashes
      return digest.toString() == hash;
    } catch (e) {
      return false;
    }
  }
}
