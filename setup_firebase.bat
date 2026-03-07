@echo off
echo Setting up Firebase for College Portal...
echo.

echo Step 1: Installing Firebase CLI...
powershell -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser"
npm install -g firebase-tools

echo.
echo Step 2: Login to Firebase...
echo Please open the browser window that will appear and login to your Google account.
firebase login

echo.
echo Step 3: Initializing Firebase...
echo This will configure your project with Firebase.
flutterfire configure

echo.
echo Firebase setup completed!
echo.
echo Next steps:
echo 1. Go to https://console.firebase.google.com/
echo 2. Create a new project named 'college-portal-complete'
echo 3. Enable Firestore Database
echo 4. Update firebase_options.dart with your actual config
echo 5. Run: flutter run -d chrome
echo.
pause
