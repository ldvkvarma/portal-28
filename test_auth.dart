import 'dart:convert';
import 'package:http/http.dart' as http;

class SimpleAuthService {
  static const String _baseUrl = 'https://college-portal-c15ac-default-rtdb.asia-southeast1.firebasedatabase.app';
  
  static Future<Map<String, dynamic>?> authenticateUser(String username, String password) async {
    try {
      print('Attempting authentication for username: $username');
      
      // Get all data from Firebase
      final url = Uri.parse('$_baseUrl/.json');
      final response = await http.get(url);
      
      if (response.statusCode == 200 && response.body != 'null') {
        final data = jsonDecode(response.body);
        
        if (data is List) {
          print('Found ${data.length} users in Firebase');
          
          for (final user in data) {
            if (user is Map<String, dynamic>) {
              // Check if this is a student
              if (user.containsKey('admissionNo')) {
                print('Checking student: ${user['admissionNo']} with DOB: ${user['dob']}');
                if ((user['admissionNo'] == username || user['rollNo'] == username) && 
                    user['dob'] == password) {
                  print('✅ Student authenticated: ${user['name']}');
                  return {
                    'id': user['id'],
                    'username': user['admissionNo'],
                    'password': user['dob'],
                    'userType': 'student',
                    'name': user['name'],
                    'email': user['email'],
                    'phone': user['phone'],
                    'isActive': true,
                    'studentData': user,
                  };
                }
              }
              // Check if this is faculty/staff
              else if (user.containsKey('username') && user.containsKey('userType')) {
                print('Checking user: ${user['username']} with type: ${user['userType']}');
                if (user['username'] == username && 
                    user['password'] == password && 
                    user['isActive'] == true) {
                  print('✅ User authenticated: ${user['name']} (${user['userType']})');
                  return Map<String, dynamic>.from(user);
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
}

void main() async {
  print('=== TESTING AUTHENTICATION ===');
  
  // Test with student credentials
  print('\n🧪 Testing student login:');
  final studentResult = await SimpleAuthService.authenticateUser('23KT1A0567', '12/25/2004');
  if (studentResult != null) {
    print('✅ Student login successful!');
    print('Name: ${studentResult['name']}');
    print('Type: ${studentResult['userType']}');
  } else {
    print('❌ Student login failed');
  }
  
  // Test with faculty credentials
  print('\n🧪 Testing faculty login:');
  final facultyResult = await SimpleAuthService.authenticateUser('principal', 'admin123');
  if (facultyResult != null) {
    print('✅ Faculty login successful!');
    print('Name: ${facultyResult['name']}');
    print('Type: ${facultyResult['userType']}');
  } else {
    print('❌ Faculty login failed');
  }
  
  print('\n=== TEST COMPLETE ===');
}
