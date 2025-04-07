// Update imports
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class AdminTrackingPage extends StatefulWidget {
  const AdminTrackingPage({Key? key}) : super(key: key);

  @override
  State<AdminTrackingPage> createState() => _AdminTrackingPageState();
}

class _AdminTrackingPageState extends State<AdminTrackingPage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _recentLocations = [];
  bool _isLoading = true;
  final MapController _mapController = MapController();
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadRecentLocations();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _loadRecentLocations();
    });
  }

  Future<void> _loadRecentLocations() async {
    try {
      final response = await _supabase
          .from('location_details')
          .select('''
            user_id,
            address,
            latitude,
            longitude
          ''')
          .order('updated_at', ascending: false);

      if (mounted) {
        setState(() {
          _recentLocations = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading locations: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Replace the _buildLocationMarkers method with _buildLocationPolygons
  List<Polygon> _buildLocationPolygons() {
    return _recentLocations.map((location) {
      try {
        final lat = double.parse(location['latitude'].toString());
        final lng = double.parse(location['longitude'].toString());
        
        return Polygon(
          points: [
            LatLng(lat - 0.001, lng - 0.001),
            LatLng(lat + 0.001, lng - 0.001),
            LatLng(lat + 0.001, lng + 0.001),
            LatLng(lat - 0.001, lng + 0.001),
          ],
          color: Colors.blue.withOpacity(0.5),
          borderColor: Colors.white,
          borderStrokeWidth: 2,
        );
      } catch (e) {
        debugPrint('Error creating location polygon: $e');
        return null;
      }
    }).whereType<Polygon>().toList();
  }

  List<CircleMarker> _buildLocationCircles() {
    return _recentLocations.map((location) {
      try {
        final lat = double.parse(location['latitude'].toString());
        final lng = double.parse(location['longitude'].toString());
        
        return CircleMarker(
          point: LatLng(lat, lng),
          radius: 8.0,
          color: Colors.red.withOpacity(0.7),
          borderColor: Colors.white,
          borderStrokeWidth: 2,
          useRadiusInMeter: false,
        );
      } catch (e) {
        debugPrint('Error creating location circle: $e');
        return null;
      }
    }).whereType<CircleMarker>().toList();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[800]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: const LatLng(14.5995, 120.9842),
                  zoom: 13.0,
                  minZoom: 5.0,
                  maxZoom: 18.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.ridesafe.app',
                  ),
                  CircleLayer(
                    circles: _buildLocationCircles(),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // User Locations List
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'User Locations',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: _recentLocations.length,
                          itemBuilder: (context, index) {
                            final location = _recentLocations[index];
                            return Card(
                              color: Colors.grey[850],
                              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: ListTile(
                                title: Text(
                                  'User ID: ${location['user_id']}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Coordinates: ${location['latitude']}, ${location['longitude']}',
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                    Text(
                                      'Address: ${location['address'] ?? 'Unknown Location'}',
                                      style: const TextStyle(color: Colors.grey),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  final lat = double.tryParse(location['latitude']?.toString() ?? '');
                                  final lng = double.tryParse(location['longitude']?.toString() ?? '');
                                  if (lat != null && lng != null) {
                                    _mapController.move(LatLng(lat, lng), 15.0);
                                  }
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
      ],
    );
  }
}