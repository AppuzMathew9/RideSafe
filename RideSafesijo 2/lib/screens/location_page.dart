import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ridesafe/widgets/base_layout.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final _supabase = Supabase.instance.client;
  Position? currentPosition;
  LatLng? homeLocation;
  LatLng? workLocation;
  String? homeAddress;
  String? workAddress;
  LatLng defaultLocation = const LatLng(37.7749, -122.4194); 
  late final MapController mapController;
  List<Map<String, dynamic>> recentLocations = [];
  double _currentZoom = 15.0;
  static const double _minZoom = 3.0;
  static const double _maxZoom = 18.0;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _checkAuth();
    // Initialize location and set up periodic updates
    _initializeLocation();
    Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _getCurrentLocation();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _checkAuth() async {
    final session = _supabase.auth.currentSession;
    if (session == null) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  Future<void> _initializeLocation() async {
    await _getCurrentLocation();
    if (mounted) await _loadLocationsFromSupabase();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        _showSnackBar('Please enable location services');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar('Location permissions are permanently denied');
        await Geolocator.openAppSettings();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: true,
      );

      if (mounted) {
        setState(() {
          currentPosition = position;
        });
        
        // Get address for the current location
        final address = await _getAddressFromLatLng(
          LatLng(position.latitude, position.longitude)
        );
        
        // Save as live location
        await _supabase.from('location_details').upsert(
          {
            'user_id': _supabase.auth.currentUser!.id,
            'location_type': 'live',
            'latitude': position.latitude,
            'longitude': position.longitude,
            'address': address,
            'updated_at': DateTime.now().toIso8601String(),
          },
          onConflict: 'user_id, location_type'
        );

        // Save as recent location
        await _addToRecentLocations(
          'Current Location',
          LatLng(position.latitude, position.longitude)
        );
        
        // Update live location in Supabase
        try {
          final address = await _getAddressFromLatLng(
            LatLng(position.latitude, position.longitude)
          );
          
          await _supabase.from('location_details').upsert(
            {
              'user_id': _supabase.auth.currentUser!.id,
              'location_type': 'live',
              'latitude': position.latitude,
              'longitude': position.longitude,
              'address': address,
              'updated_at': DateTime.now().toIso8601String(),
            },
            onConflict: 'user_id, location_type'
          );
        } catch (e) {
          debugPrint('Error updating live location: $e');
        }
        
        // Ensure map updates after getting position
        if (mapController.camera.center != LatLng(position.latitude, position.longitude)) {
          await mapController.move(
            LatLng(position.latitude, position.longitude),
            _currentZoom,
          );
        }
      }
    } catch (e) {
      debugPrint('Location error: $e');
      _showSnackBar('Error getting location. Please check your settings.');
    }
  }

  // Remove the first initState method and keep only this one

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<String> _getAddressFromLatLng(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        List<String> addressParts = [];
        
        if (place.street?.isNotEmpty ?? false) {
          addressParts.add(place.street!);
        }
        if (place.subLocality?.isNotEmpty ?? false) {
          addressParts.add(place.subLocality!);
        }
        if (place.locality?.isNotEmpty ?? false) {
          addressParts.add(place.locality!);
        }
        if (place.postalCode?.isNotEmpty ?? false) {
          addressParts.add(place.postalCode!);
        }
        
        return addressParts.isNotEmpty 
            ? addressParts.join(', ')
            : '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
    }
    return '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
  }

  Future<void> _loadLocationsFromSupabase() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('location_details')
          .select()
          .eq('user_id', user.id);

      if (mounted) {
        setState(() {
          for (final location in response) {
            if (location['location_type'] == 'home') {
              homeLocation = LatLng(
                location['latitude'] as double,
                location['longitude'] as double,
              );
              homeAddress = location['address'] as String?;
            } else if (location['location_type'] == 'work') {
              workLocation = LatLng(
                location['latitude'] as double,
                location['longitude'] as double,
              );
              workAddress = location['address'] as String?;
            } else if (location['location_type'] == 'recent') {
              recentLocations.add({
                'title': location['title'] as String,
                'latitude': location['latitude'] as double,
                'longitude': location['longitude'] as double,
                'timestamp': location['created_at'] as String,
              });
            }
          }
        });
      }
    } catch (e) {
      _showSnackBar('Error loading locations: ${e.toString()}');
    }
  }

  Future<void> _saveLocation(String type, LatLng location) async {
    try {
      final address = await _getAddressFromLatLng(location);
      
      if (type == 'home' || type == 'work') {
        // Update or insert home/work location
        final existing = await _supabase
            .from('location_details')
            .select()
            .eq('user_id', _supabase.auth.currentUser!.id)
            .eq('location_type', type)
            .maybeSingle();

        if (existing != null) {
          await _supabase
              .from('location_details')
              .update({
                'latitude': location.latitude,
                'longitude': location.longitude,
                'address': address,
              })
              .eq('id', existing['id']);
        } else {
          await _supabase.from('location_details').insert({
            'user_id': _supabase.auth.currentUser!.id,
            'location_type': type,
            'title': type.capitalize(),
            'latitude': location.latitude,
            'longitude': location.longitude,
            'address': address,
          });
        }

        setState(() {
          if (type == 'home') {
            homeLocation = location;
            homeAddress = address;
          } else {
            workLocation = location;
            workAddress = address;
          }
        });
      }

      // Add to recent locations
      await _addToRecentLocations(type, location);
      
      _showSnackBar('$type location saved successfully');
    } catch (e) {
      _showSnackBar('Error saving location: ${e.toString()}');
    }
  }

  Future<void> _addToRecentLocations(String title, LatLng location) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final address = await _getAddressFromLatLng(location);

      await _supabase.from('location_details').insert({
        'user_id': user.id,
        'location_type': 'recent',
        'title': title,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'address': address,
      }).select();  // Add select() to ensure proper timestamp handling

      // Fetch latest recent locations
      final response = await _supabase
          .from('location_details')
          .select()
          .eq('user_id', user.id)
          .eq('location_type', 'recent')
          .order('created_at', ascending: false)
          .limit(5);

      if (mounted) {
        setState(() {
          recentLocations = response.map((loc) => {
            'title': loc['title'] as String,
            'latitude': loc['latitude'] as double,
            'longitude': loc['longitude'] as double,
            'timestamp': loc['created_at'] as String,
          }).toList();
        });
      }
    } catch (e) {
      _showSnackBar('Error saving recent location: ${e.toString()}');
    }
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];
    
    if (currentPosition != null) {
      markers.add(Marker(
        point: LatLng(currentPosition!.latitude, currentPosition!.longitude),
        width: 40,
        height: 40,
        child: const Icon(Icons.location_pin, color: Colors.blue, size: 40),
      ));
    }

    if (homeLocation != null) {
      markers.add(Marker(
        point: homeLocation!,
        width: 40,
        height: 40,
        child: const Icon(Icons.home, color: Colors.green, size: 40),
      ));
    }

    if (workLocation != null) {
      markers.add(Marker(
        point: workLocation!,
        width: 40,
        height: 40,
        child: const Icon(Icons.work, color: Colors.orange, size: 40),
      ));
    }

    return markers;
  }

  String _calculateDistance(LatLng start, LatLng end) {
    double distance = Geolocator.distanceBetween(
      start.latitude, 
      start.longitude, 
      end.latitude, 
      end.longitude
    );
    return '${(distance / 1000).toStringAsFixed(2)} km';
  }

  // Remove these methods
  void _zoomIn() {
    final newZoom = (_currentZoom + 1).clamp(_minZoom, _maxZoom);
    setState(() => _currentZoom = newZoom);
    mapController.move(
      LatLng(currentPosition?.latitude ?? defaultLocation.latitude,
             currentPosition?.longitude ?? defaultLocation.longitude),
      newZoom
    );
  }

  void _zoomOut() {
    final newZoom = (_currentZoom - 1).clamp(_minZoom, _maxZoom);
    setState(() => _currentZoom = newZoom);
    mapController.move(
      LatLng(currentPosition?.latitude ?? defaultLocation.latitude,
             currentPosition?.longitude ?? defaultLocation.longitude),
      newZoom
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      currentIndex: 1,
      child: Column(
        children: [
          Expanded(
            flex: 3, // Increased flex for map
            child: Stack(
              children: [
                currentPosition == null
                    ? const Center(child: CircularProgressIndicator())
                    : FlutterMap(
                        mapController: mapController,
                        options: MapOptions(
                          initialCenter: LatLng(
                            currentPosition?.latitude ?? defaultLocation.latitude,
                            currentPosition?.longitude ?? defaultLocation.longitude
                          ),
                          initialZoom: _currentZoom,
                          onTap: (tapPosition, point) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Save Location'),
                                content: const Text('Save this location as:'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _saveLocation('home', point);
                                    },
                                    child: const Text('Home'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _saveLocation('work', point);
                                    },
                                    child: const Text('Work'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.ridesafe',
                          ),
                          MarkerLayer(markers: _buildMarkers()),
                        ],
                      ),
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        heroTag: "homeLocation",
                        onPressed: () {
                          if (homeLocation != null) {
                            mapController.move(homeLocation!, _currentZoom);
                          }
                        },
                        mini: true,
                        backgroundColor: Colors.green,
                        child: const Icon(Icons.home),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: "workLocation",
                        onPressed: () {
                          if (workLocation != null) {
                            mapController.move(workLocation!, _currentZoom);
                          }
                        },
                        mini: true,
                        backgroundColor: Colors.orange,
                        child: const Icon(Icons.work),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: "currentLocation",
                        onPressed: _getCurrentLocation,
                        mini: true,
                        backgroundColor: Colors.blue,
                        child: const Icon(Icons.my_location),
                      ),
                    ],
                  ),
                ),
                // Remove this entire Positioned widget
                // Positioned(
                //   right: 16,
                //   bottom: 16,
                //   child: Column(
                //     children: [
                //       FloatingActionButton(
                //         heroTag: "zoomIn",
                //         onPressed: _zoomIn,
                //         mini: true,
                //         child: const Icon(Icons.add),
                //       ),
                //       const SizedBox(height: 8),
                //       FloatingActionButton(
                //         heroTag: "zoomOut",
                //         onPressed: _zoomOut,
                //         mini: true,
                //         child: const Icon(Icons.remove),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
          Expanded(
            flex: 2, // Increased flex for bottom section
            child: DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.25,
              maxChildSize: 0.75,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.9),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[600],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const Text(
                            'Saved Locations',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (homeLocation != null)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.home, color: Colors.green),
                              title: const Text('Home', style: TextStyle(color: Colors.white)),
                              subtitle: Text(
                                homeAddress ?? 'Loading address...',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                          if (workLocation != null)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.work, color: Colors.orange),
                              title: const Text('Work', style: TextStyle(color: Colors.white)),
                              subtitle: Text(
                                workAddress ?? 'Loading address...',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                          const SizedBox(height: 16),
                          const Text(
                            'Recent Locations',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: recentLocations.length,
                            itemBuilder: (context, index) {
                              final location = recentLocations[index];
                              final distance = currentPosition != null
                                  ? _calculateDistance(
                                      LatLng(currentPosition!.latitude, currentPosition!.longitude),
                                      LatLng(location['latitude'] as double, location['longitude'] as double),
                                    )
                                  : 'N/A';

                              return FutureBuilder<String>(
                                future: _getAddressFromLatLng(LatLng(
                                  location['latitude'] as double,
                                  location['longitude'] as double,
                                )),
                                builder: (context, snapshot) {
                                  return ListTile(
                                    leading: const Icon(Icons.location_on, color: Colors.blue),
                                    title: Text(
                                      location['title'] as String,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    subtitle: Text(
                                      '${snapshot.data ?? 'Loading address...'}\nDistance: $distance',
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Add this extension at the end of the file if it's missing
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}