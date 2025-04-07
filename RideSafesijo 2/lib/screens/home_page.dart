// Update imports at the top
import 'package:flutter/material.dart';
import 'package:ridesafe/widgets/base_layout.dart';
import 'package:ridesafe/services/vehicle_service.dart';
import 'package:ridesafe/screens/bluetooth_management_page.dart';
import 'package:ridesafe/services/ride_statistics_service.dart';
import 'package:vibration/vibration.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isHelmetWorn = false;  // Keep this declaration at the top
  bool _isBluetoothConnected = false;
  final VehicleService _vehicleService = VehicleService();
  List<Map<String, dynamic>> vehicles = [];
  String selectedBikeNo = '';
  bool isLoading = true;

  final RideStatisticsService _rideStatisticsService = RideStatisticsService();
  Map<String, dynamic> rideStats = {
    'top_speed': 0.0,
    'battery_health': 0,
    'trip_distance': 0.0,
  };

  Timer? _alertCheckTimer;

  // Add new property for connection status
  bool _isDeviceConnected = false;

  // Remove duplicate initState and fix the timer setup
  @override
  void initState() {
    super.initState();
    _loadVehicles();
    _checkDeviceStatus();
    _checkHelmetStatus();
    _alertCheckTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkDeviceStatus();
      _checkHelmetStatus();
    });
  }

  Future<void> _checkDeviceStatus() async {
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser?.email == null) return;

      final response = await Supabase.instance.client
          .from('device_status')
          .select()
          .eq('email', currentUser!.email)
          .single();

      setState(() {
        _isDeviceConnected = response != null && response['connection'] == 'connect';
      });
    } catch (e) {
      setState(() {
        _isDeviceConnected = false;
      });
      debugPrint('Error checking device status: $e');
    }
  }

  @override
  void dispose() {
    _alertCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkForHelmetAlerts() async {
    try {
      final response = await Supabase.instance.client
          .from('helmet_alert')
          .select()
          .eq('alert_type', 'no_helmet')
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      if (response != null && mounted) {
        Vibration.vibrate(duration: 1000);
      }
    } catch (e) {
      debugPrint('Error checking helmet alerts: $e');
    }
  }

  // Remove duplicate methods and move all methods inside class body
  void _updateBluetoothState(bool isConnected) {
    setState(() {
      _isBluetoothConnected = isConnected;
    });
  }

  Future<void> _loadVehicles() async {
    try {
      final vehicleList = await _vehicleService.getVehicles();
      setState(() {
        vehicles = vehicleList;
        if (vehicles.isNotEmpty) {
          selectedBikeNo = vehicles.first['number'];
          _loadRideStatistics(vehicles.first['id']); // Load stats for first vehicle
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadRideStatistics(String vehicleId) async {
    final stats = await _rideStatisticsService.getLatestRideStatistics(vehicleId);
    setState(() {
      rideStats = stats;
    });
  }

  // Update _showVehicleSelector to load stats when vehicle changes
  void _showVehicleSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Select Vehicle',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: vehicles.map((vehicle) => ListTile(
            title: Text(
              vehicle['name'],
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              vehicle['number'],
              style: const TextStyle(color: Colors.grey),
            ),
            onTap: () {
              setState(() {
                selectedBikeNo = vehicle['number'];
              });
              _loadRideStatistics(vehicle['id']); // Load stats for selected vehicle
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  // Fix the _buildStat method placement (move it inside the class)
  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // Fix the closing brace placement for _buildBikeStats
  Widget _buildBikeStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStat('${rideStats['top_speed'].toStringAsFixed(1)}', 'Speed (km/h)'),
          Container(width: 1, height: 40, color: Colors.blue),
          _buildStat('${rideStats['battery_health']}%', 'Battery'),
          Container(width: 1, height: 40, color: Colors.blue),
          _buildStat('${rideStats['trip_distance'].toStringAsFixed(1)}', 'Trip (km)'),
        ],
      ),
    );
  }

  // Move these methods inside the class
  void _showHelmetAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Safety Alert',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Please wear your helmet for a safe ride!',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  // Remove these duplicate declarations:
  // bool _isHelmetWorn = false;  <- Remove this
  // @override
  // void initState() { ... }     <- Remove this entire method

  Future<void> _checkHelmetStatus() async {
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser?.email == null) return;

      final response = await Supabase.instance.client
          .from('helmet_alert')
          .select()
          .eq('email', currentUser!.email)
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      setState(() {
        _isHelmetWorn = response != null && response['alert_type'] == 'fine';
      });

      if (!_isHelmetWorn && mounted) {
        _showHelmetAlert(context);
        Vibration.vibrate(duration: 1000);
      }
    } catch (e) {
      setState(() {
        _isHelmetWorn = false;
      });
      debugPrint('Error checking helmet status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      currentIndex: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side with rider info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: _showVehicleSelector,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Hey Rider!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Bike No : $selectedBikeNo',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Right side with grouped icons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.warning_amber_rounded,
                        color: _isHelmetWorn ? Colors.green : Colors.red,
                      ),
                      onPressed: () => _showHelmetAlert(context),
                    ),
                    const SizedBox(width: 4), // Small gap between icons
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isDeviceConnected ? Colors.green : Colors.red,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isBluetoothConnected ? Icons.bluetooth_connected : Icons.bluetooth,
                        color: _isBluetoothConnected ? Colors.blue : Colors.grey,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BluetoothManagementPage(),
                          ),
                        ).then((connected) {
                          if (connected != null) {
                            _updateBluetoothState(connected as bool);
                          }
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 250,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[900]?.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/images/bike.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                  _buildBikeStats(),
                  // Recent Rides Section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recent Rides',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Column(
                            children: [
                              Text(
                                'No recent rides',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
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
          ),
        ],
      ),
    );
  }
}