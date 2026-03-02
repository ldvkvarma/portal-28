import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_service.dart';

class MarksSection extends StatefulWidget {
  final String studentId;

  const MarksSection({super.key, required this.studentId});

  @override
  State<MarksSection> createState() => _MarksSectionState();
}

class _MarksSectionState extends State<MarksSection> {
  List<Map<String, dynamic>> _marksData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMarksData();
  }

  Future<void> _loadMarksData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await DatabaseService.getMarks(widget.studentId);
      setState(() {
        _marksData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and Actions - Responsive layout
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'MARKS & ACADEMICS',
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
        
        // Marks Table
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
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
                  'Internal Marks',
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
                  headingRowColor: WidgetStateProperty.all(const Color(0xFFf2f2f2)),
                  dataRowMinHeight: 50,
                  dataRowMaxHeight: 50,
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
                        'Exam Type',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Marks',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Max Marks',
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
                        'Grade',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                  rows: _marksData.map((mark) {
                    final marks = int.tryParse(mark['marks']) ?? 0;
                    final maxMarks = int.tryParse(mark['maxMarks']) ?? 1;
                    final percentage = (marks / maxMarks * 100);
                    final grade = _getGrade(percentage);
                    
                    return DataRow(
                      color: WidgetStateProperty.all(
                        _marksData.indexOf(mark) % 2 == 0 
                            ? Colors.transparent 
                            : Colors.grey.withValues(alpha: 0.05),
                      ),
                      cells: [
                        DataCell(
                          Text(
                            mark['subject'] ?? 'N/A',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            mark['type'] ?? 'N/A',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            mark['marks'] ?? 'N/A',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _getMarksColor(percentage),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            mark['maxMarks'] ?? 'N/A',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _getMarksColor(percentage),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getGradeColor(grade).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              grade,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _getGradeColor(grade),
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
        
        if (_marksData.isEmpty) ...[
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.grade,
                  size: 50,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 15),
                Text(
                  'No marks available yet',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Your faculty will post marks here once available',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _getGrade(double percentage) {
    if (percentage >= 90) return 'S';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    if (percentage >= 50) return 'D';
    if (percentage >= 40) return 'E';
    return 'F';
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'S':
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.deepOrange;
      default:
        return Colors.red;
    }
  }

  Color _getMarksColor(double percentage) {
    if (percentage >= 75) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }
}
