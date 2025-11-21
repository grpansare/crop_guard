import 'package:flutter/material.dart';
import 'package:crop_disease_app/services/notification_service.dart';

class NotificationWidget extends StatefulWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const NotificationWidget({
    super.key,
    required this.notification,
    this.onTap,
    this.onDelete,
  });

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  @override
  Widget build(BuildContext context) {
    final notification = widget.notification;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: notification.isRead ? 1 : 3,
      color: notification.isRead
          ? theme.cardColor
          : theme.primaryColor.withOpacity(0.1),
      child: ListTile(
        leading: _buildNotificationIcon(notification.type),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead
                ? FontWeight.normal
                : FontWeight.bold,
            color: notification.isRead ? null : theme.primaryColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: notification.isRead
                    ? theme.textTheme.bodyMedium?.color?.withOpacity(0.7)
                    : theme.textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(notification.timestamp),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'mark_read':
                if (!notification.isRead) {
                  NotificationService().markAsRead(notification.id);
                }
                break;
              case 'delete':
                widget.onDelete?.call();
                break;
            }
          },
          itemBuilder: (context) => [
            if (!notification.isRead)
              const PopupMenuItem(
                value: 'mark_read',
                child: Row(
                  children: [
                    Icon(Icons.check, size: 18),
                    SizedBox(width: 8),
                    Text('Mark as Read'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          if (!notification.isRead) {
            NotificationService().markAsRead(notification.id);
          }
          widget.onTap?.call();
        },
      ),
    );
  }

  Widget _buildNotificationIcon(String type) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case NotificationService.diseaseAlert:
        iconData = Icons.warning;
        iconColor = Colors.red;
        break;
      case NotificationService.expertResponse:
        iconData = Icons.person;
        iconColor = Colors.blue;
        break;
      case NotificationService.caseReview:
        iconData = Icons.assignment;
        iconColor = Colors.orange;
        break;
      case NotificationService.trendAlert:
        iconData = Icons.trending_up;
        iconColor = Colors.purple;
        break;
      case NotificationService.systemUpdate:
        iconData = Icons.system_update;
        iconColor = Colors.green;
        break;
      case NotificationService.reminder:
        iconData = Icons.alarm;
        iconColor = Colors.teal;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  final NotificationService _notificationService = NotificationService();
  List<NotificationModel> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    setState(() {
      _notifications = _notificationService.getNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unreadCount = _notificationService.getUnreadCount();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unreadCount > 0)
            IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.mark_email_read),
                  Positioned(
                    right: 0,
                    top: 0,
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
                        '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: () async {
                await _notificationService.markAllAsRead();
                _loadNotifications();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All notifications marked as read'),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear All Notifications'),
                  content: const Text(
                    'Are you sure you want to clear all notifications?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await _notificationService.clearAllNotifications();
                _loadNotifications();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All notifications cleared')),
                );
              }
            },
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: theme.textTheme.bodyLarge?.color?.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.textTheme.bodyLarge?.color?.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You\'ll see notifications here when they arrive',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyLarge?.color?.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                _loadNotifications();
              },
              child: ListView.builder(
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return NotificationWidget(
                    notification: notification,
                    onTap: () {
                      // Handle notification tap
                      _handleNotificationTap(notification);
                    },
                    onDelete: () async {
                      await _notificationService.deleteNotification(
                        notification.id,
                      );
                      _loadNotifications();
                    },
                  );
                },
              ),
            ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Handle different notification types
    switch (notification.type) {
      case NotificationService.diseaseAlert:
        // Navigate to disease details
        break;
      case NotificationService.expertResponse:
        // Navigate to expert response
        break;
      case NotificationService.caseReview:
        // Navigate to case review
        break;
      case NotificationService.trendAlert:
        // Navigate to trends
        break;
      default:
        // Default action
        break;
    }
  }
}

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  Map<String, bool> _settings = {};

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _notificationService.getNotificationSettings();
    setState(() {
      _settings = settings;
    });
  }

  Future<void> _updateSetting(String key, bool value) async {
    setState(() {
      _settings[key] = value;
    });

    await _notificationService.updateNotificationSettings({key: value});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_getSettingName(key)} ${value ? 'enabled' : 'disabled'}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getSettingName(String key) {
    switch (key) {
      case 'diseaseAlerts':
        return 'Disease alerts';
      case 'expertResponses':
        return 'Expert responses';
      case 'caseReviews':
        return 'Case reviews';
      case 'trendAlerts':
        return 'Trend alerts';
      case 'systemUpdates':
        return 'System updates';
      case 'reminders':
        return 'Reminders';
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Disease Alerts'),
            subtitle: const Text('Get notified about disease outbreaks'),
            value: _settings['diseaseAlerts'] ?? true,
            onChanged: (value) => _updateSetting('diseaseAlerts', value),
          ),
          SwitchListTile(
            title: const Text('Expert Responses'),
            subtitle: const Text(
              'Get notified when experts respond to your queries',
            ),
            value: _settings['expertResponses'] ?? true,
            onChanged: (value) => _updateSetting('expertResponses', value),
          ),
          SwitchListTile(
            title: const Text('Case Reviews'),
            subtitle: const Text('Get notified about case review requests'),
            value: _settings['caseReviews'] ?? true,
            onChanged: (value) => _updateSetting('caseReviews', value),
          ),
          SwitchListTile(
            title: const Text('Trend Alerts'),
            subtitle: const Text(
              'Get notified about disease trends and patterns',
            ),
            value: _settings['trendAlerts'] ?? true,
            onChanged: (value) => _updateSetting('trendAlerts', value),
          ),
          SwitchListTile(
            title: const Text('System Updates'),
            subtitle: const Text(
              'Get notified about app updates and maintenance',
            ),
            value: _settings['systemUpdates'] ?? true,
            onChanged: (value) => _updateSetting('systemUpdates', value),
          ),
          SwitchListTile(
            title: const Text('Reminders'),
            subtitle: const Text('Get reminded about important tasks'),
            value: _settings['reminders'] ?? true,
            onChanged: (value) => _updateSetting('reminders', value),
          ),
        ],
      ),
    );
  }
}
