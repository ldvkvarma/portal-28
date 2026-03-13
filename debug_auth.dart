import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthDebugger {
  static const String _baseUrl = 'https://college-portal-c15ac-default-rtdb.asia-southeast1.firebasedatabase.app';
  
  static Future<void> debugAuthentication() async {
    print('=== DEBUGGING AUTHENTICATION ===');
    
    try {
      // Get all data from Firebase
      final url = Uri.parse('$_baseUrl/.json');
      final response = await http.get(url);
      
      if (response.statusCode == 200 && response.body != 'null') {
        final data = jsonDecode(response.body);
        
        print('\n📋 AVAILABLE USERS FOR LOGIN:');
        print('─' * 50);
        
        int studentCount = 0;
        int facultyCount = 0;
        
        // Check if data is a List (which it is based on Firebase response)
        if (data is List) {
          for (final user in data) {
            if (user is Map<String, dynamic>) {
              // Check if this is a student
              if (user.containsKey('admissionNo')) {
                studentCount++;
                print('\n🎓 STUDENT $studentCount:');
                print('  Username (Admission No): ${user['admissionNo']}');
                print('  Password (DOB): ${user['dob']}');
                print('  Name: ${user['name']}');
                print('  Roll No: ${user['rollNo']}');
                print('  └─ Try login with: ${user['admissionNo']} / ${user['dob']}');
              }
              // Check if this is faculty/staff
              else if (user.containsKey('username') && user.containsKey('userType')) {
                facultyCount++;
                print('\n👨‍🏫 FACULTY/STAFF $facultyCount:');
                print('  Username: ${user['username']}');
                print('  Password: ${user['password']}');
                print('  Name: ${user['name']}');
                print('  Type: ${user['userType']}');
                print('  └─ Try login with: ${user['username']} / ${user['password']}');
              }
            }
          }
        } else if (data is Map) {
          // Handle Map case if needed
          for (final entry in data.entries) {
            final user = entry.value as Map<dynamic, dynamic>;
            // ... same logic as above
          }
        }
        
        print('\n' + '─' * 50);
        print('📊 SUMMARY: $studentCount students, $facultyCount faculty/staff');
        print('\n💡 LOGIN TIPS:');
        print('  • For students: Use Admission Number and Date of Birth');
        print('  • For faculty: Use Username and Password');
        print('  • Make sure DOB format matches exactly (MM/DD/YYYY)');
        
      } else {
        print('❌ Failed to fetch data: ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ Error: $e');
    }
    
    print('\n=== DEBUG COMPLETE ===\n');
  }
}

void main() async {
  await AuthDebugger.debugAuthentication();
}
