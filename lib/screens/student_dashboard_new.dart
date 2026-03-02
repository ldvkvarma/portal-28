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
    // ignore: avoid_print
    print('StudentDashboardNew: _loadStudentData returned $data');
    if (data == null) {
      // debugging information
      // ignore: avoid_print
      print('StudentDashboardNew: currentUserData is null');
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
    // ignore: avoid_print
    print('StudentDashboardNew: section selected $section');
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
    return [
      // Notifications
      Stack(
        children: [
          IconButton(
            onPressed: () {
              _showNotifications();
            },
            icon: const Icon(
              Icons.notifications,
              color: Colors.white,
            ),
          ),
          if (_unreadNotifications > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  '$_unreadNotifications',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      
      // Resume Download
      IconButton(
        onPressed: () {
          _generateResume();
        },
        icon: const Icon(
          Icons.download,
          color: Colors.white,
        ),
        tooltip: 'Download Resume',
      ),
      
      // Password Change
      IconButton(
        onPressed: () {
          _showPasswordChangeDialog();
        },
        icon: const Icon(
          Icons.lock,
          color: Colors.white,
        ),
        tooltip: 'Change Password',
      ),
      
      // Logout
      TextButton(
        onPressed: _logout,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Logout',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // determine layout based on width
    final isSmall = MediaQuery.of(context).size.width < 800;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF667eea).withOpacity(0.1),
              const Color(0xFF764ba2).withOpacity(0.1),
            ],
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  child: isSmall ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Student info
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _studentName,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Student Dashboard',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      // Actions below for small screens
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.max,
                        children: _buildHeaderActions(),
                      ),
                    ],
                  ) : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Student info
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _studentName,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Student Dashboard',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                      // Actions to the right for large screens
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: _buildHeaderActions(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // optional dropdown for small screens
            if (isSmall)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: _buildMenuDropdown(),
              ),

            // Main Content - restructure so layout works inside a Column (no scrolling parent)
            Expanded(
              child: isSmall
                  ? Column(
                      children: [
                        // for small layout we already display dropdown above
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(20),
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
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
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
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
                            margin: const EdgeInsets.all(20),
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
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
              : const Color(0xFF667eea).withOpacity(0.1),
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


  // dropdown builder for small screens
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
            color: Colors.black.withOpacity(0.1),
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
          // ignore: avoid_print
          print('StudentDashboardNew: dropdown changed to $id');
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
            onPressed: () {
              Navigator.of(context).pop();
              ResumeService().generateResume(AuthService().currentUserId!);
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
}
