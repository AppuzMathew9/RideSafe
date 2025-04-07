import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class BluetoothService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> saveDevice(Map<String, dynamic> device, BuildContext context) async {
    // Get screen size
    final screenSize = MediaQuery.of(context).size;
    final deviceRatio = {
      'width': screenSize.width,
      'height': screenSize.height,
      'device_id': device['address'],
      'name': device['name'],
      'last_connected': DateTime.now().toIso8601String(),
      'is_paired': true,
    };

    await _supabase.from('bluetooth_devices').upsert(deviceRatio);
  }

  Future<List<Map<String, dynamic>>> getRecentDevices(BuildContext context) async {
    final screenSize = MediaQuery.of(context).size;
    final response = await _supabase
        .from('bluetooth_devices')
        .select()
        .order('last_connected', ascending: false);
    
    // Adjust device list based on screen size
    final devices = List<Map<String, dynamic>>.from(response);
    final adjustedDevices = devices.map((device) {
      return {
        ...device,
        'adjusted_width': screenSize.width,
        'adjusted_height': screenSize.height,
      };
    }).toList();

    return adjustedDevices;
  }

  Future<void> updateLastConnected(String deviceId, BuildContext context) async {
    final screenSize = MediaQuery.of(context).size;
    await _supabase.from('bluetooth_devices').update({
      'last_connected': DateTime.now().toIso8601String(),
      'width': screenSize.width,
      'height': screenSize.height,
    }).eq('device_id', deviceId);
  }

  Future<List<Map<String, dynamic>>> scanNearbyDevices(BuildContext context) async {
    final screenSize = MediaQuery.of(context).size;
    // Implement actual Bluetooth scanning logic
    await Future.delayed(const Duration(seconds: 2)); // Simulate scanning
    
    return [
      {
        'device_id': 'device1',
        'name': 'Device 1',
        'rssi': '-65 dBm',
        'width': screenSize.width,
        'height': screenSize.height,
      },
      {
        'device_id': 'device2',
        'name': 'Device 2',
        'rssi': '-72 dBm',
        'width': screenSize.width,
        'height': screenSize.height,
      },
    ];
  }

  Future<void> connectToDevice(String deviceId, BuildContext context) async {
    final screenSize = MediaQuery.of(context).size;
    // Update device with current screen dimensions
    await _supabase.from('bluetooth_devices').update({
      'width': screenSize.width,
      'height': screenSize.height,
      'last_connected': DateTime.now().toIso8601String(),
    }).eq('device_id', deviceId);
    
    // Implement actual Bluetooth connection logic
    await Future.delayed(const Duration(seconds: 1)); // Simulate connection
  }
}