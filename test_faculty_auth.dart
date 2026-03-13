import 'dart:convert';
import 'package:http/http.dart' as http;

class FacultyAuthTester {
  static const String _baseUrl = 'https://college-portal-c15ac-default-rtdb.asia-southeast1.firebasedatabase.app';
  
  static Future<void> testFacultyAuth() async {
    print('=== TESTING FACULTY AUTHENTICATION ===');
    
    try {
      // Get all data from Firebase
      final url = Uri.parse('$_baseUrl/.json');
      final response = await http.get(url);
      
      if (response.statusCode == 200 && response.body != 'null') {
        final data = jsonDecode(response.body);
        
        if (data is List) {
          print('\n👨‍🏫 FACULTY/STAFF CREDENTIALS:');
          print('─' * 50);
          
          int facultyCount = 0;
          for (final user in data) {
            if (user is Map<String, dynamic> && 
                user.containsKey('username') && 
                user.containsKey('userType')) {
              facultyCount++;
              print('\n👨‍🏫 FACULTY/STAFF $facultyCount:');
              print('  Username: ${user['username']}');
              print('  Password: ${user['password']}');
              print('  Name: ${user['name']}');
              print('  Type: ${user['userType']}');
              print('  Email: ${user['email']}');
              print('  Phone: ${user['phone']}');
              print('  Department: ${user['department']}');
              print('  Designation: ${user['designation']}');
              print('  Role: ${user['role']}');
              print('  Active: ${user['isActive']}');
              print('  └─ Try login with: ${user['username']} / ${user['password']}');
            }
          }
          
          print('\n' + '─' * 50);
          print('📊 Total Faculty/Staff: $facultyCount');
          
          // Test authentication for each faculty
          print('\n🧪 TESTING FACULTY LOGIN:');
          print('─' * 50);
          
          for (final user in data) {
            if (user is Map<String, dynamic> && 
                user.containsKey('username') && 
                user.containsKey('userType')) {
              final username = user['username']?.toString() ?? '';
              final password = user['password']?.toString() ?? '';
              final name = user['name']?.toString() ?? 'Unknown';
              
              print('\n🔐 Testing: $username / $password');
              
              // Simulate authentication logic
              if (user['isActive'] == true) {
                print('✅ Should authenticate: $name (${user['userType']})');
              } else {
                print('❌ Not active: $name');
              }
            }
          }
          
        } else {
          print('❌ Data is not in expected format');
        }
      } else {
        print('❌ Failed to fetch data: ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ Error: $e');
    }
    
    print('\n=== FACULTY AUTH TEST COMPLETE ===\n');
  }
}

void main() async {
  await FacultyAuthTester.testFacultyAuth();
}
