# Secure QR Code Login Implementation

## Overview
We've implemented a **secure, token-based QR code authentication system** that replaces the previous insecure password-embedding approach.

## Security Improvements

### Before (INSECURE ⚠️)
```
QR Code contained: {"e":"user@example.com","p":"plaintext_password"}
```
- ❌ Password visible to anyone who scans the QR code
- ❌ Password stored in plain text in Firestore
- ❌ QR codes never expire
- ❌ No audit trail

### After (SECURE ✅)
```
QR Code contains: "a1b2c3d4-e5f6-7890-abcd-ef1234567890" (token ID only)
```
- ✅ No password in QR code - just a temporary token
- ✅ Passwords hashed with SHA-256 + salt before storage
- ✅ Tokens expire after 5 minutes
- ✅ One-time use tokens (marked as used after first scan)
- ✅ Automatic cleanup of expired tokens

## How It Works

### 1. Password Storage (Hashed)
When creating a user:
```dart
// Password is automatically hashed before storage
final hashedPassword = PasswordHash.hashPassword("user_password");
// Stored as: "1637584920123:a3f8e9d2c1b4a5e6f7g8h9i0j1k2l3m4n5o6p7q8"
//             ^^^^^^^^^^^^^^^^  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
//             salt               SHA-256 hash
```

### 2. QR Code Generation
Admin clicks "Generate Login Badge":
```dart
1. System creates a LoginToken:
   - id: UUID (e.g., "abc123-def456")
   - userId: "user_firestore_id"
   - createdAt: now
   - expiresAt: now + 5 minutes
   - used: false

2. Token saved to Firestore collection: login_tokens

3. QR code generated containing ONLY the token ID
```

### 3. QR Code Login Flow
User scans QR code:
```dart
1. Scanner reads token ID from QR code
2. App calls: authRepository.signInWithToken(tokenId)
3. System verifies:
   ✓ Token exists in Firestore
   ✓ Token not expired
   ✓ Token not already used
4. Fetch user associated with token
5. Mark token as used (prevents reuse)
6. Return user and complete login
```

### 4. Password Login
User logs in with email/password:
```dart
1. User enters email and password
2. System tries Firebase Auth first (for admin users)
3. If Firebase Auth fails, checks Firestore:
   - Find user by email
   - Verify password using PasswordHash.verifyPassword()
   - This hashes the input password with stored salt
   - Compares hashes securely
4. Return user if password matches
```

## Files Modified/Created

### New Files
- `lib/core/utils/password_hash.dart` - Password hashing utility
- `lib/core/models/login_token.dart` - LoginToken model
- `lib/core/repositories/login_token_repository.dart` - Token management

### Modified Files
- `lib/core/repositories/auth_repository.dart` - Added `signInWithToken()`, hash verification
- `lib/core/repositories/user_repository.dart` - Hash passwords on user creation
- `lib/features/admin/user_management_screen.dart` - Token-based QR generation
- `lib/features/auth/login_screen.dart` - Token-based QR scanning
- `lib/core/providers.dart` - Added loginTokenRepositoryProvider
- `pubspec.yaml` - Added crypto package

## Security Features

### Password Hashing
- **Algorithm**: SHA-256 with salt
- **Salt**: Timestamp-based (unique per password)
- **Format**: `salt:hash` stored in Firestore
- **Verification**: Constant-time comparison to prevent timing attacks

### Token Security
- **Uniqueness**: UUID v4 ensures globally unique tokens
- **Expiration**: 5-minute lifespan
- **One-time use**: Token marked as used after first successful scan
- **Auto-cleanup**: Expired tokens deleted automatically after 1 hour
- **No password exposure**: QR code never contains the password

### Firestore Rules (Recommended)
```javascript
// Add to firestore.rules
match /login_tokens/{tokenId} {
  // Only authenticated users can read/write tokens
  allow read, write: if request.auth != null && 
                       request.auth.token.role == 'admin';
}

match /users/{userId} {
  // Password field should never be returned to clients
  allow read: if request.auth != null && 
              request.auth.uid == userId;
  allow update: if request.auth != null && 
                 request.auth.token.role == 'admin';
}
```

## Migration Guide

### For Existing Users with Plain Text Passwords
Existing users with plain-text passwords will need to:
1. Admin updates their password through User Management screen
2. Password automatically hashed on next save
3. User can then login normally or use QR code

### Testing the New System
1. Create a new user with a password
2. Generate a login badge - notice it shows expiration warning
3. Scan the QR code within 5 minutes
4. Login succeeds and user is redirected to profile
5. Try scanning the same QR code again - should fail (already used)
6. Wait 5 minutes and try scanning - should fail (expired)

## Production Recommendations

1. **Use better hashing**: Consider bcrypt or Argon2 instead of SHA-256
   ```dart
   // Alternative with better security
   import 'package:bcrypt/bcrypt.dart';
   final hashed = BCrypt.hashpw(password, BCrypt.gensalt());
   ```

2. **Implement rate limiting**: Prevent brute-force attacks
3. **Add 2FA**: Extra security layer for admin accounts
4. **Audit logging**: Track all login attempts
5. **HTTPS only**: Ensure tokens transmitted over secure connection
6. **Secure token storage**: Consider encrypted storage for tokens

## Troubleshooting

### Issue: "Invalid or expired token"
- **Cause**: Token expired (>5 min) or already used
- **Solution**: Generate a new QR code

### Issue: "Password verification failed"
- **Cause**: Password doesn't match hash
- **Solution**: Reset user password through admin panel

### Issue: Old QR codes still work
- **Cause**: Using old implementation
- **Solution**: Run `flutter clean && flutter pub get && flutter run`
