// Remove LiveTracking class and keep only these imports
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ridesafe/screens/feedback_page.dart';
import 'package:ridesafe/screens/login_page.dart';
import 'package:ridesafe/screens/admin_tracking_page.dart';

class NewAdminPage extends StatefulWidget {
  const NewAdminPage({super.key});

  @override
  State<NewAdminPage> createState() => _NewAdminPageState();
}



class _NewAdminPageState extends State<NewAdminPage> {
  int _selectedIndex = 0;

  Widget get currentPage => _pages[_selectedIndex];

  final List<Widget> _pages = [
    const UserManagement(),
    const IncidentMonitoring(),
    const AdminTrackingPage(),  // Changed from TrackingPage to AdminTrackingPage
    const SystemSettings(),
    const HardwareIntegration(),
    const EmergencyResponse(),
    const ManageReports(),
  ];

  // Remove LiveTracking class as it's no longer needed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('Admin Dashboard', style: TextStyle(color: Colors.white)),
      ),
      drawer: Drawer(
        backgroundColor: Colors.grey[900],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(Icons.admin_panel_settings, size: 35, color: Colors.blue),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Admin Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.people, color: Colors.blue),
              title: const Text('Users', style: TextStyle(color: Colors.white)),
              selected: _selectedIndex == 0,
              onTap: () => _updateIndex(0, context),
            ),
            ListTile(
              leading: const Icon(Icons.warning, color: Colors.blue),
              title: const Text('Violations', style: TextStyle(color: Colors.white)),
              selected: _selectedIndex == 1,
              onTap: () => _updateIndex(1, context),
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.blue),
              title: const Text('Tracking', style: TextStyle(color: Colors.white)),
              selected: _selectedIndex == 2,
              onTap: () => _updateIndex(2, context),  // Fixed tracking onTap handler
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.blue),
              title: const Text('Settings', style: TextStyle(color: Colors.white)),
              selected: _selectedIndex == 3,
              onTap: () => _updateIndex(3, context),
            ),
            ListTile(
              leading: const Icon(Icons.devices, color: Colors.blue),
              title: const Text('Hardware', style: TextStyle(color: Colors.white)),
              selected: _selectedIndex == 4,
              onTap: () => _updateIndex(4, context),
            ),
            ListTile(
              leading: const Icon(Icons.emergency, color: Colors.blue),
              title: const Text('Emergency', style: TextStyle(color: Colors.white)),
              selected: _selectedIndex == 5,
              onTap: () => _updateIndex(5, context),
            ),
            ListTile(
              leading: const Icon(Icons.assessment, color: Colors.blue),
              title: const Text('Reports', style: TextStyle(color: Colors.white)),
              selected: _selectedIndex == 6,
              onTap: () => _updateIndex(6, context),
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: currentPage,
    );
  }

  void _updateIndex(int index, BuildContext context) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Close the drawer
  }
}

// Placeholder widgets for each section
class UserManagement extends StatefulWidget {
  const UserManagement({super.key});

  @override
  State<UserManagement> createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final response = await _supabase
          .from('user_details')  // Changed from 'User_details' to 'user_details'
          .select('id, full_name, email, phone_number')
          .order('created_at');

      if (mounted) {
        setState(() {
          _users = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading users: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'User Management',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        color: Colors.grey[900],
                        child: ListTile(
                          title: Text(
                            user['full_name'] ?? 'No name',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user['email'] ?? 'No email',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              Text(
                                user['phone_number'] ?? 'No phone',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              try {
                                await _supabase
                                    .from('user_details')  // Changed from 'User_details' to 'user_details'
                                    .delete()
                                    .eq('id', user['id']);
                                _loadUsers();
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error deleting user: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
  }
}

class IncidentMonitoring extends StatelessWidget {
  const IncidentMonitoring({super.key});
  @override
  Widget build(BuildContext context) => const Center(
        child: Text(
          'Incident & Violation Monitoring',
          style: TextStyle(color: Colors.white),
        ),
      );
}

class SystemSettings extends StatelessWidget {
  const SystemSettings({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('System Settings & Notifications', style: TextStyle(color: Colors.white)));
}

class HardwareIntegration extends StatelessWidget {
  const HardwareIntegration({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Hardware Integration & Alerts', style: TextStyle(color: Colors.white)));
}

class EmergencyResponse extends StatelessWidget {
  const EmergencyResponse({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Accident & Emergency Response', style: TextStyle(color: Colors.white)));
}

// Keep only this version of ManageReports and remove the other implementation
class ManageReports extends StatelessWidget {
  const ManageReports({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const FeedbackPage();
  }
}
