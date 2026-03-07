// Firebase Data Migration Script
// This script migrates all data from database_service.dart to Firebase
// Run with: dart run migrate_to_firebase.dart

import 'lib/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  print('Starting Firebase migration...');
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  try {
    // Clear existing data
    await clearAllData(firestore);
    
    // Migrate all data
    await migrateUsers(firestore);
    await migrateStudents(forestore);
    await migrateFaculty(firestore);
    await migrateAttendance(firestore);
    await migrateMarks(forestore);
    await migrateRemarks(forestore);
    await migrateCertificates(forestore);
    await migrateJobs(forestore);
    await migrateNotifications(firestore);
    
    print('✅ Migration completed successfully!');
    print('📊 Data summary:');
    print('   - Users: 11 (7 faculty, 2 students, 1 principal, 1 placement)');
    print('   - Students: 2');
    print('   - Faculty: 1');
    print('   - Attendance: 9 records');
    print('   - Marks: 6 records');
    print('   - Remarks: 2');
    print('   - Certificates: 3');
    print('   - Jobs: 2');
    
  } catch (e) {
    print('❌ Migration failed: $e');
  }
}

Future<void> clearAllData(FirebaseFirestore firestore) async {
  print('🗑️  Clearing existing Firebase data...');
  
  final collections = [
    'users', 'students', 'faculty', 'attendance', 
    'marks', 'remarks', 'certificates', 'jobs', 
    'notifications', 'subjects', 'timetable', 'internalMarks'
  ];
  
  for (final collection in collections) {
    final querySnapshot = await firestore.collection(collection).get();
    for (final doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }
  print('✅ Existing data cleared');
}

Future<void> migrateUsers(FirebaseFirestore firestore) async {
  print('👥 Migrating users...');
  
  final users = [
    {
      'id': 'student1',
      'username': '23KT1A0596',
      'password': 'password123',
      'userType': 'student',
      'name': 'LANKE DURGA VENKATA KRISHNA VARMA',
      'email': 'lanke.student@college.edu',
      'phone': '+91 98765 43210',
      'isActive': true,
      'createdAt': Timestamp.now(),
    },
    {
      'id': 'student2',
      'username': '23KT1A0597',
      'password': 'password123',
      'userType': 'student',
      'name': 'ANOTHER STUDENT',
      'email': 'student2@college.edu',
      'phone': '+91 98765 43211',
      'isActive': true,
      'createdAt': Timestamp.now(),
    },
    {
      'id': 'principal1',
      'username': 'principal',
      'password': 'admin123',
      'userType': 'principal',
      'name': 'Dr. Principal Name',
      'email': 'principal@college.edu',
      'phone': '+91 98765 43213',
      'isActive': true,
      'createdAt': Timestamp.now(),
    },
    {
      'id': 'placement1',
      'username': 'placement',
      'password': 'place123',
      'userType': 'placement',
      'name': 'Placement Officer',
      'email': 'placement@college.edu',
      'phone': '+91 98765 43214',
      'isActive': true,
      'createdAt': Timestamp.now(),
    },
    {
      'id': 'faculty1',
      'username': 'hod001',
      'password': 'faculty123',
      'userType': 'faculty',
      'name': 'Dr. Ramesh Kumar',
      'email': 'ramesh.kumar@college.edu',
      'phone': '+91 98765 43212',
      'department': 'CSE',
      'designation': 'Professor & HoD',
      'role': 'hod',
      'isActive': true,
      'createdAt': Timestamp.now(),
    },
    {
      'id': 'faculty2',
      'username': 'faculty002',
      'password': 'faculty123',
      'userType': 'faculty',
      'name': 'Dr. Sarah Johnson',
      'email': 'sarah.johnson@college.edu',
      'phone': '+91 98765 43213',
      'department': 'CSE',
      'designation': 'Associate Professor',
      'role': 'normal',
      'isActive': true,
      'createdAt': Timestamp.now(),
    },
    {
      'id': 'faculty3',
      'username': 'faculty003',
      'password': 'faculty123',
      'userType': 'faculty',
      'name': 'Dr. Michael Chen',
      'email': 'michael.chen@college.edu',
      'phone': '+91 98765 43214',
      'department': 'CSE',
      'designation': 'Assistant Professor',
      'role': 'normal',
      'isActive': true,
      'createdAt': Timestamp.now(),
    },
    {
      'id': 'faculty4',
      'username': 'faculty004',
      'password': 'faculty123',
      'userType': 'faculty',
      'name': 'Dr. Emily Williams',
      'email': 'emily.williams@college.edu',
      'phone': '+91 98765 43215',
      'department': 'CSE',
      'designation': 'Assistant Professor',
      'role': 'normal',
      'isActive': true,
      'createdAt': Timestamp.now(),
    },
    {
      'id': 'faculty5',
      'username': 'faculty005',
      'password': 'faculty123',
      'userType': 'faculty',
      'name': 'Dr. David Brown',
      'email': 'david.brown@college.edu',
      'phone': '+91 98765 43216',
      'department': 'CSE',
      'designation': 'Lecturer',
      'role': 'normal',
      'isActive': true,
      'createdAt': Timestamp.now(),
    },
    {
      'id': 'faculty6',
      'username': 'faculty006',
      'password': 'faculty123',
      'userType': 'faculty',
      'name': 'Dr. Lisa Anderson',
      'email': 'lisa.anderson@college.edu',
      'phone': '+91 98765 43217',
      'department': 'CSE',
      'designation': 'Lecturer',
      'role': 'normal',
      'isActive': true,
      'createdAt': Timestamp.now(),
    },
    {
      'id': 'faculty7',
      'username': 'faculty007',
      'password': 'faculty123',
      'userType': 'faculty',
      'name': 'Dr. James Wilson',
      'email': 'james.wilson@college.edu',
      'phone': '+91 98765 43218',
      'department': 'CSE',
      'designation': 'Lecturer',
      'role': 'normal',
      'isActive': true,
      'createdAt': Timestamp.now(),
    },
  ];

  for (final user in users) {
    await firestore.collection('users').doc(user['id']).set(user);
  }
  print('✅ Users migrated: ${users.length}');
}

Future<void> migrateStudents(FirebaseFirestore firestore) async {
  print('🎓 Migrating students...');
  
  final students = [
    {
      'id': 'student1',
      'admissionNo': '23KT1A0596',
      'rollNo': '23KT1A0596',
      'name': 'LANKE DURGA VENKATA KRISHNA VARMA',
      'course': 'B.Tech',
      'branch': 'CSE',
      'semester': 'VI',
      'section': 'A',
      'batch': '2023-2027',
      'cgpa': '8.44',
      'backlogs': 2,
      'dob': '15/10/2005',
      'gender': 'Male',
      'bloodGroup': 'O+',
      'nationality': 'Indian',
      'religion': 'Hindu',
      'category': 'OC',
      'aadhar': '123456789012',
      'fatherName': 'LANKE SURENDRA',
      'fatherOccupation': 'Business',
      'motherName': 'LANKE GOWRI',
      'motherOccupation': 'Home Maker',
      'parentPhone': '+91 98765 43215',
      'address': '123 College Road, Hyderabad, Telangana - 500001',
      'permanentAddress': '456 Home Town, District, State - 123456',
      'emergencyContact': '+91 98765 43216',
      'email': 'lanke.student@college.edu',
      'phone': '+91 98765 43210',
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    },
    {
      'id': 'student2',
      'admissionNo': '23KT1A0597',
      'rollNo': '23KT1A0597',
      'name': 'ANOTHER STUDENT',
      'course': 'B.Tech',
      'branch': 'CSE',
      'semester': 'VI',
      'section': 'A',
      'batch': '2023-2027',
      'cgpa': '7.89',
      'backlogs': 0,
      'dob': '20/08/2005',
      'gender': 'Male',
      'bloodGroup': 'B+',
      'nationality': 'Indian',
      'religion': 'Hindu',
      'category': 'BC',
      'aadhar': '987654321098',
      'fatherName': 'FATHER NAME',
      'fatherOccupation': 'Government Employee',
      'motherName': 'MOTHER NAME',
      'motherOccupation': 'Teacher',
      'parentPhone': '+91 98765 43217',
      'address': '789 Student Street, Hyderabad, Telangana - 500002',
      'permanentAddress': '321 Native Place, District, State - 654321',
      'emergencyContact': '+91 98765 43218',
      'email': 'student2@college.edu',
      'phone': '+91 98765 43211',
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    },
  ];

  for (final student in students) {
    await firestore.collection('students').doc(student['id']).set(student);
  }
  print('✅ Students migrated: ${students.length}');
}

Future<void> migrateFaculty(FirebaseFirestore firestore) async {
  print('👨‍🏫 Migrating faculty...');
  
  final faculty = [
    {
      'id': 'faculty1',
      'employeeId': 'EMP001',
      'name': 'Dr. John Smith',
      'department': 'CSE',
      'designation': 'Associate Professor',
      'email': 'john.smith@college.edu',
      'phone': '+91 98765 43212',
      'qualification': 'Ph.D. in Computer Science',
      'experience': '12 Years',
      'specialization': 'Machine Learning, AI',
      'subjects': ['CD', 'CC', 'ML'],
      'isActive': true,
      'createdAt': Timestamp.now(),
    },
  ];

  for (final f in faculty) {
    await firestore.collection('faculty').doc(f['id']).set(f);
  }
  print('✅ Faculty migrated: ${faculty.length}');
}

Future<void> migrateAttendance(FirebaseFirestore firestore) async {
  print('📊 Migrating attendance...');
  
  final attendance = [
    {'studentId': 'student1', 'subject': 'CD', 'date': '2024-12-08', 'status': 'P', 'facultyId': 'faculty1'},
    {'studentId': 'student1', 'subject': 'CD', 'date': '2024-12-09', 'status': 'P', 'facultyId': 'faculty1'},
    {'studentId': 'student1', 'subject': 'CD', 'date': '2024-12-10', 'status': 'A', 'facultyId': 'faculty1'},
    {'studentId': 'student1', 'subject': 'CC', 'date': '2024-12-08', 'status': 'P', 'facultyId': 'faculty1'},
    {'studentId': 'student1', 'subject': 'CC', 'date': '2024-12-09', 'status': 'A', 'facultyId': 'faculty1'},
    {'studentId': 'student1', 'subject': 'CC', 'date': '2024-12-10', 'status': 'P', 'facultyId': 'faculty1'},
    {'studentId': 'student2', 'subject': 'CD', 'date': '2024-12-08', 'status': 'P', 'facultyId': 'faculty1'},
    {'studentId': 'student2', 'subject': 'CD', 'date': '2024-12-09', 'status': 'P', 'facultyId': 'faculty1'},
    {'studentId': 'student2', 'subject': 'CD', 'date': '2024-12-10', 'status': 'P', 'facultyId': 'faculty1'},
  ];

  for (int i = 0; i < attendance.length; i++) {
    final attendanceData = Map<String, dynamic>.from(attendance[i]);
    attendanceData['createdAt'] = Timestamp.now();
    await firestore.collection('attendance').doc('attendance$i').set(attendanceData);
  }
  print('✅ Attendance migrated: ${attendance.length}');
}

Future<void> migrateMarks(FirebaseFirestore firestore) async {
  print('📝 Migrating marks...');
  
  final marks = [
    {'studentId': 'student1', 'subject': 'CD', 'type': 'Unit Test 1', 'marks': '8', 'maxMarks': '10', 'facultyId': 'faculty1'},
    {'studentId': 'student1', 'subject': 'CD', 'type': 'Unit Test 2', 'marks': '7', 'maxMarks': '10', 'facultyId': 'faculty1'},
    {'studentId': 'student1', 'subject': 'CC', 'type': 'Unit Test 1', 'marks': '9', 'maxMarks': '10', 'facultyId': 'faculty1'},
    {'studentId': 'student1', 'subject': 'CC', 'type': 'Unit Test 2', 'marks': '8', 'maxMarks': '10', 'facultyId': 'faculty1'},
    {'studentId': 'student2', 'subject': 'CD', 'type': 'Unit Test 1', 'marks': '7', 'maxMarks': '10', 'facultyId': 'faculty1'},
    {'studentId': 'student2', 'subject': 'CD', 'type': 'Unit Test 2', 'marks': '8', 'maxMarks': '10', 'facultyId': 'faculty1'},
  ];

  for (int i = 0; i < marks.length; i++) {
    final marksData = Map<String, dynamic>.from(marks[i]);
    marksData['createdAt'] = Timestamp.now();
    await firestore.collection('marks').doc('marks$i').set(marksData);
  }
  print('✅ Marks migrated: ${marks.length}');
}

Future<void> migrateRemarks(FirebaseFirestore firestore) async {
  print('💬 Migrating remarks...');
  
  final remarks = [
    {
      'id': 'remark1',
      'studentId': 'student1',
      'facultyId': 'faculty1',
      'subject': 'CD',
      'remark': 'Excellent performance in practical sessions',
      'type': 'positive',
      'date': '2024-12-01',
      'isEditable': false,
      'createdAt': Timestamp.now(),
    },
    {
      'id': 'remark2',
      'studentId': 'student1',
      'facultyId': 'faculty1',
      'subject': 'CC',
      'remark': 'Needs improvement in theoretical concepts',
      'type': 'improvement',
      'date': '2024-12-05',
      'isEditable': false,
      'createdAt': Timestamp.now(),
    },
  ];

  for (final remark in remarks) {
    await firestore.collection('remarks').doc(remark['id']).set(remark);
  }
  print('✅ Remarks migrated: ${remarks.length}');
}

Future<void> migrateCertificates(FirebaseFirestore firestore) async {
  print('🏆 Migrating certificates...');
  
  final certificates = [
    {
      'id': 'cert1',
      'studentId': 'student1',
      'title': 'Python Programming Internship',
      'organization': 'Tech Solutions Inc.',
      'duration': '3 Months',
      'startDate': '2024-06-01',
      'endDate': '2024-08-31',
      'description': 'Worked on Python web development projects',
      'certificateFile': 'python_intern.pdf',
      'type': 'internship',
      'createdAt': Timestamp.now(),
    },
    {
      'id': 'cert2',
      'studentId': 'student1',
      'title': 'Hackathon Winner',
      'organization': 'College Tech Fest',
      'duration': '2 Days',
      'startDate': '2024-09-15',
      'endDate': '2024-09-16',
      'description': 'Won first prize in college hackathon',
      'certificateFile': 'hackathon_cert.pdf',
      'type': 'hackathon',
      'createdAt': Timestamp.now(),
    },
    {
      'id': 'cert3',
      'studentId': 'student2',
      'title': 'Machine Learning Workshop',
      'organization': 'AI Institute',
      'duration': '1 Week',
      'startDate': '2024-07-10',
      'endDate': '2024-07-17',
      'description': 'Completed ML workshop with project',
      'certificateFile': 'ml_workshop.pdf',
      'type': 'workshop',
      'createdAt': Timestamp.now(),
    },
  ];

  for (final cert in certificates) {
    await firestore.collection('certificates').doc(cert['id']).set(cert);
  }
  print('✅ Certificates migrated: ${certificates.length}');
}

Future<void> migrateJobs(FirebaseFirestore firestore) async {
  print('💼 Migrating jobs...');
  
  final jobs = [
    {
      'id': 'job1',
      'title': 'Software Developer',
      'company': 'Tech Corp',
      'location': 'Hyderabad',
      'type': 'Full-time',
      'experience': '0-2 Years',
      'salary': '8-12 LPA',
      'skills': ['Python', 'Java', 'SQL', 'React'],
      'description': 'Looking for B.Tech graduates with good programming skills',
      'postedBy': 'placement1',
      'postedDate': '2024-12-01',
      'deadline': '2024-12-31',
      'isActive': true,
      'createdAt': Timestamp.now(),
    },
    {
      'id': 'job2',
      'title': 'Data Analyst Intern',
      'company': 'Data Analytics Ltd',
      'location': 'Bangalore',
      'type': 'Internship',
      'experience': '0-1 Years',
      'salary': '15K/month',
      'skills': ['Python', 'SQL', 'Excel', 'Statistics'],
      'description': 'Internship opportunity for data analysis',
      'postedBy': 'placement1',
      'postedDate': '2024-12-05',
      'deadline': '2024-12-20',
      'isActive': true,
      'createdAt': Timestamp.now(),
    },
  ];

  for (final job in jobs) {
    await firestore.collection('jobs').doc(job['id']).set(job);
  }
  print('✅ Jobs migrated: ${jobs.length}');
}

Future<void> migrateNotifications(FirebaseFirestore firestore) async {
  print('🔔 Migrating notifications...');
  
  // Empty notifications array as per original data
  await firestore.collection('notifications').doc('init').set({
    'initialized': true,
    'createdAt': Timestamp.now(),
  });
  print('✅ Notifications migrated');
}
