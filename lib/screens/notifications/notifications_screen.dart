import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../services/notification_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: FutureBuilder<List<PendingNotificationRequest>>(
        future: NotificationService.instance.getPendingReminders(),
        builder: (context, snapshot) {
          final list = snapshot.data ?? const <PendingNotificationRequest>[];
          if (list.isEmpty) {
            return const Center(child: Text('No reminders set'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final item = list[i];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.notifications_active_outlined),
                  ),
                  title: Text(item.title ?? 'Reminder'),
                  subtitle: Text(item.body ?? ''),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
