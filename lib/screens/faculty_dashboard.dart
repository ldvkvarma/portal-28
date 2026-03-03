import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'hod_dashboard.dart';
import 'normal_faculty_dashboard.dart';

class FacultyDashboard extends StatefulWidget {
  const FacultyDashboard({super.key});

  @override
  State<FacultyDashboard> createState() => _FacultyDashboardState();
}

class _FacultyDashboardState extends State<FacultyDashboard> {
  @override
  void initState() {
    super.initState();
    _navigateToCorrectDashboard();
  }

  void _navigateToCorrectDashboard() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = AuthService();
      
      if (authService.isHod) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HoDDashboard()),
        );
      } else if (authService.isNormalFaculty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NormalFacultyDashboard()),
        );
      } else {
        // Fallback to old dashboard or show error
        _showErrorScreen();
      }
    });
  }

  void _showErrorScreen() {
    setState(() {
      // Show error state
    });
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF667eea).withValues(alpha: 0.1),
              const Color(0xFF764ba2).withValues(alpha: 0.1),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.school,
                size: 100,
                color: const Color(0xFF667eea),
              ),
              const SizedBox(height: 20),
              Text(
                'Loading Dashboard...',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF667eea),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Redirecting to your dashboard',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 30),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  'Logout',
                  style: GoogleFonts.inter(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
