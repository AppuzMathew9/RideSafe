import 'package:supabase_flutter/supabase_flutter.dart';

class VehicleService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getVehicles() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('vehicle_details')
        .select()
        .eq('user_id', userId);
    
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addVehicle(String name, String number) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase.from('vehicle_details').insert({
      'user_id': userId,
      'name': name,
      'number': number,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteVehicle(int vehicleId) async {
    await _supabase
        .from('vehicle_details')
        .delete()
        .eq('id', vehicleId);
  }
}