@echo off
echo ========================================
echo Firebase Data Migration Script
echo ========================================
echo.
echo This will migrate all your student and faculty data
echo from database_service.dart to Firebase Firestore
echo.

echo Step 1: Installing dependencies...
flutter pub get

echo.
echo Step 2: Running migration...
echo Make sure you have:
echo 1. Set up Firebase project
echo 2. Updated firebase_options.dart with your config
echo 3. Enabled Firestore in Firebase Console
echo.
pause

dart run migrate_to_firebase.dart

echo.
echo Migration completed! Your data is now in Firebase.
echo.
echo You can now run your app with:
echo flutter run -d chrome
echo.
pause
