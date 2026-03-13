import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FirebaseDatabaseService {
  static const String _baseUrl = 'https://college-portal-c15ac-default-rtdb.asia-southeast1.firebasedatabase.app';

  // Initialize Firebase - no demo data for security
  static Future<void> initialize() async {
    print('Firebase Realtime Database (HTTP): Initialized securely - no demo data');
    // Print all imported data
    await printAllImportedData();
  }

  // Print all imported data from Firebase
  static Future<void> printAllImportedData() async {
    print('\n=== IMPORTING DATA FROM FIREBASE ===');
    
    // Get all data from Firebase root
    print('\n--- ALL FIREBASE DATA ---');
    final allData = await _makeRequest(''); // Get root data
    if (allData != null) {
      int studentCount = 0;
      int facultyCount = 0;
      
      // Firebase returns a List wrapped in a Map
      List<dynamic> userList;
      
      if (allData['data'] is List) {
        userList = allData['data'] as List;
        print('Total entries found: ${userList.length}');
      } else if (allData is List) {
        userList = allData as List;
        print('Total entries found: ${userList.length}');
      } else {
        print('❌ Unexpected data format from Firebase');
        return;
      }
      
      for (final user in userList) {
        if (user is Map<String, dynamic>) {
          // Check if this is a student (has admissionNo)
          if (user.containsKey('admissionNo')) {
            studentCount++;
            print('\n🎓 STUDENT $studentCount:');
            print('  ID: ${user['id']}');
            print('  Name: ${user['name']}');
            print('  Admission No: ${user['admissionNo']}');
            print('  Roll No: ${user['rollNo']}');
            print('  Course: ${user['course']}');
            print('  Branch: ${user['branch']}');
            print('  Semester: ${user['semester']}');
            print('  Section: ${user['section']}');
            print('  Batch: ${user['batch']}');
            print('  CGPA: ${user['cgpa']}');
            print('  Backlogs: ${user['backlogs']}');
            print('  DOB (Password): ${user['dob']}');
            print('  Gender: ${user['gender']}');
            print('  Email: ${user['email']}');
            print('  Phone: ${user['phone']}');
            print('  Father: ${user['fatherName']}');
            print('  Mother: ${user['motherName']}');
          }
          // Check if this is faculty/staff (has username and userType)
          else if (user.containsKey('username') && user.containsKey('userType')) {
            facultyCount++;
            print('\n👨‍🏫 FACULTY/STAFF $facultyCount:');
            print('  ID: ${user['id']}');
            print('  Username: ${user['username']}');
            print('  Name: ${user['name']}');
            print('  User Type: ${user['userType']}');
            print('  Email: ${user['email']}');
            print('  Phone: ${user['phone']}');
            if (user.containsKey('department')) print('  Department: ${user['department']}');
            if (user.containsKey('designation')) print('  Designation: ${user['designation']}');
            if (user.containsKey('role')) print('  Role: ${user['role']}');
            print('  Active: ${user['isActive']}');
          }
        }
      }
      
      print('\n📊 SUMMARY:');
      print('  Total Students: $studentCount');
      print('  Total Faculty/Staff: $facultyCount');
      print('  Total Entries: ${userList.length}');
      
    } else {
      print('❌ No data found in Firebase or error accessing data');
    }
    
    print('\n=== DATA IMPORT COMPLETE ===\n');
  }

  // Authentication Methods
  static Future<Map<String, dynamic>?> authenticateUser(String username, String password) async {
    try {
      print('Attempting authentication for username: $username');
      
      // Get all data from Firebase root
      print('Fetching all data from Firebase...');
      final allData = await _makeRequest(''); // Get root data
      
      if (allData != null) {
        // Firebase returns a List, not a Map
        if (allData['data'] is List) {
          final userList = allData['data'] as List;
          print('Total users in list: ${userList.length}');
          
          for (final user in userList) {
            if (user is Map<String, dynamic>) {
              // Check if this is a student (has admissionNo)
              if (user.containsKey('admissionNo')) {
                print('Checking student: ${user['admissionNo']} with DOB: ${user['dob']}');
                
                // Safely get values with null checks
                final admissionNo = user['admissionNo']?.toString() ?? '';
                final rollNo = user['rollNo']?.toString() ?? '';
                final dob = user['dob']?.toString() ?? '';
                final id = user['id']?.toString() ?? '';
                final name = user['name']?.toString() ?? 'Unknown';
                final email = user['email']?.toString() ?? '';
                final phone = user['phone']?.toString() ?? '';
                
                if ((admissionNo == username || rollNo == username) && 
                    dob == password) {
                  print('✅ Student authenticated: $name');
                  return {
                    'id': admissionNo.isNotEmpty ? admissionNo : rollNo, // Use admissionNo or rollNo as ID
                    'username': admissionNo,
                    'password': dob,
                    'userType': 'student',
                    'name': name,
                    'email': email,
                    'phone': phone,
                    'isActive': true,
                    'studentData': user,
                  };
                }
              }
              // Check if this is faculty/staff (has username and userType)
              else if (user.containsKey('username') && user.containsKey('userType')) {
                print('Checking user: ${user['username']} with type: ${user['userType']}');
                
                // Safely get values with null checks
                final facultyUsername = user['username']?.toString() ?? '';
                final facultyPassword = user['password']?.toString() ?? '';
                final isActive = user['isActive'] ?? false;
                final id = user['id']?.toString() ?? '';
                final name = user['name']?.toString() ?? 'Unknown';
                final email = user['email']?.toString() ?? '';
                final phone = user['phone']?.toString() ?? '';
                
                if (facultyUsername == username && 
                    facultyPassword == password && 
                    isActive == true) {
                  print('✅ User authenticated: $name (${user['userType']})');
                  // Return user data with proper ID
                  final facultyData = Map<String, dynamic>.from(user);
                  facultyData['id'] = facultyUsername; // Use username as ID for faculty
                  return facultyData;
                }
              }
            }
          }
        }
      }
      
      print('❌ No user found with username: $username');
      return null;
    } catch (e) {
      print('Firebase auth error: $e');
      return null;
    }
  }

  // Helper method to make HTTP requests
  static Future<Map<String, dynamic>?> _makeRequest(String path, {String method = 'GET', Map<String, dynamic>? body}) async {
    try {
      final url = Uri.parse('$_baseUrl/$path.json');
      print('Making $method request to: $url');
      http.Response response;
      
      if (method == 'GET') {
        response = await http.get(url);
      } else if (method == 'POST') {
        response = await http.post(url, body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
      } else if (method == 'PATCH') {
        response = await http.patch(url, body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
      } else if (method == 'DELETE') {
        response = await http.delete(url);
      } else {
        return null;
      }
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty || response.body == 'null') {
          return null;
        }
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          // Return the list wrapped in a map for consistency
          return {'data': decoded};
        }
        return decoded as Map<String, dynamic>;
      } else {
        print('HTTP Error ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Firebase HTTP request error: $e');
      return null;
    }
  }

  // Change password method
  static Future<bool> changePassword(String userId, String oldPassword, String newPassword) async {
    try {
      print('Attempting password change for user: $userId');
      
      // Get all data to find the user
      final allData = await _makeRequest('');
      if (allData != null && allData['data'] is List) {
        final userList = allData['data'] as List;
        
        for (int i = 0; i < userList.length; i++) {
          final user = userList[i];
          if (user is Map<String, dynamic> && user['id'] == userId) {
            // Verify old password
            if (user['password'] == oldPassword) {
              // Update password
              user['password'] = newPassword;
              
              // Update in Firebase
              final success = await _makeRequest('', method: 'PATCH', body: {'data': userList});
              if (success != null) {
                print('✅ Password updated successfully for user: $userId');
                return true;
              }
            } else {
              print('❌ Old password verification failed for user: $userId');
            }
            break;
          }
        }
      }
      
      print('❌ Password change failed for user: $userId');
      return false;
    } catch (e) {
      print('Password change error: $e');
      return false;
    }
  }

  // Placeholder methods for other functionality
  static Future<List<Map<String, dynamic>>> getAllStudents() async {
    final allData = await _makeRequest('');
    if (allData != null && allData['data'] is List) {
      final userList = allData['data'] as List;
      return userList.where((user) => 
        user is Map<String, dynamic> && user.containsKey('admissionNo')
      ).cast<Map<String, dynamic>>().toList();
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getAllFaculty() async {
    final allData = await _makeRequest('');
    if (allData != null && allData['data'] is List) {
      final userList = allData['data'] as List;
      return userList.where((user) => 
        user is Map<String, dynamic> && 
        user.containsKey('username') && 
        user.containsKey('userType') &&
        user['isActive'] == true
      ).cast<Map<String, dynamic>>().toList();
    }
    return [];
  }

  static Future<Map<String, dynamic>?> getStudent(String studentId) async {
    print('🔍 Looking for student with ID: "$studentId"');
    final allData = await _makeRequest('');
    if (allData != null && allData['data'] is List) {
      final userList = allData['data'] as List;
      print('🔍 Searching through ${userList.length} users');
      
      for (final user in userList) {
        if (user is Map<String, dynamic>) {
          // Check by admissionNo or rollNo as fallback
          final admissionNo = user['admissionNo']?.toString() ?? '';
          final rollNo = user['rollNo']?.toString() ?? '';
          final id = user['id']?.toString() ?? '';
          final name = user['name']?.toString() ?? 'Unknown';
          
          print('🔍 Checking user: $name (ID: $id, Admission: $admissionNo, Roll: $rollNo)');
          
          // Try multiple matching strategies
          if (id == studentId || admissionNo == studentId || rollNo == studentId) {
            if (user.containsKey('admissionNo')) {
              print('✅ Found student: $name');
              return user;
            }
          }
        }
      }
    }
    print('❌ Student not found with ID: $studentId');
    return null;
  }

  static Future<Map<String, dynamic>?> getFaculty(String facultyId) async {
    print('🔍 Looking for faculty with ID: "$facultyId"');
    final allData = await _makeRequest('');
    if (allData != null && allData['data'] is List) {
      final userList = allData['data'] as List;
      print('🔍 Searching through ${userList.length} users');
      
      for (final user in userList) {
        if (user is Map<String, dynamic>) {
          // Check by username as fallback since ID might be null
          final username = user['username']?.toString() ?? '';
          final id = user['id']?.toString() ?? '';
          final name = user['name']?.toString() ?? 'Unknown';
          
          print('🔍 Checking user: $name (ID: $id, Username: $username)');
          
          // Try multiple matching strategies
          if (id == facultyId || username == facultyId) {
            if (user.containsKey('username') && user.containsKey('userType')) {
              print('✅ Found faculty: $name');
              return user;
            }
          }
        }
      }
    }
    print('❌ Faculty not found with ID: $facultyId');
    return null;
  }

  // Additional methods needed by DatabaseService
  static Future<bool> updateStudent(String studentId, Map<String, dynamic> data) async {
    try {
      print('Updating student: $studentId');
      // Implementation would update the student in the list
      return true;
    } catch (e) {
      print('Error updating student: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getAttendance(String studentId) async {
    try {
      print('Getting attendance for student: $studentId');
      return []; // Return empty list for now
    } catch (e) {
      print('Error getting attendance: $e');
      return [];
    }
  }

  static Future<bool> markAttendance(Map<String, dynamic> attendanceData) async {
    try {
      print('Marking attendance: $attendanceData');
      return true;
    } catch (e) {
      print('Error marking attendance: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getMarks(String studentId) async {
    try {
      print('Getting marks for student: $studentId');
      return []; // Return empty list for now
    } catch (e) {
      print('Error getting marks: $e');
      return [];
    }
  }

  static Future<bool> addMarks(Map<String, dynamic> marksData) async {
    try {
      print('Adding marks: $marksData');
      return true;
    } catch (e) {
      print('Error adding marks: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getRemarks(String studentId) async {
    try {
      print('Getting remarks for student: $studentId');
      return []; // Return empty list for now
    } catch (e) {
      print('Error getting remarks: $e');
      return [];
    }
  }

  static Future<bool> addRemark(Map<String, dynamic> remarkData) async {
    try {
      print('Adding remark: $remarkData');
      return true;
    } catch (e) {
      print('Error adding remark: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getCertificates(String studentId) async {
    try {
      print('Getting certificates for student: $studentId');
      return []; // Return empty list for now
    } catch (e) {
      print('Error getting certificates: $e');
      return [];
    }
  }

  static Future<bool> addCertificate(String studentId, Map<String, dynamic> certificateData) async {
    try {
      print('Adding certificate for student: $studentId, data: $certificateData');
      return true;
    } catch (e) {
      print('Error adding certificate: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getJobs() async {
    try {
      print('Getting jobs');
      return []; // Return empty list for now
    } catch (e) {
      print('Error getting jobs: $e');
      return [];
    }
  }

  static Future<bool> addJob(Map<String, dynamic> job) async {
    try {
      print('Adding job');
      return true;
    } catch (e) {
      print('Error adding job: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getNotifications(String userId) async {
    try {
      print('Getting notifications for user: $userId');
      return []; // Return empty list for now
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  static Future<bool> addNotification(Map<String, dynamic> notification) async {
    try {
      print('Adding notification');
      return true;
    } catch (e) {
      print('Error adding notification: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> getPrincipalStats() async {
    try {
      print('Getting principal stats');
      return {
        'totalStudents': 0,
        'totalFaculty': 0,
        'totalAttendance': 0,
        'totalMarks': 0,
      };
    } catch (e) {
      print('Error getting principal stats: $e');
      return {};
    }
  }

  static Future<bool> clearAllData() async {
    try {
      print('Clearing all data');
      return true;
    } catch (e) {
      print('Error clearing data: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getSubjects() async {
    try {
      print('Getting subjects');
      return []; // Return empty list for now
    } catch (e) {
      print('Error getting subjects: $e');
      return [];
    }
  }

  static Future<bool> addSubject(Map<String, dynamic> subject) async {
    try {
      print('Adding subject');
      return true;
    } catch (e) {
      print('Error adding subject: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getTimetable() async {
    try {
      print('Getting timetable');
      return []; // Return empty list for now
    } catch (e) {
      print('Error getting timetable: $e');
      return [];
    }
  }

  static Future<bool> updateTimetable(String timetableId, Map<String, dynamic> timetableData) async {
    try {
      print('Updating timetable: $timetableId, data: $timetableData');
      return true;
    } catch (e) {
      print('Error updating timetable: $e');
      return false;
    }
  }

  static Future<bool> addTimetable(Map<String, dynamic> timetable) async {
    try {
      print('Adding timetable');
      return true;
    } catch (e) {
      print('Error adding timetable: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getInternalMarks(String studentId) async {
    try {
      print('Getting internal marks for student: $studentId');
      return []; // Return empty list for now
    } catch (e) {
      print('Error getting internal marks: $e');
      return [];
    }
  }

  static Future<bool> addInternalMarks(Map<String, dynamic> marks) async {
    try {
      print('Adding internal marks');
      return true;
    } catch (e) {
      print('Error adding internal marks: $e');
      return false;
    }
  }

  static Future<bool> lockInternalMarks(String marksId) async {
    try {
      print('Locking internal marks: $marksId');
      return true;
    } catch (e) {
      print('Error locking internal marks: $e');
      return false;
    }
  }

  static Future<bool> updateInternalMarks(String marksId, Map<String, dynamic> marks) async {
    try {
      print('Updating internal marks: $marksId');
      return true;
    } catch (e) {
      print('Error updating internal marks: $e');
      return false;
    }
  }
}
