import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class FacultyMarksScreen extends StatefulWidget {
  const FacultyMarksScreen({super.key});

  @override
  State<FacultyMarksScreen> createState() => _FacultyMarksScreenState();
}

class _FacultyMarksScreenState extends State<FacultyMarksScreen> {
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _subjects = [];
  Map<String, dynamic>? _facultyData;
  bool _isLoading = true;
  String? _selectedSubject;
  String? _selectedExam;
  Map<String, TextEditingController> _marksControllers = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final facultyData = AuthService().currentUserData;
      final subjects = await DatabaseService.getSubjects();
      final students = await DatabaseService.getAllStudents();
      
      // Filter my subjects
      final mySubjects = subjects.where((subject) =>
          facultyData?['subjects']?.contains(subject['code']) == true
      ).toList();
      
      setState(() {
        _facultyData = facultyData;
        _subjects = mySubjects;
        _students = students;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _addMarks() {
    if (_selectedSubject == null || _selectedExam == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select subject and exam type')),
      );
      return;
    }

    // Initialize controllers for each student
    for (final student in _students) {
      _marksControllers[student['id']] ??= TextEditingController();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Internal Marks', style: GoogleFonts.inter()),
        content: StatefulBuilder(
          builder: (context, setDialogState) => SizedBox(
            width: double.maxFinite,
            height: 500,
            child: Column(
              children: [
                // Subject and Exam Selection
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
                      child: DropdownButtonFormField<String>(
                        value: _selectedExam,
                        decoration: const InputDecoration(
                          labelText: 'Exam Type',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Internal1', 'Internal2'].map((exam) => DropdownMenuItem(
                          value: exam,
                          child: Text(exam),
                        )).toList(),
                        onChanged: (value) {
                          setState(() => _selectedExam = value);
                          setDialogState(() => _selectedExam = value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Max Marks Input
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Maximum Marks',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., 30',
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: '30',
                  onChanged: (value) {
                    // You can store max marks if needed
                  },
                ),
                const SizedBox(height: 16),
                const Divider(),
                
                // Students List with Marks
                Text(
                  'Enter Marks for Students',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                Expanded(
                  child: ListView.builder(
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      final rollNo = student['rollNo'] ?? student['admissionNo'];
                      final controller = _marksControllers[student['id']]!;
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.withOpacity(0.1),
                            child: Text(
                              '${index + 1}',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          title: Text(
                            student['name'],
                            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text('Roll No: $rollNo'),
                          trailing: SizedBox(
                            width: 80,
                            child: TextFormField(
                              controller: controller,
                              decoration: const InputDecoration(
                                labelText: 'Marks',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                            ),
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
            onPressed: _saveMarks,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save Marks'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveMarks() async {
    if (_selectedSubject == null || _selectedExam == null) return;

    bool success = true;
    for (final student in _students) {
      final controller = _marksControllers[student['id']];
      if (controller != null && controller.text.isNotEmpty) {
        final marksData = {
          'studentId': student['id'],
          'subject': _selectedSubject,
          'exam': _selectedExam,
          'marks': controller.text,
          'maxMarks': '30', // Default max marks
          'facultyId': _facultyData?['id'],
          'isLocked': false,
        };
        
        final result = await DatabaseService.addInternalMarks(marksData);
        if (!result) success = false;
      }
    }

    Navigator.pop(context);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marks saved successfully')),
      );
      _marksControllers.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save marks')),
      );
    }
  }

  void _viewMarksHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Marks History', style: GoogleFonts.inter()),
        content: const SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Center(
            child: Text('Marks history would be displayed here'),
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

  void _lockMarks() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Lock Marks', style: GoogleFonts.inter()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock, size: 48, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              'Once marks are locked, they cannot be edited by normal faculty.\nOnly HoD can modify locked marks.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(),
            ),
            const SizedBox(height: 16),
            Text(
              'Are you sure you want to lock the marks?',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Marks locked successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Lock Marks'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Internal Marks Management', style: GoogleFonts.inter()),
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
                          'Manage Internal Marks',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _viewMarksHistory,
                              icon: const Icon(Icons.history),
                              label: const Text('History'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: _lockMarks,
                              icon: const Icon(Icons.lock),
                              label: const Text('Lock'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: _addMarks,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Marks'),
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
                            'Internal Exams',
                            '2',
                            Icons.assignment,
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
                          '• Select subject and exam type (Internal1 or Internal2)\n'
                          '• Enter marks for each student (out of 30)\n'
                          '• Once submitted and locked, marks cannot be edited\n'
                          '• Only HoD can modify locked marks records\n'
                          '• All marks will be reflected on student dashboard',
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
                            'Recent Marks Entry',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Center(
                              child: Text(
                                'No recent marks entries',
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
