// Firebase configuration file for College Portal
// This file will be automatically generated when you run flutterfire configure
// Replace the placeholder values below with your actual Firebase config

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
/// 
/// To get your actual Firebase configuration:
/// 1. Go to https://console.firebase.google.com/
/// 2. Create a project named 'college-portal-complete'
/// 3. Add your app (Web, Android, Windows)
/// 4. Copy the configuration here
/// 
/// Or run: flutterfire configure
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Replace these with your actual Firebase config from Firebase Console
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDemoKey-ReplaceWithActualKey',
    appId: '1:1234567890:web:abcdef1234567890',
    messagingSenderId: '1234567890',
    projectId: 'college-portal-complete',
    authDomain: 'college-portal-complete.firebaseapp.com',
    storageBucket: 'college-portal-complete.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDemoKey-ReplaceWithActualKey',
    appId: '1:1234567890:android:abcdef1234567890',
    messagingSenderId: '1234567890',
    projectId: 'college-portal-complete',
    storageBucket: 'college-portal-complete.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDemoKey-ReplaceWithActualKey',
    appId: '1:1234567890:ios:abcdef1234567890',
    messagingSenderId: '1234567890',
    projectId: 'college-portal-complete',
    storageBucket: 'college-portal-complete.appspot.com',
    iosBundleId: 'com.example.collegePortalComplete',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDemoKey-ReplaceWithActualKey',
    appId: '1:1234567890:macos:abcdef1234567890',
    messagingSenderId: '1234567890',
    projectId: 'college-portal-complete',
    storageBucket: 'college-portal-complete.appspot.com',
    iosBundleId: 'com.example.collegePortalComplete',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDemoKey-ReplaceWithActualKey',
    appId: '1:1234567890:windows:abcdef1234567890',
    messagingSenderId: '1234567890',
    projectId: 'college-portal-complete',
    authDomain: 'college-portal-complete.firebaseapp.com',
    storageBucket: 'college-portal-complete.appspot.com',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyDemoKey-ReplaceWithActualKey',
    appId: '1:1234567890:linux:abcdef1234567890',
    messagingSenderId: '1234567890',
    projectId: 'college-portal-complete',
    storageBucket: 'college-portal-complete.appspot.com',
  );
}
