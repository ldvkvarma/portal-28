import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_service.dart';

class RemarksSection extends StatefulWidget {
  final String studentId;

  const RemarksSection({super.key, required this.studentId});

  @override
  State<RemarksSection> createState() => _RemarksSectionState();
}

class _RemarksSectionState extends State<RemarksSection> {
  List<Map<String, dynamic>> _remarksData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRemarksData();
  }

  Future<void> _loadRemarksData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await DatabaseService.getRemarks(widget.studentId);
      setState(() {
        _remarksData = data;
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
                'FACULTY REMARKS',
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
        
        // Remarks Cards
        if (_remarksData.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.comment,
                  size: 50,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 15),
                Text(
                  'No remarks available yet',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Your faculty will add remarks here once available',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Remarks List
          ..._remarksData.map((remark) => _buildRemarkCard(remark)).toList(),
        ],
      ],
    );
  }

  Widget _buildRemarkCard(Map<String, dynamic> remark) {
    final remarkType = remark['type'] ?? 'general';
    final color = _getRemarkColor(remarkType);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
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
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getRemarkIcon(remarkType),
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    remark['subject'] ?? 'General',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getRemarkTypeText(remarkType),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  remark['remark'] ?? 'No remark text available',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Date: ${_formatDate(remark['date'])}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Posted: ${_formatDateTime(remark['createdAt'])}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRemarkColor(String type) {
    switch (type) {
      case 'positive':
        return Colors.green;
      case 'improvement':
        return Colors.orange;
      case 'warning':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getRemarkIcon(String type) {
    switch (type) {
      case 'positive':
        return Icons.thumb_up;
      case 'improvement':
        return Icons.trending_up;
      case 'warning':
        return Icons.warning;
      default:
        return Icons.comment;
    }
  }

  String _getRemarkTypeText(String type) {
    switch (type) {
      case 'positive':
        return 'Positive';
      case 'improvement':
        return 'Improvement';
      case 'warning':
        return 'Warning';
      default:
        return 'General';
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatDateTime(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
