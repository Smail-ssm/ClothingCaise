# Firebase Setup Script

## Quick Setup (Recommended)

Run this command in your terminal:

```bash
flutterfire configure --project=clothing-caisse-manager
```

This will:
1. Ask you to log in to your Google account
2. Create or select a Firebase project
3. Generate `firebase_options.dart` automatically
4. Configure Android, Web, and Windows platforms

## Manual Firebase Configuration

If you prefer manual setup or the CLI doesn't work:

### 1. Create Firebase Project
- Go to https://console.firebase.google.com/
- Click "Add project"
- Name it "clothing-caisse-manager"
- Disable Google Analytics (optional)

### 2. Enable Services
- **Authentication**: Go to Build → Authentication → Get Started → Email/Password → Enable
- **Firestore**: Go to Build → Firestore Database → Create database → Start in production mode

### 3. Create Web App
- Go to Project Settings → Your apps → Web
- Register app with name "Clothing Caisse Manager Web"
- Copy the Firebase configuration

### 4. Update lib/main.dart

Replace the Firebase options in `main.dart` with your config:

```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: 'YOUR_API_KEY_HERE',
    appId: 'YOUR_APP_ID_HERE',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
  ),
);
```
CONFIG html 
```HTML

// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyC9AolU23PH-rpCwzALgTZSzoiD4TZ9MeM",
  authDomain: "clothing-caisse-manager.firebaseapp.com",
  projectId: "clothing-caisse-manager",
  storageBucket: "clothing-caisse-manager.firebasestorage.app",
  messagingSenderId: "141398138140",
  appId: "1:141398138140:web:1f9a5e204c5c91de8e6ed9",
  measurementId: "G-9FVQ55YT3J"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);
```

### 5. For Android (if deploying to Android)
- Download `google-services.json`
- Place in `android/app/` directory

## Creating First Admin User

After Firebase is configured:

1. Open Firebase Console → Authentication
2. Click "Add User"
3. Email: your-email@example.com
4. Password: your-secure-password
5. Copy the generated UID

6. Go to Firestore Database
7. Start collection: `users`
8. Document ID: [paste UID from step 5]
9. Add fields:
   - `name` (string): "Admin"
   - `email` (string): "your-email@example.com"
   - `role` (string): "admin"
   - `createdAt` (timestamp): [click "Set to current time"]
10. Save

## Testing the Setup

```bash
flutter run -d chrome
```

Login with the credentials you created!
