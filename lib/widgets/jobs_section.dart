import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_service.dart';

class JobsSection extends StatefulWidget {
  final String studentId;

  const JobsSection({super.key, required this.studentId});

  @override
  State<JobsSection> createState() => _JobsSectionState();
}

class _JobsSectionState extends State<JobsSection> {
  List<Map<String, dynamic>> _jobsData = [];
  List<Map<String, dynamic>> _studentCertificates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final jobs = await DatabaseService.getJobs();
      final certificates = await DatabaseService.getCertificates(widget.studentId);
      
      setState(() {
        _jobsData = jobs;
        _studentCertificates = certificates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isJobMatched(Map<String, dynamic> job) {
    final jobSkills = (job['skills'] as List<dynamic>?)?.map((s) => s.toString().toLowerCase()).toList() ?? [];
    final studentSkills = _extractStudentSkills();
    
    // Check if student has at least 2 matching skills
    int matchingSkills = 0;
    for (final skill in studentSkills) {
      if (jobSkills.any((jobSkill) => jobSkill.contains(skill))) {
        matchingSkills++;
      }
    }
    
    return matchingSkills >= 2;
  }

  List<String> _extractStudentSkills() {
    final skills = <String>{};
    
    // Extract skills from certificates
    for (final cert in _studentCertificates) {
      final description = cert['description']?.toString().toLowerCase() ?? '';
      
      // Add common programming languages and technologies
      if (description.contains('python')) skills.add('python');
      if (description.contains('java')) skills.add('java');
      if (description.contains('javascript')) skills.add('javascript');
      if (description.contains('react')) skills.add('react');
      if (description.contains('sql')) skills.add('sql');
      if (description.contains('machine learning')) skills.add('machine learning');
      if (description.contains('ml')) skills.add('ml');
      if (description.contains('web')) skills.add('web');
      if (description.contains('flutter')) skills.add('flutter');
      if (description.contains('android')) skills.add('android');
    }
    
    return skills.toList();
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
                'JOB OPPORTUNITIES',
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
        
        // Matched Jobs Section
        if (_jobsData.any((job) => _isJobMatched(job))) ...[
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.work,
                  color: Colors.green,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Jobs matching your profile are available!',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Jobs List
        if (_jobsData.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.work_outline,
                  size: 50,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 15),
                Text(
                  'No job opportunities available',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Check back later for new job postings',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Filter Tabs
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
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF667eea),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      'All Jobs (${_jobsData.length})',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Matched (${_jobsData.where((job) => _isJobMatched(job)).length})',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Job Cards
          ..._jobsData.map((job) => _buildJobCard(job)).toList(),
        ],
      ],
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    final isMatched = _isJobMatched(job);
    
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
        border: isMatched ? Border.all(color: Colors.green, width: 2) : null,
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isMatched ? Colors.green.withValues(alpha: 0.1) : const Color(0xFF667eea).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        job['title'] ?? 'Job Title',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isMatched ? Colors.green : const Color(0xFF667eea),
                        ),
                      ),
                    ),
                    if (isMatched) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Matched',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.business,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 5),
                    Text(
                      job['company'] ?? 'Company Name',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 5),
                    Text(
                      job['location'] ?? 'Location',
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
          
          // Content
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job Details
                Row(
                  children: [
                    _buildJobDetailChip(job['type'] ?? 'Full-time', Icons.work),
                    const SizedBox(width: 10),
                    _buildJobDetailChip(job['experience'] ?? '0-2 Years', Icons.trending_up),
                    const SizedBox(width: 10),
                    _buildJobDetailChip(job['salary'] ?? 'Salary', Icons.attach_money),
                  ],
                ),
                
                const SizedBox(height: 15),
                
                // Description
                Text(
                  job['description'] ?? 'Job description not available',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                
                const SizedBox(height: 15),
                
                // Skills Required
                if (job['skills'] != null) ...[
                  Text(
                    'Skills Required:',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (job['skills'] as List<dynamic>).map((skill) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        skill.toString(),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 15),
                ],
                
                // Deadline
                Row(
                  children: [
                    Icon(
                      Icons.event,
                      size: 16,
                      color: Colors.red[600],
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Apply by: ${job['deadline'] ?? 'N/A'}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.red[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 15),
                
                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        // View details
                      },
                      icon: const Icon(Icons.info_outline, size: 16),
                      label: Text(
                        'View Details',
                        style: GoogleFonts.inter(fontSize: 12),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF667eea),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        _showApplyDialog(job);
                      },
                      icon: const Icon(Icons.send, size: 16),
                      label: Text(
                        'Apply Now',
                        style: GoogleFonts.inter(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isMatched ? Colors.green : const Color(0xFF667eea),
                        foregroundColor: Colors.white,
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

  Widget _buildJobDetailChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showApplyDialog(Map<String, dynamic> job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Apply for Job',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Position: ${job['title']}',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Company: ${job['company']}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Your application will be sent to the placement officer for review.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Application submitted successfully!',
                    style: GoogleFonts.inter(),
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Submit Application',
              style: GoogleFonts.inter(),
            ),
          ),
        ],
      ),
    );
  }
}
