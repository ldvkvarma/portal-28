import 'dart:convert';
import 'package:http/http.dart' as http;

class StudentDetailsViewer {
  static const String _baseUrl = 'https://college-portal-c15ac-default-rtdb.asia-southeast1.firebasedatabase.app';
  
  static Future<void> showAllStudentDetails() async {
    print('=== ALL STUDENT DETAILS ===');
    
    try {
      // Get all data from Firebase
      final url = Uri.parse('$_baseUrl/.json');
      final response = await http.get(url);
      
      if (response.statusCode == 200 && response.body != 'null') {
        final data = jsonDecode(response.body);
        
        if (data is List) {
          print('\n📊 TOTAL STUDENTS FOUND: ${data.length}\n');
          
          int studentCount = 0;
          for (final user in data) {
            if (user is Map<String, dynamic> && user.containsKey('admissionNo')) {
              studentCount++;
              print('─' * 80);
              print('🎓 STUDENT #$studentCount: ${user['name']}');
              print('📋 ADMISSION NO: ${user['admissionNo']}');
              print('📋 ROLL NO: ${user['rollNo']}');
              print('📋 ID: ${user['id']}');
              print('📧 EMAIL: ${user['email']}');
              print('📱 PHONE: ${user['phone']}');
              print('🎂 DOB: ${user['dob']}');
              print('📚 COURSE: ${user['course']} - ${user['branch']}');
              print('📖 SEMESTER: ${user['semester']} - SECTION: ${user['section']}');
              print('🎯 CGPA: ${user['cgpa']}');
              print('📊 BACKLOGS: ${user['backlogs']}');
              print('🩸 BLOOD GROUP: ${user['bloodGroup']}');
              print('👨‍👩‍👧‍👦 FATHER: ${user['fatherName']} (${user['fatherOccupation']})');
              print('👩‍👧‍👦‍👨 MOTHER: ${user['motherName']} (${user['motherOccupation']})');
              print('🏠 ADDRESS: ${user['address']}');
              print('📞 EMERGENCY: ${user['emergencyContact']}');
              print('🆔 AADHAR: ${user['aadhar']}');
              print('🌍 RELIGION: ${user['religion']}');
              print('🇮🇳 NATIONALITY: ${user['nationality']}');
              print('📅 BATCH: ${user['batch']}');
              print('📝 CATEGORY: ${user['category']}');
              print('');
            }
          }
          
          print('─' * 80);
          print('📊 SUMMARY: Found $studentCount students out of ${data.length} total records');
          
        } else {
          print('❌ Data is not in expected format');
        }
      } else {
        print('❌ Failed to fetch data: ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ Error: $e');
    }
    
    print('\n=== STUDENT DETAILS COMPLETE ===\n');
  }
}

void main() async {
  await StudentDetailsViewer.showAllStudentDetails();
}
