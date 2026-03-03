import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class FacultyAttendanceScreen extends StatefulWidget {
  const FacultyAttendanceScreen({super.key});

  @override
  State<FacultyAttendanceScreen> createState() => _FacultyAttendanceScreenState();
}

class _FacultyAttendanceScreenState extends State<FacultyAttendanceScreen> {
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _subjects = [];
  List<Map<String, dynamic>> _timetable = [];
  Map<String, dynamic>? _facultyData;
  bool _isLoading = true;
  String? _selectedSubject;
  String? _selectedDate;
  Map<String, bool> _attendanceStatus = {};

  @override
  void initState() {
    super.initState();
    _loadData();
    _selectedDate = DateTime.now().toString().split(' ')[0];
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final facultyData = AuthService().currentUserData;
      final subjects = await DatabaseService.getSubjects();
      final timetable = await DatabaseService.getTimetable();
      final students = await DatabaseService.getAllStudents();
      
      // Filter my subjects
      final mySubjects = subjects.where((subject) =>
          facultyData?['subjects']?.contains(subject['code']) == true
      ).toList();
      
      setState(() {
        _facultyData = facultyData;
        _subjects = mySubjects;
        _students = students;
        _timetable = timetable;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _markAttendance() {
    if (_selectedSubject == null || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select subject and date')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mark Attendance', style: GoogleFonts.inter()),
        content: StatefulBuilder(
          builder: (context, setDialogState) => SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                // Subject and Date Selection
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedSubject,
                        decoration: const InputDecoration(
                          labelText: 'Subject',
                          border: OutlineInputBorder(),
                        ),
                        items: _subjects.map<DropdownMenuItem<String>>((subject) => DropdownMenuItem<String>(
                          value: subject['code'] as String,
                          child: Text('${subject['code']} - ${subject['name']}'),
                        )).toList(),
                        onChanged: (value) {
                          setState(() => _selectedSubject = value);
                          setDialogState(() => _selectedSubject = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        controller: TextEditingController(text: _selectedDate),
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.parse(_selectedDate!),
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2025),
                          );
                          if (date != null) {
                            setState(() => _selectedDate = date.toString().split(' ')[0]);
                            setDialogState(() => _selectedDate = date.toString().split(' ')[0]);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Attendance Mode Toggle
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Mark Presentees'),
                        value: 'present',
                        groupValue: 'present',
                        onChanged: (value) {},
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Mark Absentees'),
                        value: 'absent',
                        groupValue: 'present',
                        onChanged: (value) {},
                      ),
                    ),
                  ],
                ),
                const Divider(),
                
                // Students List
                Expanded(
                  child: ListView.builder(
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      final rollNo = student['rollNo'] ?? student['admissionNo'];
                      final isPresent = _attendanceStatus[student['id']] ?? true;
                      
                      return CheckboxListTile(
                        value: isPresent,
                        onChanged: (value) {
                          setDialogState(() {
                            _attendanceStatus[student['id']] = value ?? false;
                          });
                        },
                        title: Text(
                          student['name'],
                          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text('Roll No: $rollNo'),
                        secondary: CircleAvatar(
                          backgroundColor: isPresent 
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          child: Icon(
                            isPresent ? Icons.check : Icons.close,
                            color: isPresent ? Colors.green : Colors.red,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _saveAttendance,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save Attendance'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAttendance() async {
    if (_selectedSubject == null || _selectedDate == null) return;

    bool success = true;
    for (final student in _students) {
      final attendanceData = {
        'studentId': student['id'],
        'subject': _selectedSubject,
        'date': _selectedDate,
        'status': _attendanceStatus[student['id']] == true ? 'P' : 'A',
        'facultyId': _facultyData?['id'],
        'period': '1', // Default period
        'isLocked': false,
      };
      
      final result = await DatabaseService.markAttendance(attendanceData);
      if (!result) success = false;
    }

    Navigator.pop(context);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance marked successfully')),
      );
      _attendanceStatus.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save attendance')),
      );
    }
  }

  void _viewAttendanceHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Attendance History', style: GoogleFonts.inter()),
        content: const SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Center(
            child: Text('Attendance history would be displayed here'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Management', style: GoogleFonts.inter()),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
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
            : Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mark Attendance',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _viewAttendanceHistory,
                              icon: const Icon(Icons.history),
                              label: const Text('History'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: _markAttendance,
                              icon: const Icon(Icons.how_to_reg),
                              label: const Text('Mark Attendance'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF667eea),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Stats Cards
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Students',
                            _students.length.toString(),
                            Icons.people,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'My Subjects',
                            _subjects.length.toString(),
                            Icons.book,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Today',
                            DateTime.now().toString().split(' ')[0],
                            Icons.today,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Instructions
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              'Instructions',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Select subject and date to mark attendance\n'
                          '• Choose between marking presentees or absentees\n'
                          '• Once submitted, attendance cannot be edited by normal faculty\n'
                          '• Only HoD can modify locked attendance records',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Recent Activity
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
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
                            'Recent Attendance',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Center(
                              child: Text(
                                'No recent attendance records',
                                style: GoogleFonts.inter(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
            color: Colors.grey.withOpacity(0.1),
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
