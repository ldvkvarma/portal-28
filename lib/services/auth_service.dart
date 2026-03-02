import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? _currentUser;
  String? _currentUserType;
  Map<String, dynamic>? _currentUserData;

  // Initialize auth service
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    
    if (isLoggedIn) {
      _currentUser = prefs.getString('userId');
      _currentUserType = prefs.getString('userType');
      
      // Load user data
      if (_currentUserType == 'student') {
        _currentUserData = await DatabaseService.getStudent(_currentUser!);
      } else if (_currentUserType == 'faculty') {
        _currentUserData = await DatabaseService.getFaculty(_currentUser!);
      }
    }
  }

  // Login method
  Future<Map<String, dynamic>?> login(String username, String password) async {
    final user = await DatabaseService.authenticateUser(username, password);
    
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userId', user['id']);
      await prefs.setString('userType', user['userType']);
      
      _currentUser = user['id'];
      _currentUserType = user['userType'];
      _currentUserData = user;
      
      return user;
    }
    
    return null;
  }

  // Logout method
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userId');
    await prefs.remove('userType');
    
    _currentUser = null;
    _currentUserType = null;
    _currentUserData = null;
  }

  // Check if user is logged in
  bool get isLoggedIn => _currentUser != null;

  // Get current user ID
  String? get currentUserId => _currentUser;

  // Get current user type
  String? get currentUserType => _currentUserType;

  // Get current user data
  Map<String, dynamic>? get currentUserData => _currentUserData;

  // Check if user has specific role
  bool hasRole(String role) => _currentUserType == role;

  // Check if user is student
  bool get isStudent => _currentUserType == 'student';

  // Check if user is faculty
  bool get isFaculty => _currentUserType == 'faculty';

  // Check if user is principal
  bool get isPrincipal => _currentUserType == 'principal';

  // Check if user is placement officer
  bool get isPlacement => _currentUserType == 'placement';

  // Update current user data
  Future<void> updateCurrentUser() async {
    if (_currentUser != null && _currentUserType != null) {
      if (_currentUserType == 'student') {
        _currentUserData = await DatabaseService.getStudent(_currentUser!);
      } else if (_currentUserType == 'faculty') {
        _currentUserData = await DatabaseService.getFaculty(_currentUser!);
      }
    }
  }

  // Change password
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    if (_currentUser != null) {
      return await DatabaseService.changePassword(_currentUser!, oldPassword, newPassword);
    }
    return false;
  }

  // Get user permissions based on role
  Map<String, bool> getPermissions() {
    switch (_currentUserType) {
      case 'student':
        return {
          'view_profile': true,
          'view_attendance': true,
          'view_marks': true,
          'view_remarks': true,
          'add_certificates': true,
          'view_jobs': true,
          'edit_profile': true,
          'change_password': true,
          'edit_attendance': false,
          'edit_marks': false,
          'edit_remarks': false,
          'monitor_faculty': false,
          'post_jobs': false,
        };
      case 'faculty':
        return {
          'view_profile': true,
          'view_attendance': true,
          'view_marks': true,
          'view_remarks': true,
          'add_certificates': false,
          'view_jobs': false,
          'edit_profile': true,
          'change_password': true,
          'edit_attendance': true,
          'edit_marks': true,
          'edit_remarks': true,
          'monitor_faculty': false,
          'post_jobs': false,
        };
      case 'principal':
        return {
          'view_profile': true,
          'view_attendance': true,
          'view_marks': true,
          'view_remarks': true,
          'add_certificates': false,
          'view_jobs': true,
          'edit_profile': true,
          'change_password': true,
          'edit_attendance': true,
          'edit_marks': true,
          'edit_remarks': true,
          'monitor_faculty': true,
          'post_jobs': false,
        };
      case 'placement':
        return {
          'view_profile': true,
          'view_attendance': false,
          'view_marks': false,
          'view_remarks': false,
          'add_certificates': false,
          'view_jobs': true,
          'edit_profile': true,
          'change_password': true,
          'edit_attendance': false,
          'edit_marks': false,
          'edit_remarks': false,
          'monitor_faculty': false,
          'post_jobs': true,
        };
      default:
        return {};
    }
  }

  // Check specific permission
  bool hasPermission(String permission) {
    final permissions = getPermissions();
    return permissions[permission] ?? false;
  }
}
