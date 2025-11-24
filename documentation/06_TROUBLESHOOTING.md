# 🆘 Troubleshooting - Clothing Caisse Manager

Common issues and how to fix them.

## 🏗️ Build & Setup Issues

### ❌ "Visual Studio not found" or CMake Error
**Problem**: Flutter cannot find the correct Visual Studio version to build the Windows app.
**Fix**:
1.  Install **Visual Studio 2022 Community**.
2.  Select the **"Desktop development with C++"** workload during installation.
3.  Run `flutter doctor` to verify.
4.  Run `flutter clean` and try again.

### ❌ "Firebase not initialized"
**Problem**: App crashes on startup with a Firebase error.
**Fix**:
1.  Ensure you have run `flutterfire configure`.
2.  Check `lib/firebase_options.dart` exists.
3.  Verify `main.dart` calls `Firebase.initializeApp()`.

### ❌ "Symlink support" Warning (Windows)
**Problem**: Warning about developer mode during `flutter pub get`.
**Fix**:
-   Enable **Developer Mode** in Windows Settings -> Privacy & security -> For developers.
-   Or run the command prompt as Administrator.
-   *Note: This is usually harmless and can be ignored.*

---

## 📱 Runtime Issues

### ❌ Login Fails
**Problem**: "User not found" or "Wrong password".
**Fix**:
-   Check your internet connection.
-   Verify the user exists in Firebase Authentication.
-   Verify the user document exists in the `users` Firestore collection.

### ❌ "Permission Denied"
**Problem**: You cannot access certain screens (e.g., Products, Stock).
**Fix**:
-   Check your user role in Firestore.
-   Only `admin` users can edit products.
-   `cashier` users are limited to Sales and Cash Sessions.

### ❌ Android Device Not Found
**Problem**: `flutter run` doesn't see your phone.
**Fix**:
1.  Enable **USB Debugging** on your phone (Developer Options).
2.  Connect via USB.
3.  Check the phone screen to "Allow USB Debugging".
4.  Run `flutter devices` to check connection.

---

## 🐛 Debugging

### Viewing Logs
-   In VS Code, check the **Debug Console**.
-   In terminal, run with `-v` for verbose output: `flutter run -v`.

### Resetting Data
-   To clear local app data (if things get stuck):
    -   **Android**: App Info -> Storage -> Clear Storage.
    -   **Windows**: Delete the build folder or clean the project.
