class RideModel {
  final String id;
  final String vehicleId;
  final DateTime timestamp;
  final double distance;
  final double avgSpeed;
  final double maxSpeed;
  final int duration;

  RideModel({
    required this.id,
    required this.vehicleId,
    required this.timestamp,
    required this.distance,
    required this.avgSpeed,
    required this.maxSpeed,
    required this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'distance': distance,
      'avgSpeed': avgSpeed,
      'maxSpeed': maxSpeed,
      'duration': duration,
    };
  }

  factory RideModel.fromMap(Map<String, dynamic> map) {
    return RideModel(
      id: map['id'] ?? '',
      vehicleId: map['vehicleId'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      distance: (map['distance'] ?? 0).toDouble(),
      avgSpeed: (map['avgSpeed'] ?? 0).toDouble(),
      maxSpeed: (map['maxSpeed'] ?? 0).toDouble(),
      duration: map['duration'] ?? 0,
    );
  }
}