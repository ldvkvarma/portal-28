import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class FirebaseDataImporter {
  static const String _baseUrl = 'https://college-portal-c15ac-default-rtdb.asia-southeast1.firebasedatabase.app';
  
  static Future<void> importStudentData() async {
    print('=== IMPORTING STUDENT DATA TO FIREBASE ===');
    
    try {
      // Read the student data JSON file
      final file = File('c:\\Users\\MANNU\\Desktop\\portal-28 old\\student_faculty_data.json');
      if (!await file.exists()) {
        print('Error: student_faculty_data.json file not found');
        return;
      }
      
      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString);
      
      // Import students
      if (jsonData['students'] != null) {
        print('Importing ${jsonData['students'].length} students...');
        
        for (final student in jsonData['students']) {
          final studentId = student['id'];
          final url = Uri.parse('$_baseUrl/students/$studentId.json');
          
          final response = await http.put(
            url,
            body: jsonEncode(student),
            headers: {'Content-Type': 'application/json'},
          );
          
          if (response.statusCode >= 200 && response.statusCode < 300) {
            print('✅ Imported student: ${student['name']} (${student['admissionNo']})');
          } else {
            print('❌ Failed to import student ${student['name']}: ${response.statusCode}');
          }
        }
      }
      
      // Import faculty/users
      if (jsonData['faculty'] != null) {
        print('Importing ${jsonData['faculty'].length} faculty...');
        
        for (final faculty in jsonData['faculty']) {
          final facultyId = faculty['id'];
          final url = Uri.parse('$_baseUrl/users/$facultyId.json');
          
          final response = await http.put(
            url,
            body: jsonEncode(faculty),
            headers: {'Content-Type': 'application/json'},
          );
          
          if (response.statusCode >= 200 && response.statusCode < 300) {
            print('✅ Imported faculty: ${faculty['name']} (${faculty['username']})');
          } else {
            print('❌ Failed to import faculty ${faculty['name']}: ${response.statusCode}');
          }
        }
      }
      
      print('=== IMPORT COMPLETE ===');
      
    } catch (e) {
      print('Error importing data: $e');
    }
  }
  
  static Future<void> verifyImport() async {
    print('\n=== VERIFYING IMPORT ===');
    
    // Check students
    final studentsUrl = Uri.parse('$_baseUrl/students.json');
    final studentsResponse = await http.get(studentsUrl);
    
    if (studentsResponse.statusCode >= 200 && studentsResponse.statusCode < 300) {
      if (studentsResponse.body != 'null') {
        final studentsData = jsonDecode(studentsResponse.body);
        print('✅ Students in Firebase: ${studentsData.length}');
      } else {
        print('❌ No students found in Firebase');
      }
    } else {
      print('❌ Error checking students: ${studentsResponse.statusCode}');
    }
    
    // Check users
    final usersUrl = Uri.parse('$_baseUrl/users.json');
    final usersResponse = await http.get(usersUrl);
    
    if (usersResponse.statusCode >= 200 && usersResponse.statusCode < 300) {
      if (usersResponse.body != 'null') {
        final usersData = jsonDecode(usersResponse.body);
        print('✅ Users in Firebase: ${usersData.length}');
      } else {
        print('❌ No users found in Firebase');
      }
    } else {
      print('❌ Error checking users: ${usersResponse.statusCode}');
    }
    
    print('=== VERIFICATION COMPLETE ===\n');
  }
}

void main() async {
  await FirebaseDataImporter.importStudentData();
  await FirebaseDataImporter.verifyImport();
}
