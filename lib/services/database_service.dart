import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseService {
  // Keys for SharedPreferences
  static const String _usersKey = 'users';
  static const String _studentsKey = 'students';
  static const String _facultyKey = 'faculty';
  static const String _attendanceKey = 'attendance';
  static const String _marksKey = 'marks';
  static const String _resultsKey = 'results';
  static const String _remarksKey = 'remarks';
  static const String _certificatesKey = 'certificates';
  static const String _jobsKey = 'jobs';
  static const String _notificationsKey = 'notifications';
  static const String _subjectsKey = 'subjects';
  static const String _timetableKey = 'timetable';
  static const String _internalMarksKey = 'internalMarks';

  // Initialize database with demo data
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (!prefs.containsKey(_usersKey)) {
      await _insertDemoData();
    }
  }

  static Future<void> _insertDemoData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Demo Users
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
        'createdAt': DateTime.now().toIso8601String(),
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
        'createdAt': DateTime.now().toIso8601String(),
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
        'createdAt': DateTime.now().toIso8601String(),
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
        'createdAt': DateTime.now().toIso8601String(),
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
        'createdAt': DateTime.now().toIso8601String(),
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
        'createdAt': DateTime.now().toIso8601String(),
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
        'createdAt': DateTime.now().toIso8601String(),
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
        'createdAt': DateTime.now().toIso8601String(),
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
        'createdAt': DateTime.now().toIso8601String(),
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
        'createdAt': DateTime.now().toIso8601String(),
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
        'createdAt': DateTime.now().toIso8601String(),
      },
    ];

    // Demo Student Profiles
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
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
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
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    ];

    // Demo Faculty
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
        'createdAt': DateTime.now().toIso8601String(),
      },
    ];

    // Demo Attendance Data
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

    // Demo Marks Data
    final marks = [
      {'studentId': 'student1', 'subject': 'CD', 'type': 'Unit Test 1', 'marks': '8', 'maxMarks': '10', 'facultyId': 'faculty1'},
      {'studentId': 'student1', 'subject': 'CD', 'type': 'Unit Test 2', 'marks': '7', 'maxMarks': '10', 'facultyId': 'faculty1'},
      {'studentId': 'student1', 'subject': 'CC', 'type': 'Unit Test 1', 'marks': '9', 'maxMarks': '10', 'facultyId': 'faculty1'},
      {'studentId': 'student1', 'subject': 'CC', 'type': 'Unit Test 2', 'marks': '8', 'maxMarks': '10', 'facultyId': 'faculty1'},
      {'studentId': 'student2', 'subject': 'CD', 'type': 'Unit Test 1', 'marks': '7', 'maxMarks': '10', 'facultyId': 'faculty1'},
      {'studentId': 'student2', 'subject': 'CD', 'type': 'Unit Test 2', 'marks': '8', 'maxMarks': '10', 'facultyId': 'faculty1'},
    ];

    // Demo Remarks
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
        'createdAt': DateTime.now().toIso8601String(),
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
        'createdAt': DateTime.now().toIso8601String(),
      },
    ];

    // Demo Certificates
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
        'createdAt': DateTime.now().toIso8601String(),
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
        'createdAt': DateTime.now().toIso8601String(),
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
        'createdAt': DateTime.now().toIso8601String(),
      },
    ];

    // Demo Jobs
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
        'createdAt': DateTime.now().toIso8601String(),
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
        'createdAt': DateTime.now().toIso8601String(),
      },
    ];

    // Save all data
    await prefs.setString(_usersKey, jsonEncode(users));
    await prefs.setString(_studentsKey, jsonEncode(students));
    await prefs.setString(_facultyKey, jsonEncode(faculty));
    await prefs.setString(_attendanceKey, jsonEncode(attendance));
    await prefs.setString(_marksKey, jsonEncode(marks));
    await prefs.setString(_remarksKey, jsonEncode(remarks));
    await prefs.setString(_certificatesKey, jsonEncode(certificates));
    await prefs.setString(_jobsKey, jsonEncode(jobs));
    await prefs.setString(_notificationsKey, jsonEncode([]));
  }

  // Authentication Methods
  static Future<Map<String, dynamic>?> authenticateUser(String username, String password) async {
    print('Auth: Attempting login for username: $username');
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey) ?? '[]';
    final users = jsonDecode(usersJson) as List;
    print('Auth: Found ${users.length} users in database');
    
    try {
      final user = users.firstWhere((u) => 
        u['username'] == username && 
        u['password'] == password && 
        u['isActive'] == true
      );
      print('Auth: Login successful for ${user['name']}');
      return user;
    } catch (e) {
      print('Auth: Login failed - $e');
      return null;
    }
  }

  static Future<bool> changePassword(String userId, String oldPassword, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey) ?? '[]';
    final users = jsonDecode(usersJson) as List;
    
    try {
      final userIndex = users.indexWhere((u) => u['id'] == userId && u['password'] == oldPassword);
      if (userIndex != -1) {
        users[userIndex]['password'] = newPassword;
        users[userIndex]['updatedAt'] = DateTime.now().toIso8601String();
        await prefs.setString(_usersKey, jsonEncode(users));
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  // Student Methods
  static Future<Map<String, dynamic>?> getStudent(String studentId) async {
    final prefs = await SharedPreferences.getInstance();
    final studentsJson = prefs.getString(_studentsKey) ?? '[]';
    final students = jsonDecode(studentsJson) as List;
    
    try {
      return students.firstWhere((student) => student['id'] == studentId);
    } catch (e) {
      return null;
    }
  }

  static Future<bool> updateStudent(String studentId, Map<String, dynamic> updates) async {
    final prefs = await SharedPreferences.getInstance();
    final studentsJson = prefs.getString(_studentsKey) ?? '[]';
    final students = jsonDecode(studentsJson) as List;
    
    try {
      final studentIndex = students.indexWhere((student) => student['id'] == studentId);
      if (studentIndex != -1) {
        students[studentIndex].addAll(updates);
        students[studentIndex]['updatedAt'] = DateTime.now().toIso8601String();
        await prefs.setString(_studentsKey, jsonEncode(students));
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  // Faculty Methods
  static Future<Map<String, dynamic>?> getFaculty(String facultyId) async {
    final prefs = await SharedPreferences.getInstance();
    final facultyJson = prefs.getString(_facultyKey) ?? '[]';
    final faculty = jsonDecode(facultyJson) as List;
    
    try {
      return faculty.firstWhere((f) => f['id'] == facultyId);
    } catch (e) {
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getAllFaculty() async {
    final prefs = await SharedPreferences.getInstance();
    final facultyJson = prefs.getString(_facultyKey) ?? '[]';
    final faculty = jsonDecode(facultyJson) as List;
    
    return faculty.cast<Map<String, dynamic>>().toList();
  }

  static Future<List<Map<String, dynamic>>> getAllStudents() async {
    final prefs = await SharedPreferences.getInstance();
    final studentsJson = prefs.getString(_studentsKey) ?? '[]';
    final students = jsonDecode(studentsJson) as List;
    
    return students.cast<Map<String, dynamic>>().toList();
  }

  // Attendance Methods
  static Future<List<Map<String, dynamic>>> getAttendance(String studentId) async {
    final prefs = await SharedPreferences.getInstance();
    final attendanceJson = prefs.getString(_attendanceKey) ?? '[]';
    final attendance = jsonDecode(attendanceJson) as List;
    
    return attendance
        .where((record) => record['studentId'] == studentId)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  static Future<bool> markAttendance(Map<String, dynamic> attendanceData) async {
    final prefs = await SharedPreferences.getInstance();
    final attendanceJson = prefs.getString(_attendanceKey) ?? '[]';
    final attendance = jsonDecode(attendanceJson) as List;
    
    attendance.add({
      ...attendanceData,
      'createdAt': DateTime.now().toIso8601String(),
    });
    
    await prefs.setString(_attendanceKey, jsonEncode(attendance));
    return true;
  }

  // Marks Methods
  static Future<List<Map<String, dynamic>>> getMarks(String studentId) async {
    final prefs = await SharedPreferences.getInstance();
    final marksJson = prefs.getString(_marksKey) ?? '[]';
    final marks = jsonDecode(marksJson) as List;
    
    return marks
        .where((record) => record['studentId'] == studentId)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  static Future<bool> addMarks(Map<String, dynamic> marksData) async {
    final prefs = await SharedPreferences.getInstance();
    final marksJson = prefs.getString(_marksKey) ?? '[]';
    final marks = jsonDecode(marksJson) as List;
    
    marks.add({
      ...marksData,
      'createdAt': DateTime.now().toIso8601String(),
    });
    
    await prefs.setString(_marksKey, jsonEncode(marks));
    return true;
  }

  // Remarks Methods
  static Future<List<Map<String, dynamic>>> getRemarks(String studentId) async {
    final prefs = await SharedPreferences.getInstance();
    final remarksJson = prefs.getString(_remarksKey) ?? '[]';
    final remarks = jsonDecode(remarksJson) as List;
    
    return remarks
        .where((remark) => remark['studentId'] == studentId)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  static Future<bool> addRemark(Map<String, dynamic> remarkData) async {
    final prefs = await SharedPreferences.getInstance();
    final remarksJson = prefs.getString(_remarksKey) ?? '[]';
    final remarks = jsonDecode(remarksJson) as List;
    
    remarks.add({
      ...remarkData,
      'id': 'remark${DateTime.now().millisecondsSinceEpoch}',
      'isEditable': false,
      'createdAt': DateTime.now().toIso8601String(),
    });
    
    await prefs.setString(_remarksKey, jsonEncode(remarks));
    return true;
  }

  // Certificate Methods
  static Future<List<Map<String, dynamic>>> getCertificates(String studentId) async {
    final prefs = await SharedPreferences.getInstance();
    final certificatesJson = prefs.getString(_certificatesKey) ?? '[]';
    final certificates = jsonDecode(certificatesJson) as List;
    
    return certificates
        .where((cert) => cert['studentId'] == studentId)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  static Future<bool> addCertificate(String studentId, Map<String, dynamic> certificateData) async {
    final prefs = await SharedPreferences.getInstance();
    final certificatesJson = prefs.getString(_certificatesKey) ?? '[]';
    final certificates = jsonDecode(certificatesJson) as List;
    
    certificates.add({
      ...certificateData,
      'id': 'cert${DateTime.now().millisecondsSinceEpoch}',
      'studentId': studentId,
      'createdAt': DateTime.now().toIso8601String(),
    });
    
    await prefs.setString(_certificatesKey, jsonEncode(certificates));
    return true;
  }

  // Job Methods
  static Future<List<Map<String, dynamic>>> getJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final jobsJson = prefs.getString(_jobsKey) ?? '[]';
    final jobs = jsonDecode(jobsJson) as List;
    
    return jobs
        .where((job) => job['isActive'] == true)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  static Future<bool> addJob(Map<String, dynamic> jobData) async {
    final prefs = await SharedPreferences.getInstance();
    final jobsJson = prefs.getString(_jobsKey) ?? '[]';
    final jobs = jsonDecode(jobsJson) as List;
    
    jobs.add({
      ...jobData,
      'id': 'job${DateTime.now().millisecondsSinceEpoch}',
      'isActive': true,
      'createdAt': DateTime.now().toIso8601String(),
    });
    
    await prefs.setString(_jobsKey, jsonEncode(jobs));
    return true;
  }

  // Notification Methods
  static Future<List<Map<String, dynamic>>> getNotifications(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getString(_notificationsKey) ?? '[]';
    final notifications = jsonDecode(notificationsJson) as List;
    
    return notifications
        .where((notif) => notif['userId'] == userId || notif['userType'] == 'all')
        .cast<Map<String, dynamic>>()
        .toList();
  }

  static Future<bool> addNotification(Map<String, dynamic> notificationData) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getString(_notificationsKey) ?? '[]';
    final notifications = jsonDecode(notificationsJson) as List;
    
    notifications.add({
      ...notificationData,
      'id': 'notif${DateTime.now().millisecondsSinceEpoch}',
      'isRead': false,
      'createdAt': DateTime.now().toIso8601String(),
    });
    
    await prefs.setString(_notificationsKey, jsonEncode(notifications));
    return true;
  }

  // Principal Monitoring Methods
  static Future<Map<String, dynamic>> getPrincipalStats() async {
    final prefs = await SharedPreferences.getInstance();
    
    final studentsJson = prefs.getString(_studentsKey) ?? '[]';
    final facultyJson = prefs.getString(_facultyKey) ?? '[]';
    final attendanceJson = prefs.getString(_attendanceKey) ?? '[]';
    final marksJson = prefs.getString(_marksKey) ?? '[]';
    
    final students = jsonDecode(studentsJson) as List;
    final faculty = jsonDecode(facultyJson) as List;
    final attendance = jsonDecode(attendanceJson) as List;
    final marks = jsonDecode(marksJson) as List;
    
    return {
      'totalStudents': students.length,
      'totalFaculty': faculty.length,
      'todayAttendance': attendance.where((a) => a['date'] == DateTime.now().toString().split(' ')[0]).length,
      'totalMarks': marks.length,
      'activeFaculty': faculty.where((f) => f['isActive'] == true).length,
    };
  }

  // Clear all data
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usersKey);
    await prefs.remove(_studentsKey);
    await prefs.remove(_facultyKey);
    await prefs.remove(_attendanceKey);
    await prefs.remove(_marksKey);
    await prefs.remove(_resultsKey);
    await prefs.remove(_remarksKey);
    await prefs.remove(_certificatesKey);
    await prefs.remove(_jobsKey);
    await prefs.remove(_notificationsKey);
    await prefs.remove(_subjectsKey);
    await prefs.remove(_timetableKey);
    await prefs.remove(_internalMarksKey);
    print('Database: All data cleared');
  }

  // Subjects Methods
  static Future<List<Map<String, dynamic>>> getSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    final subjectsJson = prefs.getString(_subjectsKey) ?? '[]';
    final subjects = jsonDecode(subjectsJson) as List;
    
    return subjects
        .where((subject) => subject['isActive'] == true)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  static Future<bool> addSubject(Map<String, dynamic> subjectData) async {
    final prefs = await SharedPreferences.getInstance();
    final subjectsJson = prefs.getString(_subjectsKey) ?? '[]';
    final subjects = jsonDecode(subjectsJson) as List;
    
    subjects.add({
      ...subjectData,
      'id': 'sub${DateTime.now().millisecondsSinceEpoch}',
      'isActive': true,
      'createdAt': DateTime.now().toIso8601String(),
    });
    
    await prefs.setString(_subjectsKey, jsonEncode(subjects));
    return true;
  }

  // Timetable Methods
  static Future<List<Map<String, dynamic>>> getTimetable() async {
    final prefs = await SharedPreferences.getInstance();
    final timetableJson = prefs.getString(_timetableKey) ?? '[]';
    final timetable = jsonDecode(timetableJson) as List;
    
    return timetable.cast<Map<String, dynamic>>().toList();
  }

  static Future<bool> updateTimetable(String timetableId, Map<String, dynamic> timetableData) async {
    final prefs = await SharedPreferences.getInstance();
    final timetableJson = prefs.getString(_timetableKey) ?? '[]';
    final timetable = jsonDecode(timetableJson) as List;
    
    try {
      final timetableIndex = timetable.indexWhere((tt) => tt['id'] == timetableId);
      if (timetableIndex != -1) {
        timetable[timetableIndex] = {
          ...timetableData,
          'id': timetableId,
          'updatedAt': DateTime.now().toIso8601String(),
        };
        await prefs.setString(_timetableKey, jsonEncode(timetable));
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  static Future<bool> addTimetable(Map<String, dynamic> timetableData) async {
    final prefs = await SharedPreferences.getInstance();
    final timetableJson = prefs.getString(_timetableKey) ?? '[]';
    final timetable = jsonDecode(timetableJson) as List;
    
    timetable.add({
      ...timetableData,
      'createdAt': DateTime.now().toIso8601String(),
    });
    
    await prefs.setString(_timetableKey, jsonEncode(timetable));
    return true;
  }

  // Internal Marks Methods
  static Future<List<Map<String, dynamic>>> getInternalMarks(String studentId) async {
    final prefs = await SharedPreferences.getInstance();
    final internalMarksJson = prefs.getString(_internalMarksKey) ?? '[]';
    final internalMarks = jsonDecode(internalMarksJson) as List;
    
    return internalMarks
        .where((mark) => mark['studentId'] == studentId)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  static Future<bool> addInternalMarks(Map<String, dynamic> marksData) async {
    final prefs = await SharedPreferences.getInstance();
    final internalMarksJson = prefs.getString(_internalMarksKey) ?? '[]';
    final internalMarks = jsonDecode(internalMarksJson) as List;
    
    internalMarks.add({
      ...marksData,
      'id': 'im${DateTime.now().millisecondsSinceEpoch}',
      'isLocked': false,
      'createdAt': DateTime.now().toIso8601String(),
    });
    
    await prefs.setString(_internalMarksKey, jsonEncode(internalMarks));
    return true;
  }

  static Future<bool> lockInternalMarks(String marksId) async {
    final prefs = await SharedPreferences.getInstance();
    final internalMarksJson = prefs.getString(_internalMarksKey) ?? '[]';
    final internalMarks = jsonDecode(internalMarksJson) as List;
    
    try {
      final marksIndex = internalMarks.indexWhere((mark) => mark['id'] == marksId);
      if (marksIndex != -1) {
        internalMarks[marksIndex]['isLocked'] = true;
        internalMarks[marksIndex]['updatedAt'] = DateTime.now().toIso8601String();
        await prefs.setString(_internalMarksKey, jsonEncode(internalMarks));
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  static Future<bool> updateInternalMarks(String marksId, Map<String, dynamic> updates) async {
    final prefs = await SharedPreferences.getInstance();
    final internalMarksJson = prefs.getString(_internalMarksKey) ?? '[]';
    final internalMarks = jsonDecode(internalMarksJson) as List;
    
    try {
      final marksIndex = internalMarks.indexWhere((mark) => mark['id'] == marksId);
      if (marksIndex != -1) {
        internalMarks[marksIndex].addAll(updates);
        internalMarks[marksIndex]['updatedAt'] = DateTime.now().toIso8601String();
        await prefs.setString(_internalMarksKey, jsonEncode(internalMarks));
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  // Faculty role check
  static Future<bool> isHod(String facultyId) async {
    final faculty = await getFaculty(facultyId);
    return faculty?['role'] == 'hod';
  }

  // Reset database (clear and reinitialize)
  static Future<void> resetDatabase() async {
    await clearAllData();
    await initialize();
    print('Database: Reset complete');
  }

  // Force reset with new faculty data
  static Future<void> forceResetWithNewFaculty() async {
    await clearAllData();
    await initialize();
    print('Database: Force reset with new faculty data complete');
  }
}
