# 🚀 Getting Started - Clothing Caisse Manager

This guide will help you set up the Clothing Caisse Manager application on your local machine.

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

1.  **Flutter SDK**: Version 3.13 or higher.
    -   [Install Flutter](https://docs.flutter.dev/get-started/install)
2.  **Git**: For version control.
    -   [Install Git](https://git-scm.com/downloads)
3.  **Visual Studio 2022** (Windows only):
    -   Required for building the Windows desktop app.
    -   Workload: **Desktop development with C++**.
4.  **VS Code** (Recommended):
    -   Extensions: Flutter, Dart.

---

## 📥 Installation

1.  **Clone the Repository**:
    ```bash
    git clone <repository-url>
    cd clothing_caisse_manager
    ```

2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```

---

## 🔥 Firebase Configuration

The app uses Firebase for Authentication and Database. You must configure it before running the app.

### Option A: Automated (Recommended)

1.  Install the FlutterFire CLI:
    ```bash
    dart pub global activate flutterfire_cli
    ```
2.  Configure the project:
    ```bash
    flutterfire configure
    ```
    -   Select your Firebase project (or create a new one).
    -   Select platforms: `android`, `ios`, `web`, `windows`.
    -   This will generate `lib/firebase_options.dart`.

### Option B: Manual

See `FIREBASE_SETUP.md` (if available) or follow the [FlutterFire manual installation guide](https://firebase.flutter.dev/docs/overview).

---

## ▶️ Running the App

### Windows (Desktop)
Recommended for the full POS experience (printing, cash drawer).
```bash
flutter run -d windows
```

### Web (Chrome)
Good for testing logic, but hardware features are limited.
```bash
flutter run -d chrome
```

### Android
Good for mobile management.
```bash
flutter run -d <device-id>
```

---

## 👤 First-Time Setup

1.  **Create Admin User**:
    -   Go to your Firebase Console -> Authentication.
    -   Create a user with email/password.
    -   Go to Firestore Database -> `users` collection.
    -   Create a document with the **User UID** as the ID.
    -   Add field: `role: "admin"`.

2.  **Login**:
    -   Use these credentials to log in to the app.

---

## 🆘 Need Help?

Check the `06_TROUBLESHOOTING.md` guide for common issues.
