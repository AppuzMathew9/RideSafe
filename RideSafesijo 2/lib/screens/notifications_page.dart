import 'package:flutter/material.dart';
import 'package:ridesafe/widgets/base_layout.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  void _showHelmetAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Helmet Alert',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Helmet Not Detected!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wear your helmet before starting the ride.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Dismiss'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Check Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      currentIndex: 3,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                    onPressed: _showHelmetAlert,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildHelmetAlert(
                title: 'Helmet Not Detected!',
                message: 'Please wear your helmet before starting the ride.',
                time: '2 minutes ago',
                isWarning: true,
                onTap: _showHelmetAlert,
              ),
              _buildHelmetAlert(
                title: 'Helmet Connected',
                message: 'Your helmet is properly connected.',
                time: '1 hour ago',
                isWarning: false,
                onTap: () {},
              ),
              _buildHelmetAlert(
                title: 'Low Battery Warning',
                message: 'Helmet battery is below 20%. Please charge soon.',
                time: '3 hours ago',
                isWarning: true,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelmetAlert({
    required String title,
    required String message,
    required String time,
    required bool isWarning,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isWarning ? Colors.red.withOpacity(0.3) : Colors.green.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: ListTile(
          leading: Icon(
            isWarning ? Icons.warning_rounded : Icons.check_circle,
            color: isWarning ? Colors.red : Colors.green,
            size: 28,
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                message,
                style: TextStyle(color: Colors.grey[400]),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}