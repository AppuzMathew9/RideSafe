import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.phone, color: Colors.blue),
                title: const Text(
                  'Toll Free Number',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  '1800-123-4567',
                  style: TextStyle(color: Colors.grey),
                ),
                onTap: () => _makePhoneCall('18001234567'),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.support_agent, color: Colors.blue),
                title: const Text(
                  'Support Contact',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  '9496469276',
                  style: TextStyle(color: Colors.grey),
                ),
                onTap: () => _makePhoneCall('9496469276'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}