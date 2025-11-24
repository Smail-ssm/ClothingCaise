import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../utils/password_hash.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';
  final _uuid = const Uuid();

  // Get all users
  Stream<List<AppUser>> getUsers() {
    return _firestore.collection(_collection).orderBy('name').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => AppUser.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  // Create user (Firestore document only)
  // Passwords are hashed before storage
  // Badge ID automatically generated for QR code login
  Future<void> createUser(AppUser user) async {
    // Generate a unique badge ID if not provided
    final badgeId = user.badgeId ?? _uuid.v4();

    // Hash the password if provided
    AppUser userToStore = user;
    if (user.password != null && user.password!.isNotEmpty) {
      final hashedPassword = PasswordHash.hashPassword(user.password!);
      userToStore = AppUser(
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        createdAt: user.createdAt,
        password: hashedPassword, // Store hashed password
        badgeId: badgeId, // Store permanent badge ID
      );
    } else {
      // No password, but still add badge ID
      userToStore = AppUser(
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        createdAt: user.createdAt,
        password: null,
        badgeId: badgeId,
      );
    }

    if (userToStore.id.isNotEmpty) {
      await _firestore
          .collection(_collection)
          .doc(userToStore.id)
          .set(userToStore.toJson());
    } else {
      await _firestore.collection(_collection).add(userToStore.toJson());
    }
  }

  // Update user role
  Future<void> updateUserRole(String userId, UserRole role) async {
    await _firestore.collection(_collection).doc(userId).update({
      'role': role.toString().split('.').last,
    });
  }

  // Delete user (Logical or Physical)
  Future<void> deleteUser(String userId) async {
    await _firestore.collection(_collection).doc(userId).delete();
  }
}
