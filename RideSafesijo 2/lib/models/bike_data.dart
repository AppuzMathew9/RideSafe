class BikeData {
  final double speed;
  final double batteryHealth;
  final double tripDistance;
  final bool helmetWorn;
  final bool isConnected;

  BikeData({
    required this.speed,
    required this.batteryHealth,
    required this.tripDistance,
    required this.helmetWorn,
    required this.isConnected,
  });

  factory BikeData.fromMap(Map<String, dynamic> map) {
    return BikeData(
      speed: map['speed']?.toDouble() ?? 0.0,
      batteryHealth: map['battery_health']?.toDouble() ?? 0.0,
      tripDistance: map['trip_distance']?.toDouble() ?? 0.0,
      helmetWorn: map['helmet_worn'] ?? false,
      isConnected: map['is_connected'] ?? false,
    );
  }
}