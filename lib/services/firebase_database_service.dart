import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseDatabaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Collection names
  static const String usersCollection = 'users';
  static const String studentsCollection = 'students';
  static const String facultyCollection = 'faculty';
  static const String attendanceCollection = 'attendance';
  static const String marksCollection = 'marks';
  static const String remarksCollection = 'remarks';
  static const String certificatesCollection = 'certificates';
  static const String jobsCollection = 'jobs';
  static const String notificationsCollection = 'notifications';
  static const String subjectsCollection = 'subjects';
  static const String timetableCollection = 'timetable';
  static const String internalMarksCollection = 'internalMarks';

  // Initialize Firebase - no demo data for security
  static Future<void> initialize() async {
    // Demo data removed for security
    // Use Firebase Console to add data manually
    print('Firebase: Initialized securely - no demo data');
  }

  // Authentication Methods
  static Future<Map<String, dynamic>?> authenticateUser(String username, String password) async {
    try {
      final querySnapshot = await _firestore
          .collection(usersCollection)
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: password)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      }
      return null;
    } catch (e) {
      print('Firebase auth error: $e');
      return null;
    }
  }

  static Future<bool> changePassword(String userId, String oldPassword, String newPassword) async {
    try {
      final userDoc = await _firestore.collection(usersCollection).doc(userId).get();
      if (userDoc.exists && userDoc.data()?['password'] == oldPassword) {
        await userDoc.reference.update({
          'password': newPassword,
          'updatedAt': Timestamp.now(),
        });
        return true;
      }
      return false;
    } catch (e) {
      print('Firebase password change error: $e');
      return false;
    }
  }

  // Student Methods
  static Future<Map<String, dynamic>?> getStudent(String studentId) async {
    try {
      final doc = await _firestore.collection(studentsCollection).doc(studentId).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('Firebase get student error: $e');
      return null;
    }
  }

  static Future<bool> updateStudent(String studentId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = Timestamp.now();
      await _firestore.collection(studentsCollection).doc(studentId).update(updates);
      return true;
    } catch (e) {
      print('Firebase update student error: $e');
      return false;
    }
  }

  // Faculty Methods
  static Future<Map<String, dynamic>?> getFaculty(String facultyId) async {
    try {
      final doc = await _firestore.collection(facultyCollection).doc(facultyId).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('Firebase get faculty error: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getAllFaculty() async {
    try {
      final querySnapshot = await _firestore
          .collection(facultyCollection)
          .where('isActive', isEqualTo: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => doc.data())
          .toList();
    } catch (e) {
      print('Firebase get all faculty error: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getAllStudents() async {
    try {
      final querySnapshot = await _firestore.collection(studentsCollection).get();
      
      return querySnapshot.docs
          .map((doc) => doc.data())
          .toList();
    } catch (e) {
      print('Firebase get all students error: $e');
      return [];
    }
  }

  // Attendance Methods
  static Future<List<Map<String, dynamic>>> getAttendance(String studentId) async {
    try {
      final querySnapshot = await _firestore
          .collection(attendanceCollection)
          .where('studentId', isEqualTo: studentId)
          .get();
      
      return querySnapshot.docs
          .map((doc) => doc.data())
          .toList();
    } catch (e) {
      print('Firebase get attendance error: $e');
      return [];
    }
  }

  static Future<bool> markAttendance(Map<String, dynamic> attendanceData) async {
    try {
      attendanceData['createdAt'] = Timestamp.now();
      await _firestore.collection(attendanceCollection).add(attendanceData);
      return true;
    } catch (e) {
      print('Firebase mark attendance error: $e');
      return false;
    }
  }

  // Marks Methods
  static Future<List<Map<String, dynamic>>> getMarks(String studentId) async {
    try {
      final querySnapshot = await _firestore
          .collection(marksCollection)
          .where('studentId', isEqualTo: studentId)
          .get();
      
      return querySnapshot.docs
          .map((doc) => doc.data())
          .toList();
    } catch (e) {
      print('Firebase get marks error: $e');
      return [];
    }
  }

  static Future<bool> addMarks(Map<String, dynamic> marksData) async {
    try {
      marksData['createdAt'] = Timestamp.now();
      await _firestore.collection(marksCollection).add(marksData);
      return true;
    } catch (e) {
      print('Firebase add marks error: $e');
      return false;
    }
  }

  // Remarks Methods
  static Future<List<Map<String, dynamic>>> getRemarks(String studentId) async {
    try {
      final querySnapshot = await _firestore
          .collection(remarksCollection)
          .where('studentId', isEqualTo: studentId)
          .get();
      
      return querySnapshot.docs
          .map((doc) => doc.data())
          .toList();
    } catch (e) {
      print('Firebase get remarks error: $e');
      return [];
    }
  }

  static Future<bool> addRemark(Map<String, dynamic> remarkData) async {
    try {
      remarkData['createdAt'] = Timestamp.now();
      await _firestore.collection(remarksCollection).add(remarkData);
      return true;
    } catch (e) {
      print('Firebase add remark error: $e');
      return false;
    }
  }

  // Certificate Methods
  static Future<List<Map<String, dynamic>>> getCertificates(String studentId) async {
    try {
      final querySnapshot = await _firestore
          .collection(certificatesCollection)
          .where('studentId', isEqualTo: studentId)
          .get();
      
      return querySnapshot.docs
          .map((doc) => doc.data())
          .toList();
    } catch (e) {
      print('Firebase get certificates error: $e');
      return [];
    }
  }

  static Future<bool> addCertificate(String studentId, Map<String, dynamic> certificateData) async {
    try {
      certificateData['studentId'] = studentId;
      certificateData['createdAt'] = Timestamp.now();
      await _firestore.collection(certificatesCollection).add(certificateData);
      return true;
    } catch (e) {
      print('Firebase add certificate error: $e');
      return false;
    }
  }

  // Job Methods
  static Future<List<Map<String, dynamic>>> getJobs() async {
    try {
      final querySnapshot = await _firestore
          .collection(jobsCollection)
          .where('isActive', isEqualTo: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => doc.data())
          .toList();
    } catch (e) {
      print('Firebase get jobs error: $e');
      return [];
    }
  }

  static Future<bool> addJob(Map<String, dynamic> jobData) async {
    try {
      jobData['createdAt'] = Timestamp.now();
      await _firestore.collection(jobsCollection).add(jobData);
      return true;
    } catch (e) {
      print('Firebase add job error: $e');
      return false;
    }
  }

  // Notification Methods
  static Future<List<Map<String, dynamic>>> getNotifications(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(notificationsCollection)
          .where('userId', isEqualTo: userId)
          .get();
      
      return querySnapshot.docs
          .map((doc) => doc.data())
          .toList();
    } catch (e) {
      print('Firebase get notifications error: $e');
      return [];
    }
  }

  static Future<bool> addNotification(Map<String, dynamic> notificationData) async {
    try {
      notificationData['createdAt'] = Timestamp.now();
      await _firestore.collection(notificationsCollection).add(notificationData);
      return true;
    } catch (e) {
      print('Firebase add notification error: $e');
      return false;
    }
  }

  // Principal Monitoring Methods
  static Future<Map<String, dynamic>> getPrincipalStats() async {
    try {
      final studentsSnapshot = await _firestore.collection(studentsCollection).get();
      final facultySnapshot = await _firestore.collection(facultyCollection).get();
      final attendanceSnapshot = await _firestore.collection(attendanceCollection).get();
      final marksSnapshot = await _firestore.collection(marksCollection).get();
      
      return {
        'totalStudents': studentsSnapshot.docs.length,
        'totalFaculty': facultySnapshot.docs.where((doc) => doc.data()['isActive'] == true).length,
        'todayAttendance': attendanceSnapshot.docs
            .where((doc) => doc.data()['date'] == DateTime.now().toString().split(' ')[0])
            .length,
        'totalMarks': marksSnapshot.docs.length,
        'activeFaculty': facultySnapshot.docs
            .where((doc) => doc.data()['isActive'] == true)
            .length,
      };
    } catch (e) {
      print('Firebase get principal stats error: $e');
      return {};
    }
  }

  // Clear all data
  static Future<void> clearAllData() async {
    try {
      final collections = [
        usersCollection,
        studentsCollection,
        facultyCollection,
        attendanceCollection,
        marksCollection,
        remarksCollection,
        certificatesCollection,
        jobsCollection,
        notificationsCollection,
        subjectsCollection,
        timetableCollection,
        internalMarksCollection,
      ];
      
      for (final collection in collections) {
        final querySnapshot = await _firestore.collection(collection).get();
        for (final doc in querySnapshot.docs) {
          await doc.reference.delete();
        }
      }
      print('Firebase: All data cleared');
    } catch (e) {
      print('Firebase clear data error: $e');
    }
  }

  // Subjects Methods
  static Future<List<Map<String, dynamic>>> getSubjects() async {
    try {
      final querySnapshot = await _firestore
          .collection(subjectsCollection)
          .where('isActive', isEqualTo: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => doc.data())
          .toList();
    } catch (e) {
      print('Firebase get subjects error: $e');
      return [];
    }
  }

  static Future<bool> addSubject(Map<String, dynamic> subjectData) async {
    try {
      subjectData['createdAt'] = Timestamp.now();
      await _firestore.collection(subjectsCollection).add(subjectData);
      return true;
    } catch (e) {
      print('Firebase add subject error: $e');
      return false;
    }
  }

  // Timetable Methods
  static Future<List<Map<String, dynamic>>> getTimetable() async {
    try {
      final querySnapshot = await _firestore.collection(timetableCollection).get();
      
      return querySnapshot.docs
          .map((doc) => doc.data())
          .toList();
    } catch (e) {
      print('Firebase get timetable error: $e');
      return [];
    }
  }

  static Future<bool> updateTimetable(String timetableId, Map<String, dynamic> timetableData) async {
    try {
      timetableData['updatedAt'] = Timestamp.now();
      await _firestore.collection(timetableCollection).doc(timetableId).update(timetableData);
      return true;
    } catch (e) {
      print('Firebase update timetable error: $e');
      return false;
    }
  }

  static Future<bool> addTimetable(Map<String, dynamic> timetableData) async {
    try {
      timetableData['createdAt'] = Timestamp.now();
      await _firestore.collection(timetableCollection).add(timetableData);
      return true;
    } catch (e) {
      print('Firebase add timetable error: $e');
      return false;
    }
  }

  // Internal Marks Methods
  static Future<List<Map<String, dynamic>>> getInternalMarks(String studentId) async {
    try {
      final querySnapshot = await _firestore
          .collection(internalMarksCollection)
          .where('studentId', isEqualTo: studentId)
          .get();
      
      return querySnapshot.docs
          .map((doc) => doc.data())
          .toList();
    } catch (e) {
      print('Firebase get internal marks error: $e');
      return [];
    }
  }

  static Future<bool> addInternalMarks(Map<String, dynamic> marksData) async {
    try {
      marksData['createdAt'] = Timestamp.now();
      await _firestore.collection(internalMarksCollection).add(marksData);
      return true;
    } catch (e) {
      print('Firebase add internal marks error: $e');
      return false;
    }
  }

  static Future<bool> lockInternalMarks(String marksId) async {
    try {
      await _firestore.collection(internalMarksCollection).doc(marksId).update({
        'isLocked': true,
        'updatedAt': Timestamp.now(),
      });
      return true;
    } catch (e) {
      print('Firebase lock internal marks error: $e');
      return false;
    }
  }

  static Future<bool> updateInternalMarks(String marksId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = Timestamp.now();
      await _firestore.collection(internalMarksCollection).doc(marksId).update(updates);
      return true;
    } catch (e) {
      print('Firebase update internal marks error: $e');
      return false;
    }
  }
}
