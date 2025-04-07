import 'package:supabase_flutter/supabase_flutter.dart';

class RideStatisticsService {
  final _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getLatestRideStatistics(String vehicleId) async {
    try {
      final response = await _supabase
          .from('ride_statistics')
          .select()
          .eq('vehicle_id', vehicleId)
          .order('created_at', ascending: false)
          .limit(1)
          .single();
      
      return {
        'top_speed': response['top_speed'],
        'battery_health': response['battery_health'],
        'trip_distance': response['trip_distance'],
      };
    } catch (e) {
      return {
        'top_speed': 0.0,
        'battery_health': 0,
        'trip_distance': 0.0,
      };
    }
  }
}