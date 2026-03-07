// Script to manually add students to Firebase
// Run this script with: dart run add_student_to_firebase.dart

import 'lib/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  // Add the student you specified
  await addStudent(firestore, {
    'id': 'student1',
    'username': '23KT1A0596',
    'password': 'password123',
    'userType': 'student',
    'name': 'LANKE DURGA VENKATA KRISHNA VARMA',
    'email': 'lanke.student@college.edu',
    'phone': '+91 98765 43210',
    'isActive': true,
    'createdAt': Timestamp.now(),
  });
  
  // Add additional students if needed
  await addStudent(firestore, {
    'id': 'student3',
    'username': '23KT1A0598',
    'password': 'password123',
    'userType': 'student',
    'name': 'NEW STUDENT NAME',
    'email': 'student3@college.edu',
    'phone': '+91 98765 43219',
    'isActive': true,
    'createdAt': Timestamp.now(),
  });
  
  print('Students added to Firebase successfully!');
}

Future<void> addStudent(FirebaseFirestore firestore, Map<String, dynamic> studentData) async {
  try {
    // Add to users collection (for authentication)
    await firestore.collection('users').doc(studentData['id']).set(studentData);
    
    // Add corresponding student profile data
    final studentProfile = {
      'id': studentData['id'],
      'admissionNo': studentData['username'],
      'rollNo': studentData['username'],
      'name': studentData['name'],
      'email': studentData['email'],
      'phone': studentData['phone'],
      'course': 'B.Tech',
      'branch': 'CSE',
      'semester': 'VI',
      'section': 'A',
      'batch': '2023-2027',
      'cgpa': '8.44',
      'backlogs': 0,
      'dob': '15/10/2005',
      'gender': 'Male',
      'bloodGroup': 'O+',
      'nationality': 'Indian',
      'religion': 'Hindu',
      'category': 'OC',
      'aadhar': '123456789012',
      'fatherName': 'FATHER NAME',
      'fatherOccupation': 'Business',
      'motherName': 'MOTHER NAME',
      'motherOccupation': 'Home Maker',
      'parentPhone': '+91 98765 43215',
      'address': '123 College Road, Hyderabad, Telangana - 500001',
      'permanentAddress': '456 Home Town, District, State - 123456',
      'emergencyContact': '+91 98765 43216',
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    };
    
    await firestore.collection('students').doc(studentData['id']).set(studentProfile);
    
    print('Added student: ${studentData['name']} (${studentData['username']})');
  } catch (e) {
    print('Error adding student ${studentData['id']}: $e');
  }
}
