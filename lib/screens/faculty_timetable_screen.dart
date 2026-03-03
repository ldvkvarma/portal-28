import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';

class FacultyTimetableScreen extends StatefulWidget {
  const FacultyTimetableScreen({super.key});

  @override
  State<FacultyTimetableScreen> createState() => _FacultyTimetableScreenState();
}

class _FacultyTimetableScreenState extends State<FacultyTimetableScreen> {
  List<Map<String, dynamic>> _timetable = [];
  List<Map<String, dynamic>> _subjects = [];
  List<Map<String, dynamic>> _faculty = [];
  bool _isLoading = true;
  String? _selectedDay;
  Map<String, dynamic> _editingDay = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final timetable = await DatabaseService.getTimetable();
      final subjects = await DatabaseService.getSubjects();
      
      // Get faculty data
      final prefs = await SharedPreferences.getInstance();
      final facultyJson = prefs.getString('faculty') ?? '[]';
      final faculty = jsonDecode(facultyJson) as List;
      
      setState(() {
        _timetable = timetable;
        _subjects = subjects;
        _faculty = faculty.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showEditTimetableDialog(String day) {
    final existingDay = _timetable.firstWhere(
      (tt) => tt['day'] == day,
      orElse: () => {'day': day},
    );
    
    _editingDay = Map.from(existingDay);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $day Timetable', style: GoogleFonts.inter()),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildPeriodEditor('Period 1', '9:00-10:00', 'period1'),
                _buildPeriodEditor('Period 2', '10:00-11:00', 'period2'),
                _buildBreakEditor('Break', '11:00-11:15', 'break1'),
                _buildPeriodEditor('Period 3', '11:15-12:15', 'period3'),
                _buildPeriodEditor('Period 4', '12:15-1:15', 'period4'),
                _buildBreakEditor('Lunch', '1:15-2:00', 'lunch'),
                _buildPeriodEditor('Period 5', '2:00-3:00', 'period5'),
                _buildPeriodEditor('Period 6', '3:00-4:00', 'period6'),
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
            onPressed: _saveTimetable,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodEditor(String title, String time, String key) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title ($time)',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _editingDay[key]?['subject'],
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: _subjects.map<DropdownMenuItem<String>>((subject) => DropdownMenuItem<String>(
                      value: subject['code'] as String,
                      child: Text('${subject['code']} - ${subject['name']}'),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        if (_editingDay[key] == null) _editingDay[key] = {};
                        _editingDay[key]['subject'] = value;
                        _editingDay[key]['time'] = time;
                        _editingDay[key]['room'] = _editingDay[key]['room'] ?? 'C301';
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _editingDay[key]?['faculty'],
                    decoration: const InputDecoration(
                      labelText: 'Faculty',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: _faculty.map<DropdownMenuItem<String>>((f) => DropdownMenuItem<String>(
                      value: f['id'] as String,
                      child: Text(f['name']),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        if (_editingDay[key] == null) _editingDay[key] = {};
                        _editingDay[key]['faculty'] = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: _editingDay[key]?['room'],
                    decoration: const InputDecoration(
                      labelText: 'Room',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (_editingDay[key] == null) _editingDay[key] = {};
                        _editingDay[key]['room'] = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakEditor(String title, String time, String key) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: Colors.grey.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              title == 'Break' ? Icons.coffee : Icons.restaurant,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Text(
              '$title ($time)',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTimetable() async {
    final day = _editingDay['day'];
    final existingIndex = _timetable.indexWhere((tt) => tt['day'] == day);
    
    final timetableData = {
      ..._editingDay,
      'id': existingIndex != -1 ? _timetable[existingIndex]['id'] : 'tt${DateTime.now().millisecondsSinceEpoch}',
      'updatedAt': DateTime.now().toIso8601String(),
    };

    bool success;
    if (existingIndex != -1) {
      success = await DatabaseService.updateTimetable(_timetable[existingIndex]['id'], timetableData);
    } else {
      // Add new timetable entry
      success = await DatabaseService.addTimetable(timetableData);
    }

    if (success) {
      Navigator.pop(context);
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Timetable updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Timetable', style: GoogleFonts.inter()),
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
                    child: Text(
                      'Weekly Timetable Management',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  
                  // Days Grid
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
                        final day = days[index];
                        final dayData = _timetable.firstWhere(
                          (tt) => tt['day'] == day,
                          orElse: () => {},
                        );
                        
                        return Card(
                          child: InkWell(
                            onTap: () => _showEditTimetableDialog(day),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        day,
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Icon(
                                        Icons.edit,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  if (dayData.isNotEmpty) ...[
                                    _buildMiniPeriod('Period 1', dayData['period1']),
                                    _buildMiniPeriod('Period 2', dayData['period2']),
                                    _buildMiniBreak('Break', dayData['break1']),
                                    _buildMiniPeriod('Period 3', dayData['period3']),
                                    _buildMiniPeriod('Period 4', dayData['period4']),
                                    _buildMiniBreak('Lunch', dayData['lunch']),
                                    _buildMiniPeriod('Period 5', dayData['period5']),
                                    _buildMiniPeriod('Period 6', dayData['period6']),
                                  ] else ...[
                                    Container(
                                      height: 100,
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Tap to configure',
                                        style: GoogleFonts.inter(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
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
    );
  }

  Widget _buildMiniPeriod(String title, Map<String, dynamic>? period) {
    if (period == null) return const SizedBox(height: 2);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              title,
              style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Center(
                child: Text(
                  period['subject'] ?? '',
                  style: GoogleFonts.inter(fontSize: 8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBreak(String title, Map<String, dynamic>? breakData) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              title,
              style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Center(
                child: Text(
                  breakData?['time'] ?? '',
                  style: GoogleFonts.inter(fontSize: 8, color: Colors.grey[600]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
