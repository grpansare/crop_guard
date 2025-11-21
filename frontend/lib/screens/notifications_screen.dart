import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> notifications = [];
  bool isLoading = true;
  int unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final token = await AuthService.getToken();
      if (token != null) {
        final response = await ApiService.getNotifications(token);
        setState(() {
          notifications = response['notifications'] ?? [];
          unreadCount = response['unreadCount'] ?? 0;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(int notificationId) async {
    try {
      final token = await AuthService.getToken();
      if (token != null) {
        await ApiService.markNotificationAsRead(notificationId, token);
        _loadNotifications(); // Refresh list
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final isRead = notification['isRead'] ?? false;

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isRead ? Colors.grey : Colors.green,
                      child: Icon(
                        _getNotificationIcon(notification['type']),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      notification['title'] ?? '',
                      style: TextStyle(
                        fontWeight: isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification['message'] ?? ''),
                        SizedBox(height: 4),
                        Text(
                          _formatDate(notification['createdAt']),
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    onTap: () {
                      if (!isRead) {
                        _markAsRead(notification['id']);
                      }
                    },
                  ),
                );
              },
            ),
    );
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'QUERY_RESPONSE':
        return Icons.question_answer;
      case 'QUERY_STATUS_UPDATE':
        return Icons.update;
      case 'SYSTEM_NOTIFICATION':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays > 0) {
        return '${diff.inDays}d ago';
      } else if (diff.inHours > 0) {
        return '${diff.inHours}h ago';
      } else {
        return '${diff.inMinutes}m ago';
      }
    } catch (e) {
      return '';
    }
  }
}
