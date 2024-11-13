import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: dummyNotifications.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final notification = dummyNotifications[index];
          return NotificationTile(notification: notification);
        },
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final NotificationItem notification;

  const NotificationTile({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.grey[200] : Colors.blue[100],
          shape: BoxShape.circle,
        ),
        child: Icon(
          notification.icon,
          color: notification.isRead ? Colors.grey[600] : Colors.blue,
        ),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(notification.message),
          const SizedBox(height: 4),
          Text(
            notification.time,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
      onTap: () {
        // 알림 클릭 시 처리
        print('알림 클릭됨: ${notification.title}');
      },
    );
  }
}

class NotificationItem {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final bool isRead;

  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    this.isRead = false,
  });
}

// 더미 데이터
final List<NotificationItem> dummyNotifications = [
  NotificationItem(
    title: '소음 측정 완료',
    message: '오늘의 소음 측정이 완료되었습니다.',
    time: '방금 전',
    icon: Icons.notifications,
  ),
  NotificationItem(
    title: '일일 리포트',
    message: '어제의 소음 분석 리포트가 준비되었습니다.',
    time: '2시간 전',
    icon: Icons.assessment,
    isRead: true,
  ),
  NotificationItem(
    title: '주간 분석',
    message: '이번 주 소음 분석 결과를 확인해보세요.',
    time: '1일 전',
    icon: Icons.analytics,
    isRead: true,
  ),
];
