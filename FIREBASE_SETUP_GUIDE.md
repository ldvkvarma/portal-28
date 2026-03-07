# Firebase Setup Guide for College Portal

## Prerequisites
1. Node.js and npm installed on your system
2. Google account for Firebase console access

## Step 1: Install Firebase CLI

### For Windows (PowerShell):
```powershell
# Allow script execution temporarily
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Install Firebase CLI
npm install -g firebase-tools

# Reset execution policy if needed
Set-ExecutionPolicy -ExecutionPolicy Restricted -Scope CurrentUser
```

### Alternative: Use Chocolatey
```powershell
choco install firebase-cli
```

## Step 2: Login to Firebase
```bash
firebase login
```

## Step 3: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `college-portal-complete`
4. Enable Google Analytics (optional)
5. Click "Create project"

## Step 4: Initialize Firebase in Flutter
```bash
# Navigate to your project directory
cd c:\Users\USER\Desktop\portal-28

# Initialize Firebase
firebase init
```

Or use FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

## Step 5: Configure Firebase for Different Platforms

### For Web:
1. In Firebase Console, go to Project Settings
2. Add Web App
3. Copy the Firebase config
4. Update `lib/firebase_options.dart` with your actual config

### For Android:
1. Download `google-services.json`
2. Place it in `android/app/google-services.json`
3. Update `android/build.gradle` and `android/app/build.gradle`

### For Windows:
1. In Firebase Console, add Windows App
2. Download the config file
3. Update your Windows build configuration

## Step 6: Update Firebase Configuration

Replace the placeholder values in `lib/firebase_options.dart` with your actual Firebase config:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'your-actual-web-api-key',
  appId: 'your-actual-web-app-id',
  messagingSenderId: 'your-actual-sender-id',
  projectId: 'your-actual-project-id',
  authDomain: 'your-project.firebaseapp.com',
  storageBucket: 'your-project.appspot.com',
);
```

## Step 7: Enable Firestore Database
1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location

## Step 8: Run the Application
```bash
flutter run -d chrome  # For web
flutter run -d windows  # For Windows (after fixing CMake issues)
```

## Step 9: Test Firebase Connection
The app will automatically use Firebase if `_useFirebase = true` in `database_service.dart`. You should see Firebase-related logs in the console.

## Troubleshooting

### Windows Build Issues:
If you encounter CMake errors with Firebase on Windows:
1. Use web version instead: `flutter run -d chrome`
2. Or temporarily disable Firebase: set `_useFirebase = false`

### Firebase Connection Issues:
1. Check your Firebase config in `firebase_options.dart`
2. Ensure Firestore rules allow access
3. Verify internet connection

### Web CORS Issues:
Add CORS rules in Firebase Console → Firestore → Rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

## Next Steps
1. Test authentication with demo users
2. Verify data persistence in Firestore
3. Deploy to Firebase Hosting for production

## Demo Users for Testing
- Student: username `23KT1A0596`, password `password123`
- Principal: username `principal`, password `admin123`
- Faculty: username `hod001`, password `faculty123`
- Placement: username `placement`, password `place123`
