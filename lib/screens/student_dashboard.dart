import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/resume_service.dart';
import '../widgets/profile_section.dart';
import '../widgets/attendance_section.dart';
import '../widgets/marks_section.dart';
import '../widgets/remarks_section.dart';
import '../widgets/certificates_section.dart';
import '../widgets/jobs_section.dart';
import '../widgets/password_change_dialog.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  String _studentName = 'Student';
  String _selectedSection = 'profile';
  int _unreadNotifications = 0;
  Map<String, dynamic>? _studentData;
  
  @override
  void initState() {
    super.initState();
    _loadStudentData();
    _loadNotifications();
  }

  Future<void> _loadStudentData() async {
    final auth = AuthService();
    await auth.updateCurrentUser();
    final data = auth.currentUserData;
    if (data == null) {
      debugPrint('StudentDashboard: currentUserData is null');
    }
    setState(() {
      _studentData = data;
      _studentName = data?['name'] ?? 'Student';
    });
  }

  Future<void> _loadNotifications() async {
    final auth = AuthService();
    final notifications = await DatabaseService.getNotifications(auth.currentUserId!);
    setState(() {
      _unreadNotifications = notifications.where((n) => n['isRead'] == false).length;
    });
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  void _onSectionSelected(String section) {
    debugPrint('StudentDashboard: section selected $section');
    setState(() {
      _selectedSection = section;
    });
  }

  Widget _buildSelectedSection() {
    switch (_selectedSection) {
      case 'profile':
        if (_studentData == null) {
          return const Center(child: Text('No profile information available.'));
        }
        return ProfileSection(studentData: _studentData, onRefresh: _loadStudentData);
      case 'attendance':
        return AttendanceSection(studentId: AuthService().currentUserId!);
      case 'marks':
        return MarksSection(studentId: AuthService().currentUserId!);
      case 'remarks':
        return RemarksSection(studentId: AuthService().currentUserId!);
      case 'certificates':
        return CertificatesSection(studentId: AuthService().currentUserId!);
      case 'jobs':
        return JobsSection(studentId: AuthService().currentUserId!);
      default:
        return ProfileSection(studentData: _studentData, onRefresh: _loadStudentData);
    }
  }

  List<Widget> _buildHeaderActions() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 600;
    
    // More responsive sizing based on screen width
    final iconSize = isSmall ? 14.0 : 24.0;
    final buttonPadding = isSmall ? 3.0 : 16.0;
    final iconGap = isSmall ? 4.0 : 8.0;
    
    return [
      // Notifications
      Stack(
        children: [
          IconButton(
            onPressed: () {
              _showNotifications();
            },
            icon: Icon(
              Icons.notifications,
              color: Colors.white,
              size: iconSize,
            ),
            padding: EdgeInsets.all(buttonPadding / 2),
            constraints: BoxConstraints(
              minWidth: iconSize + (buttonPadding * 0.8),
              minHeight: iconSize + (buttonPadding * 0.8),
            ),
          ),
          if (_unreadNotifications > 0)
            Positioned(
              right: 2,
              top: 6,
              child: Container(
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints: BoxConstraints(
                  minWidth: isSmall ? 14 : 16,
                  minHeight: isSmall ? 14 : 16,
                ),
                child: Text(
                  '$_unreadNotifications',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: isSmall ? 14 : 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      
      SizedBox(width: iconGap),
      
      // Resume Download
      IconButton(
        onPressed: () {
          _generateResume();
        },
        icon: Icon(
          Icons.download,
          color: Colors.white,
          size: iconSize,
        ),
        padding: EdgeInsets.all(buttonPadding / 2),
        constraints: BoxConstraints(
          minWidth: iconSize + buttonPadding,
          minHeight: iconSize + buttonPadding,
        ),
        tooltip: 'Download Resume',
      ),
      
      SizedBox(width: iconGap),
      
      // Password Change
      IconButton(
        onPressed: () {
          _showPasswordChangeDialog();
        },
        icon: Icon(
          Icons.lock,
          color: Colors.white,
          size: iconSize,
        ),
        padding: EdgeInsets.all(buttonPadding / 2),
        constraints: BoxConstraints(
          minWidth: iconSize + buttonPadding,
          minHeight: iconSize + buttonPadding,
        ),
        tooltip: 'Change Password',
      ),
      
      SizedBox(width: iconGap),
      
      // Logout
      TextButton(
        onPressed: _logout,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white),
          padding: EdgeInsets.symmetric(horizontal: buttonPadding, vertical: buttonPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
          ),
          minimumSize: Size(isSmall ? 40 : 80, isSmall ? 20 : 35),
        ),
        child: Text(
          'Logout',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: isSmall ? 11 : 13,
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 800;
    
    // Dynamic header height based on screen size
    final headerHeight = _calculateHeaderHeight(screenWidth);
    
    // Responsive font sizes
    final studentNameFontSize = screenWidth < 600 ? 14.0 : screenWidth < 800 ? 18.0 : 20.0;
    final dashboardFontSize = screenWidth < 600 ? 9.0 : screenWidth < 800 ? 11.0 : 12.0;
    
    return Scaffold(
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
        child: Column(
          children: [
            // Header - No top padding, starts directly at top
            Container(
              width: double.infinity,
              height: headerHeight,
              decoration: BoxDecoration(
                color: const Color(0xFF667eea),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: isSmall ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header image
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: Image.asset(
                        'assets/images/header.jpg',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.white.withValues(alpha: 0.2),
                            child: const Icon(
                              Icons.image,
                              color: Colors.white,
                              size: 24,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Student info and actions row for small screens
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left side with student info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _studentName,
                                style: GoogleFonts.inter(
                                  fontSize: studentNameFontSize,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Text(
                                'Student Dashboard',
                                style: GoogleFonts.inter(
                                  fontSize: dashboardFontSize,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Actions to the right
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: _buildHeaderActions(),
                        ),
                      ],
                    ),
                  ),
                ],
              ) : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full width header image
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: Image.asset(
                        'assets/images/header.jpg',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.white.withValues(alpha: 0.2),
                            child: const Icon(
                              Icons.image,
                              color: Colors.white,
                              size: 24,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Student info and actions row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left side with student info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _studentName,
                                style: GoogleFonts.inter(
                                  fontSize: studentNameFontSize,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Text(
                                'Student Dashboard',
                                style: GoogleFonts.inter(
                                  fontSize: dashboardFontSize,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Actions to the right
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: _buildHeaderActions(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // optional dropdown for small screens
            if (isSmall)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: _buildMenuDropdown(),
              ),

            // Main Content
            Expanded(
              child: isSmall
                  ? Column(
                      children: [
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: SingleChildScrollView(
                              child: _buildSelectedSection(),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        // Side Navigation
                        Container(
                          width: 250,
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Text(
                                  'STUDENT MENU',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                    letterSpacing: 1,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                
                                // Menu Items
                                _buildMenuItem('Profile', 'profile', Icons.person),
                                _buildMenuItem('Attendance', 'attendance', Icons.event_available),
                                _buildMenuItem('Marks', 'marks', Icons.grade),
                                _buildMenuItem('Remarks', 'remarks', Icons.comment),
                                _buildMenuItem('Certificates', 'certificates', Icons.card_membership),
                                _buildMenuItem('Job Opportunities', 'jobs', Icons.work),
                              ],
                            ),
                          ),
                        ),
                        
                        // Content Area
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: SingleChildScrollView(
                              child: _buildSelectedSection(),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, String sectionId, IconData icon) {
    final isSelected = _selectedSection == sectionId;
    
    return GestureDetector(
      onTap: () => _onSectionSelected(sectionId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF667eea)
              : const Color(0xFF667eea).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF667eea),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuDropdown() {
    final items = [
      {'title': 'Profile', 'id': 'profile', 'icon': Icons.person},
      {'title': 'Attendance', 'id': 'attendance', 'icon': Icons.event_available},
      {'title': 'Marks', 'id': 'marks', 'icon': Icons.grade},
      {'title': 'Remarks', 'id': 'remarks', 'icon': Icons.comment},
      {'title': 'Certificates', 'id': 'certificates', 'icon': Icons.card_membership},
      {'title': 'Job Opportunities', 'id': 'jobs', 'icon': Icons.work},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButton<String>(
        value: _selectedSection,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.menu, color: Color(0xFF667eea)),
        items: items.map((m) {
          return DropdownMenuItem<String>(
            value: m['id'] as String,
            child: Row(
              children: [
                Icon(m['icon'] as IconData, size: 18, color: const Color(0xFF667eea)),
                const SizedBox(width: 8),
                Text(m['title'] as String),
              ],
            ),
          );
        }).toList(),
        onChanged: (id) {
          debugPrint('StudentDashboard: dropdown changed to $id');
          if (id != null) _onSectionSelected(id);
        },
      ),
    );
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Notifications',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: DatabaseService.getNotifications(AuthService().currentUserId!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    'No notifications',
                    style: GoogleFonts.inter(),
                  ),
                );
              }

              final notifications = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true,
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return ListTile(
                    leading: Icon(
                      _getNotificationIcon(notification['type']),
                      color: const Color(0xFF667eea),
                    ),
                    title: Text(
                      notification['title'],
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      notification['body'],
                      style: GoogleFonts.inter(
                        fontSize: 12,
                      ),
                    ),
                    trailing: Text(
                      _formatDate(notification['createdAt']),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: GoogleFonts.inter(),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'attendance':
        return Icons.event_available;
      case 'marks':
        return Icons.grade;
      case 'remarks':
        return Icons.comment;
      case 'job':
        return Icons.work;
      default:
        return Icons.notifications;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  void _generateResume() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Generate Resume',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Do you want to generate and download your professional resume?',
          style: GoogleFonts.inter(),
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
            onPressed: () async {
              Navigator.of(context).pop();
              
              try {
                // Show loading indicator
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        const SizedBox(width: 16),
                        const Text('Generating resume...'),
                      ],
                    ),
                    duration: const Duration(seconds: 3),
                    backgroundColor: const Color(0xFF667eea),
                  ),
                );
                
                await ResumeService().generateResume(AuthService().currentUserId!);
                
                // Show success message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Resume generated successfully!'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              } catch (e) {
                // Show error message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error generating resume: ${e.toString()}'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
                debugPrint('Resume generation error: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Generate',
              style: GoogleFonts.inter(),
            ),
          ),
        ],
      ),
    );
  }

  void _showPasswordChangeDialog() {
    showDialog(
      context: context,
      builder: (context) => PasswordChangeDialog(
        onPasswordChanged: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Password changed successfully',
                style: GoogleFonts.inter(),
              ),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  // Calculate dynamic header height based on screen width
  double _calculateHeaderHeight(double screenWidth) {
    if (screenWidth < 400) {
      return 200.0; // Extra small screens
    } else if (screenWidth < 600) {
      return 180.0; // Small screens
    } else if (screenWidth < 800) {
      return 165.0; // Medium screens
    } else if (screenWidth < 1200) {
      return 140.0; // Large screens
    } else {
      return 125.0; // Extra large screens
    }
  }
}
