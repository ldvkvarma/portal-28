import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'database_service.dart';

class ResumeService {
  static final ResumeService _instance = ResumeService._internal();
  factory ResumeService() => _instance;
  ResumeService._internal();

  // Generate resume for student
  Future<void> generateResume(String studentId) async {
    final student = await DatabaseService.getStudent(studentId);
    final certificates = await DatabaseService.getCertificates(studentId);
    
    if (student == null) {
      debugPrint('Student not found');
      return;
    }

    final pdf = pw.Document();
    
    // Add a page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(student),
              pw.SizedBox(height: 20),
              
              // Education
              _buildEducationSection(student),
              pw.SizedBox(height: 20),
              
              // Skills
              _buildSkillsSection(student, certificates),
              pw.SizedBox(height: 20),
              
              // Experience/Certificates
              _buildExperienceSection(certificates),
              pw.SizedBox(height: 20),
              
              // Projects
              _buildProjectsSection(student),
              pw.SizedBox(height: 20),
              
              // Contact
              _buildContactSection(student),
            ],
          );
        },
      ),
    );

    // Save and print
    await _saveAndPrintPDF(pdf, 'resume_${student['admissionNo']}.pdf');
  }

  pw.Widget _buildHeader(Map<String, dynamic> student) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [
            PdfColor.fromHex('#667eea'),
            PdfColor.fromHex('#764ba2'),
          ],
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            student['name'] ?? 'Student Name',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            '${student['course'] ?? 'B.Tech'} - ${student['branch'] ?? 'CSE'}',
            style: pw.TextStyle(
              fontSize: 16,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'CGPA: ${student['cgpa'] ?? 'N/A'} | ${student['semester'] ?? 'VI'} Semester',
            style: pw.TextStyle(
              fontSize: 14,
              color: PdfColors.white,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildEducationSection(Map<String, dynamic> student) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'EDUCATION',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#667eea'),
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'College of Engineering',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                '${student['course'] ?? 'B.Tech'} in ${student['branch'] ?? 'Computer Science'}',
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.Text(
                'Batch: ${student['batch'] ?? '2023-2027'}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                'CGPA: ${student['cgpa'] ?? 'N/A'}',
                style: const pw.TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildSkillsSection(Map<String, dynamic> student, List<Map<String, dynamic>> certificates) {
    // Extract skills from certificates and add common skills
    final skills = <String>{
      'Programming Languages: Python, Java, C++',
      'Web Technologies: HTML, CSS, JavaScript, React',
      'Database: SQL, MongoDB',
      'Tools: Git, VS Code, Android Studio',
    };

    // Add skills from certificates
    for (final cert in certificates) {
      if (cert['description'] != null) {
        final description = cert['description'].toString().toLowerCase();
        if (description.contains('python')) skills.add('Python');
        if (description.contains('java')) skills.add('Java');
        if (description.contains('machine learning')) skills.add('Machine Learning');
        if (description.contains('web')) skills.add('Web Development');
      }
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'TECHNICAL SKILLS',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#667eea'),
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: skills.map((skill) => pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 2),
              child: pw.Text(
                '• $skill',
                style: const pw.TextStyle(fontSize: 12),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildExperienceSection(List<Map<String, dynamic>> certificates) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'EXPERIENCE & CERTIFICATIONS',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#667eea'),
          ),
        ),
        pw.SizedBox(height: 10),
        ...certificates.map((cert) => pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 10),
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                cert['title'] ?? 'Certificate',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                cert['organization'] ?? 'Organization',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                '${cert['startDate'] ?? 'N/A'} - ${cert['endDate'] ?? 'N/A'}',
                style: const pw.TextStyle(fontSize: 10),
              ),
              if (cert['description'] != null) ...[
                pw.SizedBox(height: 5),
                pw.Text(
                  cert['description'], 
                  style: const pw.TextStyle(fontSize: 11),
                ),
              ],
            ],
          ),
        )),

      ],
    );
  }

  pw.Widget _buildProjectsSection(Map<String, dynamic> student) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'ACADEMIC PROJECTS',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#667eea'),
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'College Management System',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                '• Developed a comprehensive college management system using Flutter and Firebase',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                '• Implemented features for attendance tracking, marks management, and notifications',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                '• Technologies: Flutter, Dart, Firebase, SQLite',
                style: const pw.TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildContactSection(Map<String, dynamic> student) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'CONTACT INFORMATION',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#667eea'),
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '📧 ${student['email'] ?? 'student@college.edu'}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                '📱 ${student['phone'] ?? '+91 XXXXX XXXXX'}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                '📍 ${student['address'] ?? 'College Address'}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                '🔗 LinkedIn: linkedin.com/in/student',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                '🔗 GitHub: github.com/student',
                style: const pw.TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _saveAndPrintPDF(pw.Document pdf, String fileName) async {
    try {
      // Check if context is available
      if (!kDebugMode) {
        // Show loading indicator
        debugPrint('Starting PDF generation for: $fileName');
      }
      
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async {
          try {
            return await pdf.save();
          } catch (e) {
            debugPrint('Error saving PDF: $e');
            throw Exception('Failed to save PDF: $e');
          }
        },
        name: fileName,
      );
      
      debugPrint('Resume generated successfully: $fileName');
      
      // Show success message if possible
      // Note: In a real app, you'd want to show a snackbar or dialog
      // but since this is a service, we'll just log it
      
    } catch (e) {
      debugPrint('Error generating resume: $e');
      // Re-throw with more descriptive message
      throw Exception('Failed to generate resume: $e');
    }
  }

  // Get resume preview data
  Future<Map<String, dynamic>> getResumePreview(String studentId) async {
    final student = await DatabaseService.getStudent(studentId);
    final certificates = await DatabaseService.getCertificates(studentId);
    
    if (student == null) return {};
    
    return {
      'student': student,
      'certificates': certificates,
      'totalCertificates': certificates.length,
      'hasInternship': certificates.any((c) => c['type'] == 'internship'),
      'hasHackathon': certificates.any((c) => c['type'] == 'hackathon'),
      'hasWorkshop': certificates.any((c) => c['type'] == 'workshop'),
    };
  }
}
