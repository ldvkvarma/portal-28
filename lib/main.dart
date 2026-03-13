import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/login_test_screen.dart';
import 'screens/student_dashboard.dart';
import 'screens/faculty_dashboard.dart';
import 'screens/principal_dashboard.dart';
import 'screens/placement_dashboard.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await DatabaseService.initialize();
  await NotificationService().initialize();
  await AuthService().initialize();
  
  runApp(const CollegePortalApp());
}

class CollegePortalApp extends StatelessWidget {
  const CollegePortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'College Portal - Complete Management System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        primaryColor: const Color(0xFF667eea),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667eea),
          primary: const Color(0xFF667eea),
          secondary: const Color(0xFF764ba2),
        ),
        textTheme: GoogleFonts.interTextTheme(),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Wait for AuthService to initialize
    await Future.delayed(const Duration(milliseconds: 100));
    
    final authService = AuthService();
    
    setState(() {
      _isLoading = false;
    });
    
    if (authService.isLoggedIn && authService.currentUserType != null) {
      if (mounted) {
        Widget dashboard;
        switch (authService.currentUserType) {
          case 'student':
            dashboard = const StudentDashboard();
            break;
          case 'faculty':
            dashboard = const FacultyDashboard();
            break;
          case 'principal':
            dashboard = const PrincipalDashboard();
            break;
          case 'placement':
            dashboard = const PlacementDashboard();
            break;
          default:
            dashboard = const LoginScreen();
        }
        
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => dashboard),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen();
    }
    return const LoginScreen(); // Back to normal login screen
  }
}
