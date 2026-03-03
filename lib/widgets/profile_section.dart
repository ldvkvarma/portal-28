import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_service.dart';

class ProfileSection extends StatefulWidget {
  final Map<String, dynamic>? studentData;
  final VoidCallback? onRefresh;

  const ProfileSection({super.key, this.studentData, this.onRefresh});

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.studentData != null) {
      _populateControllers(widget.studentData!);
    }
  }

  @override
  void didUpdateWidget(covariant ProfileSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.studentData != oldWidget.studentData && widget.studentData != null) {
      _populateControllers(widget.studentData!);
    }
  }

  void _populateControllers(Map<String, dynamic> data) {
    _phoneController.text = data['phone']?.toString() ?? '';
    _emailController.text = data['email']?.toString() ?? '';
    _addressController.text = data['address']?.toString() ?? '';
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final updates = {
          'email': _emailController.text,
          'address': _addressController.text,
        };

        final success = await DatabaseService.updateStudent(
          widget.studentData!['id'],
          updates,
        );

        if (success) {
          if (widget.onRefresh != null) {
            widget.onRefresh!();
          }
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Profile updated successfully',
                  style: GoogleFonts.inter(),
                ),
                backgroundColor: Colors.green,
              ),
            );
            setState(() {
              _isEditing = false;
            });
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to update profile',
                style: GoogleFonts.inter(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  List<Widget> _buildActionButtons() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isExtraSmall = screenWidth < 600;
    final buttonPadding = isExtraSmall ? 8.0 : 12.0;
    final fontSize = isExtraSmall ? 12.0 : 14.0;
    
    return [
      if (!_isEditing)
        ElevatedButton(
          onPressed: () {
            setState(() {
              _isEditing = true;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667eea),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: buttonPadding, vertical: 8),
          ),
          child: Text(
            'Edit',
            style: GoogleFonts.inter(fontSize: fontSize),
          ),
        ),
      if (_isEditing) ...[
        ElevatedButton(
          onPressed: _isLoading ? null : _saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF51cf66),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: buttonPadding, vertical: 8),
          ),
          child: _isLoading
              ? SizedBox(
                  width: isExtraSmall ? 12 : 16,
                  height: isExtraSmall ? 12 : 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'Save',
                  style: GoogleFonts.inter(fontSize: fontSize),
                ),
        ),
        SizedBox(width: isExtraSmall ? 5 : 10),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _isEditing = false;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: buttonPadding, vertical: 8),
          ),
          child: Text(
            'Cancel',
            style: GoogleFonts.inter(fontSize: fontSize),
          ),
        ),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (widget.studentData == null) {
      // show message instead of indefinite spinner
      return const Center(child: Text('Loading profile...'));
    }

    final student = widget.studentData!;
    
    // Check screen size for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 800; // Increased threshold for better responsiveness

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Actions - Responsive layout
          SizedBox(
            width: double.infinity,
            child: isSmallScreen ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'STUDENT PROFILE',
                    style: GoogleFonts.inter(
                      fontSize: screenWidth < 600 ? 16 : 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF667eea),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _buildActionButtons(),
                ),
              ],
            ) : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'STUDENT PROFILE',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF667eea),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _buildActionButtons(),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Profile Content
          Column(
            children: [
              // Personal Details
              _buildSectionCard('Personal Details', [
                _buildDetailRow('Admission No', student['admissionNo']),
                _buildDetailRow('Roll No', student['rollNo']),
                _buildDetailRow('Name', student['name']),
                _buildDetailRow('Course', student['course']),
                _buildDetailRow('Branch', student['branch']),
                _buildDetailRow('Semester', student['semester']),
                _buildDetailRow('Section', student['section']),
                _buildDetailRow('Batch', student['batch']),
                _buildDetailRow('CGPA', student['cgpa']),
                _buildDetailRow('Backlogs', student['backlogs']),
              ]),
              
              const SizedBox(height: 20),
              
              // Contact Details
              _buildSectionCard('Contact Details', [
                _buildDetailRow('Phone', student['phone']),
                if (_isEditing)
                  _buildEditableRow('Email', _emailController, TextInputType.emailAddress)
                else
                  _buildDetailRow('Email', student['email']),
                if (_isEditing)
                  _buildEditableRow('Address', _addressController, TextInputType.multiline)
                else
                  _buildDetailRow('Address', student['address']),
                _buildDetailRow('Emergency Contact', student['emergencyContact']),
              ]),
              
              const SizedBox(height: 20),
              
              // Personal Information
              _buildSectionCard('Personal Information', [
                _buildDetailRow('Date of Birth', student['dob']),
                _buildDetailRow('Gender', student['gender']),
                _buildDetailRow('Blood Group', student['bloodGroup']),
                _buildDetailRow('Nationality', student['nationality']),
                _buildDetailRow('Religion', student['religion']),
                _buildDetailRow('Category', student['category']),
                _buildDetailRow('Aadhar Number', student['aadhar']),
              ]),
              
              const SizedBox(height: 20),
              
              // Parent Details
              _buildSectionCard('Parent Details', [
                _buildDetailRow('Father Name', student['fatherName']),
                _buildDetailRow('Father Occupation', student['fatherOccupation']),
                _buildDetailRow('Mother Name', student['motherName']),
                _buildDetailRow('Mother Occupation', student['motherOccupation']),
                _buildDetailRow('Parent Phone', student['parentPhone']),
                _buildDetailRow('Permanent Address', student['permanentAddress']),
              ]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
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
          // Section Header
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
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          
          // Section Content
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    // convert any value to string so we don't crash when it's an int, bool, etc.
    final display = value?.toString() ?? 'N/A';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              display,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableRow(String label, TextEditingController controller, TextInputType keyboardType) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: keyboardType == TextInputType.multiline ? 3 : 1,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              style: GoogleFonts.inter(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
