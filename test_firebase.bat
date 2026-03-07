@echo off
echo ========================================
echo Firebase Connection Test
echo ========================================
echo.
echo This script will test your Firebase setup
echo Make sure you have completed all setup steps first!
echo.
pause

echo.
echo Step 1: Installing dependencies...
flutter pub get

echo.
echo Step 2: Testing Firebase connection...
dart run test_firebase_connection.dart

echo.
echo Test completed! Check the results above.
echo.
pause
