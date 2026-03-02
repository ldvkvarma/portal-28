import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../services/database_service.dart';

class CertificatesSection extends StatefulWidget {
  final String studentId;

  const CertificatesSection({super.key, required this.studentId});

  @override
  State<CertificatesSection> createState() => _CertificatesSectionState();
}

class _CertificatesSectionState extends State<CertificatesSection> {
  List<Map<String, dynamic>> _certificatesData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCertificatesData();
  }

  Future<void> _loadCertificatesData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await DatabaseService.getCertificates(widget.studentId);
      setState(() {
        _certificatesData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAddCertificateDialog() {
    showDialog(
      context: context,
      builder: (context) => AddCertificateDialog(
        onCertificateAdded: () {
          _loadCertificatesData();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and Add Button - Responsive layout
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'CERTIFICATES & ACHIEVEMENTS',
                style: GoogleFonts.inter(
                  fontSize: MediaQuery.of(context).size.width < 600 ? 24 : 32,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF667eea),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: _showAddCertificateDialog,
              icon: const Icon(Icons.add),
              label: Text(
                MediaQuery.of(context).size.width < 600 ? 'Add' : 'Add Certificate',
                style: GoogleFonts.inter(fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width < 600 ? 8 : 16,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 30),
        
        // Certificates List
        if (_certificatesData.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.card_membership,
                  size: 50,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 15),
                Text(
                  'No certificates added yet',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Add your internships, hackathons, workshops, and other achievements',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: _showAddCertificateDialog,
                  icon: const Icon(Icons.add),
                  label: Text(
                    'Add Your First Certificate',
                    style: GoogleFonts.inter(),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Certificate Cards
          ..._certificatesData.map((certificate) => _buildCertificateCard(certificate)).toList(),
        ],
      ],
    );
  }

  Widget _buildCertificateCard(Map<String, dynamic> certificate) {
    final type = certificate['type'] ?? 'general';
    final color = _getCertificateColor(type);
    
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
                  _getCertificateIcon(type),
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    certificate['title'] ?? 'Certificate',
                    style: GoogleFonts.inter(
                      fontSize: 16,
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
                    _getCertificateTypeText(type),
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
                // Organization and Duration
                Row(
                  children: [
                    Icon(
                      Icons.business,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 5),
                    Text(
                      certificate['organization'] ?? 'N/A',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.date_range,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${certificate['startDate'] ?? 'N/A'} - ${certificate['endDate'] ?? 'N/A'}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                
                // Description
                if (certificate['description'] != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    certificate['description'],
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
                
                // File attachment
                if (certificate['certificateFile'] != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.attach_file,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 5),
                      Text(
                        certificate['certificateFile'],
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
                
                const SizedBox(height: 10),
                
                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        // View certificate
                      },
                      icon: const Icon(Icons.visibility, size: 16),
                      label: Text(
                        'View',
                        style: GoogleFonts.inter(fontSize: 12),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF667eea),
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton.icon(
                      onPressed: () {
                        // Download certificate
                      },
                      icon: const Icon(Icons.download, size: 16),
                      label: Text(
                        'Download',
                        style: GoogleFonts.inter(fontSize: 12),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF51cf66),
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

  Color _getCertificateColor(String type) {
    switch (type) {
      case 'internship':
        return Colors.blue;
      case 'hackathon':
        return Colors.purple;
      case 'workshop':
        return Colors.orange;
      case 'competition':
        return Colors.red;
      case 'course':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getCertificateIcon(String type) {
    switch (type) {
      case 'internship':
        return Icons.work;
      case 'hackathon':
        return Icons.code;
      case 'workshop':
        return Icons.school;
      case 'competition':
        return Icons.emoji_events;
      case 'course':
        return Icons.menu_book;
      default:
        return Icons.card_membership;
    }
  }

  String _getCertificateTypeText(String type) {
    switch (type) {
      case 'internship':
        return 'Internship';
      case 'hackathon':
        return 'Hackathon';
      case 'workshop':
        return 'Workshop';
      case 'competition':
        return 'Competition';
      case 'course':
        return 'Course';
      default:
        return 'Certificate';
    }
  }
}

class AddCertificateDialog extends StatefulWidget {
  final VoidCallback onCertificateAdded;

  const AddCertificateDialog({super.key, required this.onCertificateAdded});

  @override
  State<AddCertificateDialog> createState() => _AddCertificateDialogState();
}

class _AddCertificateDialogState extends State<AddCertificateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _organizationController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'internship';
  String? _selectedFile;

  @override
  void dispose() {
    _titleController.dispose();
    _organizationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.single.name;
      });
    }
  }

  Future<void> _saveCertificate() async {
    if (_formKey.currentState!.validate()) {
      // In a real app, you would save this to the database
      // await DatabaseService.addCertificate(widget.studentId, {
      //   'title': _titleController.text,
      //   'organization': _organizationController.text,
      //   'duration': '${_startDateController.text} - ${_endDateController.text}',
      //   'startDate': _startDateController.text,
      //   'endDate': _endDateController.text,
      //   'description': _descriptionController.text,
      //   'certificateFile': _selectedFile,
      //   'type': _selectedType,
      // });

      Navigator.of(context).pop();
      widget.onCertificateAdded();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Add Certificate',
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Certificate Type
                DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'Certificate Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'internship', child: Text('Internship')),
                    DropdownMenuItem(value: 'hackathon', child: Text('Hackathon')),
                    DropdownMenuItem(value: 'workshop', child: Text('Workshop')),
                    DropdownMenuItem(value: 'competition', child: Text('Competition')),
                    DropdownMenuItem(value: 'course', child: Text('Course')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                ),
                const SizedBox(height: 15),

                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter certificate title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Organization
                TextFormField(
                  controller: _organizationController,
                  decoration: InputDecoration(
                    labelText: 'Organization',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter organization name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Date Range
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _startDateController,
                        decoration: InputDecoration(
                          labelText: 'Start Date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TextFormField(
                        controller: _endDateController,
                        decoration: InputDecoration(
                          labelText: 'End Date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // File Upload
                InkWell(
                  onTap: _pickFile,
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.cloud_upload,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _selectedFile ?? 'Click to upload certificate file',
                            style: GoogleFonts.inter(
                              color: _selectedFile != null ? Colors.black87 : Colors.grey[600],
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
        ),
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
          onPressed: _saveCertificate,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667eea),
            foregroundColor: Colors.white,
          ),
          child: Text(
            'Add Certificate',
            style: GoogleFonts.inter(),
          ),
        ),
      ],
    );
  }
}
