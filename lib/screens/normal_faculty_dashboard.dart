import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'faculty_attendance_screen.dart';
import 'faculty_marks_screen.dart';

class NormalFacultyDashboard extends StatefulWidget {
  const NormalFacultyDashboard({super.key});

  @override
  State<NormalFacultyDashboard> createState() => _NormalFacultyDashboardState();
}

class _NormalFacultyDashboardState extends State<NormalFacultyDashboard> {
  Map<String, dynamic>? _facultyData;
  List<Map<String, dynamic>> _timetable = [];
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _mySubjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final timetable = await DatabaseService.getTimetable();
      final facultyData = AuthService().currentUserData;
      final subjects = await DatabaseService.getSubjects();
      final students = await DatabaseService.getAllStudents();
      
      // Filter my subjects and today's classes
      final mySubjects = subjects.where((subject) =>
          facultyData?['subjects']?.contains(subject['code']) == true
      ).toList();
      
      final today = DateTime.now().weekday;
      final todayName = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'][today - 1];
      final todayClasses = timetable.where((tt) => tt['day'] == todayName).toList();
      
      setState(() {
        _facultyData = facultyData;
        _timetable = todayClasses;
        _students = students;
        _mySubjects = mySubjects;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
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
        title: Text('Faculty Dashboard', style: GoogleFonts.inter()),
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
                            'Welcome, ${_facultyData?['name'] ?? 'Faculty'}',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF667eea),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Department: ${_facultyData?['department'] ?? 'CSE'}',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'Designation: ${_facultyData?['designation'] ?? 'Faculty'}',
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
                            'My Subjects',
                            _mySubjects.length.toString(),
                            Icons.book,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Today Classes',
                            _getTodayClassesCount().toString(),
                            Icons.today,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Students',
                            _students.length.toString(),
                            Icons.people,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Today's Schedule
                    Text(
                      'Today\'s Schedule',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    if (_timetable.isEmpty)
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
                        child: Center(
                          child: Text(
                            'No classes scheduled for today',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      )
                    else
                      ..._timetable.map((day) => _buildDaySchedule(day)).toList(),
                    
                    const SizedBox(height: 24),
                    
                    // Action Cards
                    Text(
                      'Actions',
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
                            'Mark Attendance',
                            'Take daily attendance',
                            Icons.how_to_reg,
                            Colors.blue,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FacultyAttendanceScreen(),
                              ),
                            ).then((_) => _loadData()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionCard(
                            'Manage Marks',
                            'Add internal marks',
                            Icons.grade,
                            Colors.green,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FacultyMarksScreen(),
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
                            'View Timetable',
                            'Weekly schedule',
                            Icons.calendar_month,
                            Colors.purple,
                            () => _showFullTimetable(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionCard(
                            'My Subjects',
                            'View assigned subjects',
                            Icons.menu_book,
                            Colors.orange,
                            () => _showMySubjects(),
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

  int _getTodayClassesCount() {
    if (_timetable.isEmpty) return 0;
    
    int count = 0;
    for (var day in _timetable) {
      for (int i = 1; i <= 6; i++) {
        final period = day['period$i'];
        if (period != null && period['faculty'] == _facultyData?['id']) {
          count++;
        }
      }
    }
    return count;
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

  Widget _buildDaySchedule(Map<String, dynamic> day) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: const Color(0xFF667eea)),
                const SizedBox(width: 12),
                Text(
                  day['day'],
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF667eea),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (day['period1'] != null) _buildSchedulePeriod('Period 1', day['period1']),
                if (day['period2'] != null) _buildSchedulePeriod('Period 2', day['period2']),
                if (day['break1'] != null) _buildScheduleBreak('Break', day['break1']),
                if (day['period3'] != null) _buildSchedulePeriod('Period 3', day['period3']),
                if (day['period4'] != null) _buildSchedulePeriod('Period 4', day['period4']),
                if (day['lunch'] != null) _buildScheduleBreak('Lunch', day['lunch']),
                if (day['period5'] != null) _buildSchedulePeriod('Period 5', day['period5']),
                if (day['period6'] != null) _buildSchedulePeriod('Period 6', day['period6']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchedulePeriod(String period, Map<String, dynamic> periodData) {
    final isMyClass = periodData['faculty'] == _facultyData?['id'];
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMyClass ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: isMyClass ? Border.all(color: Colors.green.withValues(alpha: 0.3)) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              period,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                color: isMyClass ? Colors.green : Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  periodData['subject'] ?? '',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: isMyClass ? Colors.green : Colors.black87,
                  ),
                ),
                Text(
                  '${periodData['time']} • Room ${periodData['room'] ?? ''}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (isMyClass)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'My Class',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScheduleBreak(String title, Map<String, dynamic> breakData) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            title == 'Break' ? Icons.coffee : Icons.restaurant,
            color: Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            '$title • ${breakData['time']}',
            style: GoogleFonts.inter(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showFullTimetable() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Full Timetable', style: GoogleFonts.inter()),
        content: const SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Center(
            child: Text('Full timetable view would be displayed here'),
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

  void _showMySubjects() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('My Subjects', style: GoogleFonts.inter()),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: _mySubjects.length,
            itemBuilder: (context, index) {
              final subject = _mySubjects[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withValues(alpha: 0.1),
                  child: Icon(Icons.book, color: Colors.blue),
                ),
                title: Text(subject['name'], style: GoogleFonts.inter()),
                subtitle: Text(
                  '${subject['code']} • ${subject['semester']} Semester • ${subject['credits']} Credits',
                  style: GoogleFonts.inter(),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: subject['type'] == 'lab'
                        ? Colors.orange.withValues(alpha: 0.1)
                        : Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    subject['type'],
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: subject['type'] == 'lab' ? Colors.orange : Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
}
