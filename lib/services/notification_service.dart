import 'package:flutter/material.dart';
import 'database_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> initialize() async {
    debugPrint('NotificationService initialized');
  }

  // Send notification to specific user
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    String type = 'general',
    Map<String, dynamic>? data,
  }) async {
    final notification = {
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'data': data ?? {},
    };
    
    await DatabaseService.addNotification(notification);
    debugPrint('Notification sent to $userId: $title - $body');
  }

  // Send notification to all users of a specific type
  Future<void> broadcastNotification({
    required String userType,
    required String title,
    required String body,
    String type = 'general',
    Map<String, dynamic>? data,
  }) async {
    final notification = {
      'userType': userType,
      'title': title,
      'body': body,
      'type': type,
      'data': data ?? {},
    };
    
    await DatabaseService.addNotification(notification);
    debugPrint('Broadcast notification sent to $userType: $title - $body');
  }

  // Attendance notification
  Future<void> sendAttendanceNotification({
    required String studentId,
    required String subject,
    required String date,
    required String status,
  }) async {
    await sendNotification(
      userId: studentId,
      title: 'Attendance Updated',
      body: 'Your attendance for $subject on $date is marked as $status',
      type: 'attendance',
      data: {'subject': subject, 'date': date, 'status': status},
    );
  }

  // Marks notification
  Future<void> sendMarksNotification({
    required String studentId,
    required String subject,
    required String marks,
    required String examType,
  }) async {
    await sendNotification(
      userId: studentId,
      title: 'Marks Posted',
      body: '$examType marks for $subject: $marks',
      type: 'marks',
      data: {'subject': subject, 'marks': marks, 'examType': examType},
    );
  }

  // Remarks notification
  Future<void> sendRemarksNotification({
    required String studentId,
    required String subject,
    required String remark,
    required String remarkType,
  }) async {
    await sendNotification(
      userId: studentId,
      title: 'New Remark Added',
      body: '$remarkType remark for $subject: $remark',
      type: 'remarks',
      data: {'subject': subject, 'remark': remark, 'remarkType': remarkType},
    );
  }

  // Job notification
  Future<void> sendJobNotification({
    required List<String> studentIds,
    required String jobTitle,
    required String company,
  }) async {
    for (final studentId in studentIds) {
      await sendNotification(
        userId: studentId,
        title: 'New Job Opportunity',
        body: '$jobTitle at $company matches your profile',
        type: 'job',
        data: {'jobTitle': jobTitle, 'company': company},
      );
    }
  }

  // General notification
  Future<void> sendGeneralNotification({
    required String userId,
    required String title,
    required String body,
  }) async {
    await sendNotification(
      userId: userId,
      title: title,
      body: body,
      type: 'general',
    );
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    // In a real app, you would update the notification in the database
    debugPrint('Notification $notificationId marked as read');
  }

  // Get unread notification count
  Future<int> getUnreadCount(String userId) async {
    final notifications = await DatabaseService.getNotifications(userId);
    return notifications.where((n) => n['isRead'] == false).length;
  }
}
