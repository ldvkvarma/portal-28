# Quick Firebase Setup Guide

## Step 1: Create Firebase Project
1. Go to https://console.firebase.google.com/
2. Click "Add project"
3. Name it: `college-portal-complete`
4. Click "Continue"
5. Disable Google Analytics (optional)
6. Click "Create project"

## Step 2: Enable Firestore Database
1. In your project dashboard, click "Firestore Database"
2. Click "Create database"
3. Select "Start in test mode"
4. Choose a location (select asia-south1 for better performance)
5. Click "Enable"

## Step 3: Add Web App
1. In Firebase Console, click the Web icon (</>)
2. App nickname: `College Portal Web`
3. Click "Register app"
4. Copy the firebaseConfig object
5. Click "Continue to console"

## Step 4: Update Firebase Configuration
Replace the content of `lib/firebase_options.dart` with your actual config:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'PASTE_YOUR_API_KEY_HERE',
  appId: 'PASTE_YOUR_APP_ID_HERE',
  messagingSenderId: 'PASTE_YOUR_SENDER_ID_HERE',
  projectId: 'college-portal-complete',
  authDomain: 'college-portal-complete.firebaseapp.com',
  storageBucket: 'college-portal-complete.appspot.com',
);
```

## Step 5: Run Your App
```bash
flutter run -d chrome
```

Your app will automatically insert all the demo data into Firebase on first run!

## Demo Login Credentials:
- Student: `23KT1A0596` / `password123`
- Principal: `principal` / `admin123`
- Faculty (HoD): `hod001` / `faculty123`
- Placement: `placement` / `place123`

## What Gets Added Automatically:
✅ 11 Users (7 faculty, 2 students, 1 principal, 1 placement)
✅ 2 Complete student profiles
✅ 1 Faculty profile
✅ 9 Attendance records
✅ 6 Marks records
✅ 2 Remarks
✅ 3 Certificates
✅ 2 Job postings

## Troubleshooting:
If you see Firebase errors, make sure:
1. Your Firebase config is correct
2. Firestore is enabled
3. Internet connection is working
4. No firewall blocking Firebase

The app will fall back to local storage if Firebase fails to connect.
