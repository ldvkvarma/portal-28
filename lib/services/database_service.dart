import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_database_service.dart';

class DatabaseService {
  static bool _useFirebase = true; // Always use Firebase

  // Initialize database
  static Future<void> initialize() async {
    if (_useFirebase) {
      await FirebaseDatabaseService.initialize();
    }
  }

  // Authentication Methods
  static Future<Map<String, dynamic>?> authenticateUser(String username, String password) async {
    if (_useFirebase) {
      return await FirebaseDatabaseService.authenticateUser(username, password);
    }
    return null;
  }

  static Future<bool> changePassword(String userId, String oldPassword, String newPassword) async {
    if (_useFirebase) {
      return await FirebaseDatabaseService.changePassword(userId, oldPassword, newPassword);
    }
    return false;
  }

  // Student Methods
  static Future<Map<String, dynamic>?> getStudent(String studentId) async {
    if (_useFirebase) {
      return await FirebaseDatabaseService.getStudent(studentId);
    }
    return null;
  }

  static Future<bool> updateStudent(String studentId, Map<String, dynamic> updates) async {
    if (_useFirebase) {
      return await FirebaseDatabaseService.updateStudent(studentId, updates);
    }
    return false;
  }

  // Faculty Methods
  static Future<Map<String, dynamic>?> getFaculty(String facultyId) async {
    if (_useFirebase) {
      return await FirebaseDatabaseService.getFaculty(facultyId);
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>> getAllFaculty() async {
    if (_useFirebase) {
      return await FirebaseDatabaseService.getAllFaculty();
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getAllStudents() async {
    if (_useFirebase) {
      return await FirebaseDatabaseService.getAllStudents();
    }
    return [];
  }

  // Attendance Methods
  static Future<List<Map<String, dynamic>>> getAttendance(String studentId) async {
    if (_useFirebase) {
      return await FirebaseDatabaseService.getAttendance(studentId);
    }
    return [];
  }

  static Future<bool> markAttendance(Map<String, dynamic> attendanceData) async {
    if (_useFirebase) {
      return await FirebaseDatabaseService.markAttendance(attendanceData);
    }
    return false;
  }

  // Marks Methods
  static Future<List<Map<String, dynamic>>> getMarks(String studentId) async {
    if (_useFirebase) {
      return await FirebaseDatabaseService.getMarks(studentId);
    }
    return [];
  }

  static Future<bool> addMarks(Map<String, dynamic> marksData) async {
    if (_useFirebase) {
      return await FirebaseDatabaseService.addMarks(marksData);
    }
    return false;
  }

  // Remarks Methods
  static Future<List<Map<String, dynamic>>> getRemarks(String studentId) async {
    if (_useFirebase) {
      return await FirebaseDatabaseService.getRemarks(studentId);
    }
    return [];
  }

  static Future<bool> addRemark(Map<String, dynamic> remarkData) async {
    if (_useFirebase) {
      return await FirebaseDatabaseService.addRemark(remarkData);
    }
    return false;
  }

  // Certificate Methods
  static Future<List<Map<String, dynamic>>> getCertificates(String studentId) async {
    if (_useFirebase) {
      return await FirebaseDatabaseService.getCertificates(studentId);
    }
    return [];
  }

  static Future<bool> addCertificate(String studentId, Map<String, dynamic> certificateData) async {
    if (_useFirebase) {
      return await FirebaseDatabaseService.addCertificate(studentId, certificateData);
    }
    return false;
  }

  // Job Methods
  static Future<List<Map<String, dynamic>>> getJobs() async {
    if (_useFirebase) {
      return await FirebaseDatabaseService.getJobs();
    }
    return [];
  }

  static Future<bool> addJob(Map<String, dynamic> jobData) async {
    if (_useFirebase) {
      return await FirebaseDatabaseService.addJob(jobData);
    }
    return false;
  }

  // Notification Methods
  static Future<List<Map<String, dynamic>>> getNotifications(String userId) async {
    if (_useFirebase) {
      return await FirebaseDatabaseService.getNotifications(userId);
    }
    return [];
  }

  static Future<bool> addNotification(Map<String, dynamic> notificationData) async {
    if (_useFirebase) {
      return await FirebaseDatabaseService.addNotification(notificationData);
    }
    return false;
  }

  // Principal Monitoring Methods
  static Future<Map<String, dynamic>> getPrincipalStats() async {
    if (_useFirebase) {
      return await FirebaseDatabaseService.getPrincipalStats();
    }
    return {};
  }

  // Clear all data
  static Future<void> clearAllData() async {
    if (_useFirebase) {
      await FirebaseDatabaseService.clearAllData();
    }
  }

  // Subjects Methods
  static Future<List<Map<String, dynamic>>> getSubjects() async {
    if (_useFirebase) {
      return await FirebaseDatabaseService.getSubjects();
    }
    return [];
  }

  static Future<bool> addSubject(Map<String, dynamic> subjectData) async {
    if (_useFirebase) {
      return await FirebaseDatabaseService.addSubject(subjectData);
    }
    return false;
  }

  // Timetable Methods
  static Future<List<Map<String, dynamic>>> getTimetable() async {
    if (_useFirebase) {
      return await FirebaseDatabaseService.getTimetable();
    }
    return [];
  }

  static Future<bool> updateTimetable(String timetableId, Map<String, dynamic> timetableData) async {
    if (_useFirebase) {
      return await FirebaseDatabaseService.updateTimetable(timetableId, timetableData);
    }
    return false;
  }

  static Future<bool> addTimetable(Map<String, dynamic> timetableData) async {
    if (_useFirebase) {
      return await FirebaseDatabaseService.addTimetable(timetableData);
    }
    return false;
  }

  // Internal Marks Methods
  static Future<List<Map<String, dynamic>>> getInternalMarks(String studentId) async {
    if (_useFirebase) {
      return await FirebaseDatabaseService.getInternalMarks(studentId);
    }
    return [];
  }

  static Future<bool> addInternalMarks(Map<String, dynamic> marksData) async {
    if (_useFirebase) {
      return await FirebaseDatabaseService.addInternalMarks(marksData);
    }
    return false;
  }

  static Future<bool> lockInternalMarks(String marksId) async {
    if (_useFirebase) {
      return await FirebaseDatabaseService.lockInternalMarks(marksId);
    }
    return false;
  }

  static Future<bool> updateInternalMarks(String marksId, Map<String, dynamic> updates) async {
    if (_useFirebase) {
      return await FirebaseDatabaseService.updateInternalMarks(marksId, updates);
    }
    return false;
  }

  // Faculty role check
  static Future<bool> isHod(String facultyId) async {
    final faculty = await getFaculty(facultyId);
    return faculty?['role'] == 'hod';
  }

  // Reset database
  static Future<void> resetDatabase() async {
    await clearAllData();
    await initialize();
  }

  // Force reset with new faculty data
  static Future<void> forceResetWithNewFaculty() async {
    await clearAllData();
    await initialize();
  }
}
