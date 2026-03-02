import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class PlacementDashboard extends StatelessWidget {
  const PlacementDashboard({super.key});

  Future<void> _logout() async {
    await AuthService().logout();
    // Navigate back to login
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
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Icon(
                Icons.business_center,
                size: 100,
                color: const Color(0xFF667eea),
              ),
              const SizedBox(height: 20),
              Text(
                'Placement Officer Dashboard',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF667eea),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Job posting features coming soon!',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
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
      ),
    );
  }
}
