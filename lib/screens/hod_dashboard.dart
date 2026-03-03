import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'faculty_timetable_screen.dart';
import 'faculty_subjects_screen.dart';

class HoDDashboard extends StatefulWidget {
  const HoDDashboard({super.key});

  @override
  State<HoDDashboard> createState() => _HoDDashboardState();
}

class _HoDDashboardState extends State<HoDDashboard> {
  Map<String, dynamic>? _hodData;
  List<Map<String, dynamic>> _subjects = [];
  List<Map<String, dynamic>> _timetable = [];
  List<Map<String, dynamic>> _faculty = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final subjects = await DatabaseService.getSubjects();
      final timetable = await DatabaseService.getTimetable();
      final faculty = await DatabaseService.getAllFaculty();
      
      setState(() {
        _subjects = subjects;
        _timetable = timetable;
        _faculty = faculty;
        _hodData = AuthService().currentUserData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _showBackConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exit Dashboard?', style: GoogleFonts.inter()),
        content: Text(
          'Do you want to logout from the dashboard?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Logout', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'HoD Dashboard',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Remove back arrow
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${_hodData?['name'] ?? 'HoD'}',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF667eea),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Department: ${_hodData?['department'] ?? 'CSE'}',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'Designation: ${_hodData?['designation'] ?? 'Head of Department'}',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Stats Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Subjects',
                            _subjects.length.toString(),
                            Icons.book,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Faculty',
                            _faculty.length.toString(),
                            Icons.people,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Classes',
                            _timetable.length.toString(),
                            Icons.calendar_today,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Action Cards
                    Text(
                      'Management',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionCard(
                            'Manage Subjects',
                            'Add and manage semester subjects',
                            Icons.book,
                            Colors.blue,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FacultySubjectsScreen(),
                              ),
                            ).then((_) => _loadData()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionCard(
                            'Manage Timetable',
                            'Create and update class schedules',
                            Icons.schedule,
                            Colors.green,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FacultyTimetableScreen(),
                              ),
                            ).then((_) => _loadData()),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionCard(
                            'View Faculty',
                            'Manage department faculty',
                            Icons.people,
                            Colors.purple,
                            () => _showFacultyList(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionCard(
                            'View Timetable',
                            'Current week schedule',
                            Icons.calendar_month,
                            Colors.orange,
                            () => _showTimetable(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFacultyList() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Department Faculty', style: GoogleFonts.inter()),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: _faculty.length,
            itemBuilder: (context, index) {
              final faculty = _faculty[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: faculty['role'] == 'hod' 
                      ? Colors.red.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                  child: Icon(
                    faculty['role'] == 'hod' ? Icons.admin_panel_settings : Icons.person,
                    color: faculty['role'] == 'hod' ? Colors.red : Colors.blue,
                  ),
                ),
                title: Text(faculty['name'], style: GoogleFonts.inter()),
                subtitle: Text(
                  '${faculty['designation']} • ${faculty['role'] == 'hod' ? 'Head of Department' : 'Faculty'}',
                  style: GoogleFonts.inter(),
                ),
                trailing: Text(
                  faculty['subjects']?.join(', ') ?? '',
                  style: GoogleFonts.inter(fontSize: 12),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTimetable() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Weekly Timetable', style: GoogleFonts.inter()),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: _timetable.length,
            itemBuilder: (context, index) {
              final day = _timetable[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ExpansionTile(
                  title: Text(day['day'], style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (day['period1'] != null)
                            _buildPeriodTile('Period 1', day['period1']),
                          if (day['period2'] != null)
                            _buildPeriodTile('Period 2', day['period2']),
                          if (day['break1'] != null)
                            _buildBreakTile('Break', day['break1']),
                          if (day['period3'] != null)
                            _buildPeriodTile('Period 3', day['period3']),
                          if (day['period4'] != null)
                            _buildPeriodTile('Period 4', day['period4']),
                          if (day['lunch'] != null)
                            _buildBreakTile('Lunch', day['lunch']),
                          if (day['period5'] != null)
                            _buildPeriodTile('Period 5', day['period5']),
                          if (day['period6'] != null)
                            _buildPeriodTile('Period 6', day['period6']),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodTile(String period, Map<String, dynamic> periodData) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              period,
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${periodData['subject']} • ${periodData['time']} • ${periodData['room']}',
                style: GoogleFonts.inter(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakTile(String title, Map<String, dynamic> breakData) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              title,
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                breakData['time'],
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ),
        ],
      ),
    ); // PopScope closing
  }
}
