import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import '../utils/password_hash.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<AppUser> signIn(String email, String password) async {
    print('Attempting sign in for: $email');
    try {
      // 1. Try Firebase Auth first (for Admins/existing auth users)
      try {
        print('Trying Firebase Auth...');
        final credential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (credential.user != null) {
          print('Firebase Auth successful. UID: ${credential.user!.uid}');
          final userDoc = await _firestore
              .collection('users')
              .doc(credential.user!.uid)
              .get();

          if (userDoc.exists) {
            print('User document found in Firestore.');
            return AppUser.fromJson(userDoc.data()!, userDoc.id);
          } else {
            print(
              'User document NOT found in Firestore for UID: ${credential.user!.uid}',
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        print('Firebase Auth failed: ${e.code} - ${e.message}');
        // Fallthrough to local check if Firebase Auth fails
      }

      // 2. Fallback: Check Firestore directly for non-auth users with HASHED passwords
      print('Falling back to local Firestore check...');

      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      print('Found ${querySnapshot.docs.length} documents for email: $email');

      if (querySnapshot.docs.isEmpty) {
        print('No user found with this email in Firestore.');
        throw Exception('User not found');
      }

      final doc = querySnapshot.docs.first;
      final userData = doc.data();
      final storedPasswordHash = userData['password'] as String?;

      if (storedPasswordHash == null) {
        print('No password hash stored for this user.');
        throw Exception('Invalid credentials');
      }

      print('Verifying password hash...');

      // Verify password against stored hash
      if (PasswordHash.verifyPassword(password, storedPasswordHash)) {
        print('Password verification successful.');
        return AppUser.fromJson(userData, doc.id);
      } else {
        print('Password verification failed.');
        throw Exception('Invalid password');
      }
    } catch (e) {
      print('Sign in error: $e');
      throw Exception('Sign in failed: $e');
    }
  }

  // Sign in with a permanent badge ID (for QR code login - REUSABLE)
  Future<AppUser> signInWithBadge(String badgeId) async {
    print('Attempting badge-based sign in. Badge ID: $badgeId');
    try {
      // Query for user with this badge ID
      final querySnapshot = await _firestore
          .collection('users')
          .where('badgeId', isEqualTo: badgeId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Invalid badge - user not found');
      }

      final doc = querySnapshot.docs.first;
      final userData = doc.data();

      print('Badge login successful for user: ${userData['name']}');
      return AppUser.fromJson(userData, doc.id);
    } catch (e) {
      print('Badge sign in error: $e');
      throw Exception('Badge sign in failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user data
  Future<AppUser?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return AppUser.fromJson(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  // Create user (admin only)
  Future<AppUser> createUser({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Failed to create user');
      }

      final appUser = AppUser(
        id: credential.user!.uid,
        name: name,
        email: email,
        role: role,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(appUser.toJson());

      return appUser;
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }
}
