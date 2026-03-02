import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_service.dart';

class AttendanceSection extends StatefulWidget {
  final String studentId;

  const AttendanceSection({super.key, required this.studentId});

  @override
  State<AttendanceSection> createState() => _AttendanceSectionState();
}

class _AttendanceSectionState extends State<AttendanceSection> {
  List<Map<String, dynamic>> _attendanceData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  Future<void> _loadAttendanceData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await DatabaseService.getAttendance(widget.studentId);
      setState(() {
        _attendanceData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _calculateAttendanceStats() {
    final subjectStats = <String, Map<String, dynamic>>{};
    
    for (final record in _attendanceData) {
      final subject = record['subject'];
      if (!subjectStats.containsKey(subject)) {
        subjectStats[subject] = {
          'held': 0,
          'present': 0,
          'absent': 0,
        };
      }
      
      subjectStats[subject]!['held']++;
      if (record['status'] == 'P') {
        subjectStats[subject]!['present']++;
      } else {
        subjectStats[subject]!['absent']++;
      }
    }

    // Calculate percentages
    for (final subject in subjectStats.keys) {
      final stats = subjectStats[subject]!;
      final total = stats['held'];
      if (total > 0) {
        stats['percentage'] = ((stats['present'] / total) * 100).toStringAsFixed(2);
      } else {
        stats['percentage'] = '0.00';
      }
    }

    return subjectStats;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final subjectStats = _calculateAttendanceStats();
    final totalHeld = subjectStats.values.fold<int>(0, (sum, stats) => sum + (stats['held'] as int));
    final totalPresent = subjectStats.values.fold<int>(0, (sum, stats) => sum + (stats['present'] as int));
    final totalPercentage = totalHeld > 0 ? ((totalPresent / totalHeld) * 100).toStringAsFixed(2) : '0.00';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and Actions - Responsive layout
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'ATTENDANCE RECORDS',
                style: GoogleFonts.inter(
                  fontSize: MediaQuery.of(context).size.width < 600 ? 24 : 32,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF667eea),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            // Edit button placeholder (if needed in future)
            if (MediaQuery.of(context).size.width < 600)
              const SizedBox(width: 10),
          ],
        ),
        
        const SizedBox(height: 30),
        
        // Summary Cards
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Classes',
                totalHeld.toString(),
                Icons.calendar_today,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildSummaryCard(
                'Classes Attended',
                totalPresent.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildSummaryCard(
                'Attendance %',
                '$totalPercentage%',
                Icons.percent,
                _getPercentageColor(double.parse(totalPercentage)),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 30),
        
        // Subject-wise Attendance
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Text(
                  'Subject-wise Attendance',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              
              // Table
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 30,
                  horizontalMargin: 20,
                  headingRowColor: MaterialStateProperty.all(const Color(0xFFf2f2f2)),
                  dataRowHeight: 50,
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Subject',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Held',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Present',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Absent',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Percentage',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                  rows: subjectStats.entries.map((entry) {
                    final subject = entry.key;
                    final stats = entry.value;
                    final percentage = double.parse(stats['percentage']);
                    
                    return DataRow(
                      color: MaterialStateProperty.all(
                        subjectStats.keys.toList().indexOf(subject) % 2 == 0 
                            ? Colors.transparent 
                            : Colors.grey.withOpacity(0.05),
                      ),
                      cells: [
                        DataCell(
                          Text(
                            subject,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            stats['held'].toString(),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            stats['present'].toString(),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            stats['absent'].toString(),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            stats['percentage'],
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _getPercentageColor(percentage),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getPercentageColor(percentage).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              percentage >= 75 ? 'Good' : 'Need Improvement',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _getPercentageColor(percentage),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 30),
        
        // Recent Attendance
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Text(
                  'Recent Attendance',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              
              // Recent Records
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _attendanceData.take(10).length,
                itemBuilder: (context, index) {
                  final record = _attendanceData[index];
                  return Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            record['date'] ?? 'N/A',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            record['subject'] ?? 'N/A',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: record['status'] == 'P' 
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              record['status'] == 'P' ? 'Present' : 'Absent',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: record['status'] == 'P' 
                                    ? Colors.green 
                                    : Colors.red,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 30,
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 75) {
      return Colors.green;
    } else if (percentage >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
