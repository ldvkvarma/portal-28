// Firebase Connection Test Script
// Run this to verify your Firebase setup is working correctly

import 'lib/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lib/services/database_service.dart';

Future<void> main() async {
  print('🔥 Testing Firebase Connection...');
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
    
    // Test Firestore connection
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    
    // Test reading users
    final usersSnapshot = await firestore.collection('users').limit(1).get();
    print('✅ Firestore connection successful');
    print('📊 Found ${usersSnapshot.docs.length} users in database');
    
    // Test authentication
    final testUser = await DatabaseService.authenticateUser('23KT1A0596', 'password123');
    if (testUser != null) {
      print('✅ Authentication test passed');
      print('👤 User: ${testUser['name']} (${testUser['userType']})');
    } else {
      print('❌ Authentication test failed - check user credentials');
    }
    
    // Test student data
    final studentData = await DatabaseService.getStudent('student1');
    if (studentData != null) {
      print('✅ Student data test passed');
      print('🎓 Student: ${studentData['name']} - ${studentData['branch']}');
    } else {
      print('❌ Student data test failed - check student collection');
    }
    
    print('\n🎉 Firebase setup test completed!');
    print('📝 If all tests passed, your app is ready to use.');
    
  } catch (e) {
    print('❌ Firebase connection failed: $e');
    print('\n🔧 Troubleshooting:');
    print('1. Check your Firebase config in firebase_options.dart');
    print('2. Ensure Firestore is enabled in Firebase Console');
    print('3. Verify internet connection');
    print('4. Check Firebase Security Rules');
  }
}
