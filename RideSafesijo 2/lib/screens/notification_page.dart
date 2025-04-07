import 'package:flutter/material.dart';
import 'package:ridesafe/widgets/base_layout.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      currentIndex: 2,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildNotificationItem(
                  icon: Icons.warning_amber_rounded,
                  color: Colors.red,
                  title: 'Helmet Alert',
                  message: 'Please wear your helmet before starting the ride',
                  time: '1 min ago',
                ),
                _buildNotificationItem(
                  icon: Icons.warning_rounded,
                  color: Colors.orange,
                  title: 'Low Tire Pressure Alert',
                  message: 'Front tire pressure is below recommended level',
                  time: '2 hours ago',
                ),
                _buildNotificationItem(
                  icon: Icons.battery_alert_rounded,
                  color: Colors.red,
                  title: 'Battery Level Critical',
                  message: 'Your bike battery is at 15%',
                  time: '3 hours ago',
                ),
                _buildNotificationItem(
                  icon: Icons.security_rounded,
                  color: Colors.green,
                  title: 'Security Check Passed',
                  message: 'Your bike security system is working properly',
                  time: '5 hours ago',
                ),
                _buildNotificationItem(
                  icon: Icons.schedule_rounded,
                  color: Colors.blue,
                  title: 'Maintenance Reminder',
                  message: 'Schedule your next service in 3 days',
                  time: '1 day ago',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}