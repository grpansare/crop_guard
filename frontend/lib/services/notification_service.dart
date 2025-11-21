import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  List<NotificationModel> _notificationsList = [];

  // Notification types
  static const String diseaseAlert = 'disease_alert';
  static const String expertResponse = 'expert_response';
  static const String caseReview = 'case_review';
  static const String trendAlert = 'trend_alert';
  static const String systemUpdate = 'system_update';
  static const String reminder = 'reminder';

  // Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone
      tz.initializeTimeZones();

      // Android initialization settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      // Combined initialization settings
      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize the plugin
      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Request permissions
      await _requestPermissions();

      // Load saved notifications
      await _loadNotifications();

      _isInitialized = true;
      debugPrint('Notification service initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize notification service: $e');
    }
  }

  // Request notification permissions
  Future<void> _requestPermissions() async {
    try {
      await _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();

      await _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (e) {
      debugPrint('Failed to request permissions: $e');
    }
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    try {
      final payload = response.payload;
      if (payload != null) {
        final data = jsonDecode(payload);
        _handleNotificationAction(data);
      }
    } catch (e) {
      debugPrint('Error handling notification tap: $e');
    }
  }

  // Handle notification action
  void _handleNotificationAction(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final id = data['id'] as String?;

    switch (type) {
      case diseaseAlert:
        // Navigate to disease details
        debugPrint('Opening disease alert: $id');
        break;
      case expertResponse:
        // Navigate to expert response
        debugPrint('Opening expert response: $id');
        break;
      case caseReview:
        // Navigate to case review
        debugPrint('Opening case review: $id');
        break;
      case trendAlert:
        // Navigate to trends
        debugPrint('Opening trend alert: $id');
        break;
      default:
        debugPrint('Unknown notification type: $type');
    }
  }

  // Show immediate notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? type,
    String? id,
    Map<String, dynamic>? data,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Create notification model
      final notification = NotificationModel(
        id: id ?? notificationId.toString(),
        title: title,
        body: body,
        type: type ?? 'general',
        timestamp: DateTime.now(),
        isRead: false,
        data: data ?? {},
      );

      // Add to list
      _notificationsList.insert(0, notification);
      await _saveNotifications();

      // Android notification details
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'crop_disease_channel',
            'Crop Disease Notifications',
            channelDescription: 'Notifications for crop disease detection app',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
            playSound: true,
          );

      // iOS notification details
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      // Combined notification details
      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Show notification
      await _notifications.show(
        notificationId,
        title,
        body,
        details,
        payload: jsonEncode({'type': type, 'id': id, 'data': data}),
      );

      debugPrint('Notification shown: $title');
    } catch (e) {
      debugPrint('Failed to show notification: $e');
    }
  }

  // Schedule notification
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? type,
    String? id,
    Map<String, dynamic>? data,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Android notification details
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'crop_disease_scheduled',
            'Scheduled Crop Disease Notifications',
            channelDescription:
                'Scheduled notifications for crop disease detection app',
            importance: Importance.high,
            priority: Priority.high,
          );

      // iOS notification details
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      // Combined notification details
      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Schedule notification
      await _notifications.zonedSchedule(
        notificationId,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        details,
        payload: jsonEncode({'type': type, 'id': id, 'data': data}),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      debugPrint('Notification scheduled: $title at $scheduledDate');
    } catch (e) {
      debugPrint('Failed to schedule notification: $e');
    }
  }

  // Show disease alert notification
  Future<void> showDiseaseAlert({
    required String diseaseName,
    required String severity,
    required String location,
    String? cropType,
  }) async {
    await showNotification(
      title: '🚨 Disease Alert',
      body: '$diseaseName detected in $location (Severity: $severity)',
      type: diseaseAlert,
      data: {
        'diseaseName': diseaseName,
        'severity': severity,
        'location': location,
        'cropType': cropType,
      },
    );
  }

  // Show expert response notification
  Future<void> showExpertResponse({
    required String expertName,
    required String queryId,
    required String response,
  }) async {
    await showNotification(
      title: '👨‍⚕️ Expert Response',
      body: '$expertName responded to your query',
      type: expertResponse,
      id: queryId,
      data: {
        'expertName': expertName,
        'queryId': queryId,
        'response': response,
      },
    );
  }

  // Show case review notification
  Future<void> showCaseReview({
    required String caseId,
    required String farmerName,
    required String diseaseName,
  }) async {
    await showNotification(
      title: '📋 Case Review Required',
      body: 'Review case for $farmerName - $diseaseName',
      type: caseReview,
      id: caseId,
      data: {
        'caseId': caseId,
        'farmerName': farmerName,
        'diseaseName': diseaseName,
      },
    );
  }

  // Show trend alert notification
  Future<void> showTrendAlert({
    required String trendType,
    required String description,
    required String riskLevel,
  }) async {
    await showNotification(
      title: '📈 Trend Alert',
      body: '$trendType: $description (Risk: $riskLevel)',
      type: trendAlert,
      data: {
        'trendType': trendType,
        'description': description,
        'riskLevel': riskLevel,
      },
    );
  }

  // Show reminder notification
  Future<void> showReminder({
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await scheduleNotification(
      title: '⏰ Reminder: $title',
      body: body,
      scheduledDate: scheduledDate,
      type: reminder,
    );
  }

  // Get all notifications
  List<NotificationModel> getNotifications() {
    return List.unmodifiable(_notificationsList);
  }

  // Get unread notifications count
  int getUnreadCount() {
    return _notificationsList.where((n) => !n.isRead).length;
  }

  // Mark notification as read
  Future<void> markAsRead(String id) async {
    try {
      final index = _notificationsList.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notificationsList[index] = _notificationsList[index].copyWith(
          isRead: true,
        );
        await _saveNotifications();
      }
    } catch (e) {
      debugPrint('Failed to mark notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      for (int i = 0; i < _notificationsList.length; i++) {
        _notificationsList[i] = _notificationsList[i].copyWith(isRead: true);
      }
      await _saveNotifications();
    } catch (e) {
      debugPrint('Failed to mark all notifications as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String id) async {
    try {
      _notificationsList.removeWhere((n) => n.id == id);
      await _saveNotifications();
    } catch (e) {
      debugPrint('Failed to delete notification: $e');
    }
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      _notificationsList.clear();
      await _saveNotifications();
      await _notifications.cancelAll();
    } catch (e) {
      debugPrint('Failed to clear all notifications: $e');
    }
  }

  // Cancel scheduled notification
  Future<void> cancelScheduledNotification(int id) async {
    try {
      await _notifications.cancel(id);
    } catch (e) {
      debugPrint('Failed to cancel scheduled notification: $e');
    }
  }

  // Cancel all scheduled notifications
  Future<void> cancelAllScheduledNotifications() async {
    try {
      await _notifications.cancelAll();
    } catch (e) {
      debugPrint('Failed to cancel all scheduled notifications: $e');
    }
  }

  // Load notifications from storage
  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString('notifications_list');

      if (notificationsJson != null) {
        final List<dynamic> notificationsData = jsonDecode(notificationsJson);
        _notificationsList = notificationsData
            .map((data) => NotificationModel.fromJson(data))
            .toList();
      }
    } catch (e) {
      debugPrint('Failed to load notifications: $e');
      _notificationsList = [];
    }
  }

  // Save notifications to storage
  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = jsonEncode(
        _notificationsList.map((n) => n.toJson()).toList(),
      );
      await prefs.setString('notifications_list', notificationsJson);
    } catch (e) {
      debugPrint('Failed to save notifications: $e');
    }
  }

  // Get notification settings
  Future<Map<String, bool>> getNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'diseaseAlerts': prefs.getBool('notify_disease_alerts') ?? true,
        'expertResponses': prefs.getBool('notify_expert_responses') ?? true,
        'caseReviews': prefs.getBool('notify_case_reviews') ?? true,
        'trendAlerts': prefs.getBool('notify_trend_alerts') ?? true,
        'systemUpdates': prefs.getBool('notify_system_updates') ?? true,
        'reminders': prefs.getBool('notify_reminders') ?? true,
      };
    } catch (e) {
      debugPrint('Failed to get notification settings: $e');
      return {
        'diseaseAlerts': true,
        'expertResponses': true,
        'caseReviews': true,
        'trendAlerts': true,
        'systemUpdates': true,
        'reminders': true,
      };
    }
  }

  // Update notification settings
  Future<void> updateNotificationSettings(Map<String, bool> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final entry in settings.entries) {
        await prefs.setBool('notify_${entry.key}', entry.value);
      }
    } catch (e) {
      debugPrint('Failed to update notification settings: $e');
    }
  }

  // Check if notification type is enabled
  Future<bool> isNotificationTypeEnabled(String type) async {
    try {
      final settings = await getNotificationSettings();
      switch (type) {
        case diseaseAlert:
          return settings['diseaseAlerts'] ?? true;
        case expertResponse:
          return settings['expertResponses'] ?? true;
        case caseReview:
          return settings['caseReviews'] ?? true;
        case trendAlert:
          return settings['trendAlerts'] ?? true;
        case systemUpdate:
          return settings['systemUpdates'] ?? true;
        case reminder:
          return settings['reminders'] ?? true;
        default:
          return true;
      }
    } catch (e) {
      debugPrint('Failed to check notification type: $e');
      return true;
    }
  }
}

// Notification model class
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic> data;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    required this.isRead,
    required this.data,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'data': data,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      type: json['type'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'],
      data: Map<String, dynamic>.from(json['data']),
    );
  }
}
