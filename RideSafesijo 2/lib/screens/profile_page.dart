import 'package:flutter/material.dart';
import 'package:ridesafe/widgets/base_layout.dart';
import 'package:ridesafe/screens/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ridesafe/services/vehicle_service.dart';
import 'package:ridesafe/screens/edit_profile_page.dart';
import 'package:ridesafe/screens/help_support_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final VehicleService _vehicleService = VehicleService();
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> vehicles = [];
  String userName = '';
  bool isLoading = true;
  bool isLoadingVehicles = true;
  List<Map<String, dynamic>> recentLocations = [];
  bool isLoadingLocations = true;
  // Add these at the class level
  double _rating = 0;
  final _feedbackController = TextEditingController();
  bool _hasSubmittedReview = false;
  String _existingFeedbackId = '';

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeSupabase();
    _checkExistingReview();
  }

  // Remove the standalone UI code blocks and keep only the methods
  Future<void> _checkExistingReview() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        final response = await _supabase
            .from('user_feedback')
            .select()
            .eq('user_id', userId)
            .single();
        
        if (mounted) {
          setState(() {
            _hasSubmittedReview = true;
            _existingFeedbackId = response['id'].toString();
            _rating = (response['rating'] ?? 0).toDouble();
            _feedbackController.text = response['feedback'] ?? '';
          });
        }
      }
    } catch (e) {
      // No existing review found
      setState(() {
        _hasSubmittedReview = false;
        _existingFeedbackId = '';
      });
    }
  }

  // Remove duplicate _submitFeedback method
  Future<void> _submitFeedback() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        if (_hasSubmittedReview) {
          // Update existing review
          await _supabase
              .from('user_feedback')
              .update({
                'rating': _rating.toInt(),
                'feedback': _feedbackController.text,
              })
              .eq('id', _existingFeedbackId);
        } else {
          // Insert new review
          final response = await _supabase
              .from('user_feedback')
              .insert({
                'user_id': userId,
                'rating': _rating.toInt(),
                'feedback': _feedbackController.text,
              })
              .select();
          
          _existingFeedbackId = response[0]['id'].toString();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_hasSubmittedReview 
                ? 'Review updated successfully!' 
                : 'Thank you for your feedback!'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _hasSubmittedReview = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error ${_hasSubmittedReview ? 'updating' : 'submitting'} feedback: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Remove standalone UI code blocks
  // Replace the existing feedback section title with:

  // Update the submit button text
 

  Future<void> _initializeSupabase() async {
    try {
      await _loadUserData();
      await _loadVehicles();
      await _loadRecentLocations();
    } catch (e) {
      debugPrint('Error initializing data: $e');
    }
  }

  Future<void> _loadRecentLocations() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('location_details')
          .select()
          .eq('user_id', user.id)
          .eq('location_type', 'recent')
          .order('created_at', ascending: false)
          .limit(10);

      if (mounted) {
        setState(() {
          recentLocations = response.map((loc) => {
            'title': loc['title'] as String,
            'latitude': loc['latitude'] as double,
            'longitude': loc['longitude'] as double,
            'address': loc['address'] as String,
            'timestamp': loc['created_at'] as String,
          }).toList();
          isLoadingLocations = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoadingLocations = false);
      }
    }
  }

  void _showRideHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Row(
          children: [
            const Icon(Icons.history, color: Colors.blue),
            const SizedBox(width: 8),
            const Text(
              'Recent Locations',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400, // Fixed height for the dialog
          child: Column(
            children: [
              if (isLoadingLocations)
                const Center(child: CircularProgressIndicator())
              else if (recentLocations.isEmpty)
                const Center(
                  child: Text(
                    'No recent locations found',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: recentLocations.length,
                    itemBuilder: (context, index) {
                      final location = recentLocations[index];
                      final dateTime = DateTime.parse(location['timestamp']);
                      final formattedDate = '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';

                      return ListTile(
                        leading: const Icon(Icons.location_on, color: Colors.blue),
                        title: Text(
                          location['title'],
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              location['address'],
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Text(
                              formattedDate,
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadUserData() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final response = await Supabase.instance.client
            .from('user_details')
            .select('full_name')
            .eq('user_id', userId)
            .single();
        
        setState(() {
          userName = response['full_name'] ?? 'User';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        userName = 'User';
        isLoading = false;
      });
    }
  }

  Future<void> _loadVehicles() async {
    try {
      final vehicleList = await _vehicleService.getVehicles();
      setState(() {
        vehicles = vehicleList;
        isLoadingVehicles = false;
      });
    } catch (e) {
      setState(() {
        isLoadingVehicles = false;
      });
    }
  }

  // Remove the hardcoded vehicles list and keep only one version of each method
  // Keep the first version of _showAddVehicleDialog() and _showVehiclesList()
  // that uses the VehicleService

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : Colors.blue,
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.white,
            fontSize: 16,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey[600],
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showAddVehicleDialog() {
    final nameController = TextEditingController();
    final numberController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Add New Vehicle',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Vehicle Name',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: numberController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Vehicle Number',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && numberController.text.isNotEmpty) {
                await _vehicleService.addVehicle(
                  nameController.text,
                  numberController.text,
                );
                _loadVehicles(); // Reload the vehicles list
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showVehiclesList() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'My Vehicles',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.add_circle, color: Colors.blue),
                title: const Text(
                  'Add New Vehicle',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showAddVehicleDialog();
                },
              ),
              Divider(color: Colors.grey[800]),
              if (isLoadingVehicles)
                const Center(child: CircularProgressIndicator())
              else if (vehicles.isEmpty)
                const Center(
                  child: Text(
                    'No vehicles added yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: vehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = vehicles[index];
                      return ListTile(
                        leading: const Icon(Icons.motorcycle, color: Colors.blue),
                        title: Text(
                          vehicle['name'],
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          vehicle['number'],
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await _vehicleService.deleteVehicle(vehicle['id']);
                            _loadVehicles(); // Reload the list
                            Navigator.pop(context);
                            _showVehiclesList(); // Refresh the dialog
                          },
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      currentIndex: 3,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header with avatar and name
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[800],
                    child: const Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ],
              ),
            ),

            // Profile Options
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildProfileOption(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfilePage(currentName: userName),
                        ),
                      );
                      if (result == true) {
                        _loadUserData();
                      }
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.motorcycle_outlined,
                    title: 'My Vehicles',
                    onTap: _showVehiclesList,
                  ),
                  _buildProfileOption(
                    icon: Icons.history,
                    title: 'Ride History',
                    onTap: _showRideHistory,
                  ),
                  _buildProfileOption(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.grey[900],
                          title: const Text(
                            'Settings',
                            style: TextStyle(color: Colors.white),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Remove Raspberry Pi connection option
                              // Add other settings options here if needed
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HelpSupportPage(),
                        ),
                      );
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.logout,
                    title: 'Logout',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    isDestructive: true,
                  ),
                  
                  // Rating and Feedback Section
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _hasSubmittedReview ? 'Your Review' : 'Rate Your Experience',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Update the rating button's onPressed handler
                        Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                        return IconButton(
                        icon: Icon(
                        index < _rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 30,
                        ),
                        onPressed: _hasSubmittedReview ? null : () {
                        setState(() {
                        _rating = index + 1;
                        });
                        },
                        );
                        }),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _feedbackController,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 3,
                          enabled: !_hasSubmittedReview,  // Disable text field after submission
                          decoration: InputDecoration(
                            hintText: 'Share your feedback...',
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            fillColor: Colors.grey[800],
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _rating > 0 ? _submitFeedback : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              _hasSubmittedReview ? 'Update Review' : 'Submit Review',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}