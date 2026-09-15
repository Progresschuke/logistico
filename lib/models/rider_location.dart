class RiderLocation {
  final double latitude;
  final double longitude;
  final String riderId;
  final String userId;
  final double accuracy;
  final DateTime timestamp;
  final double speed;
  final double heading;
  final double altitude;
  final double speedAccuracy;
  final double headingAccuracy;
  final double altitudeAccuracy;

  const RiderLocation({
    required this.latitude,
    required this.longitude,
    required this.riderId,
    required this.userId,
    required this.accuracy,
    required this.timestamp,
    required this.speed,
    required this.heading,
    required this.altitude,
    required this.speedAccuracy,
    required this.headingAccuracy,
    required this.altitudeAccuracy,
  });

  RiderLocation copyWith({
    double? latitude,
    double? longitude,
    String? riderId,
    String? userId,
    double? accuracy,
    DateTime? timestamp,
    double? speed,
    double? heading,
    double? altitude,
    double? speedAccuracy,
    double? headingAccuracy,
    double? altitudeAccuracy,
  }) {
    return RiderLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      riderId: riderId ?? this.riderId,
      userId: userId ?? this.userId,
      accuracy: accuracy ?? this.accuracy,
      timestamp: timestamp ?? this.timestamp,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      altitude: altitude ?? this.altitude,
      speedAccuracy: speedAccuracy ?? this.speedAccuracy,
      headingAccuracy: headingAccuracy ?? this.headingAccuracy,
      altitudeAccuracy: altitudeAccuracy ?? this.altitudeAccuracy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': 'rider_location',
      'latitude': latitude,
      'longitude': longitude,
      'riderId': riderId,
      'userId': userId,
      'accuracy': accuracy,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'speed': speed,
      'heading': heading,
      'altitude': altitude,
      'speedAccuracy': speedAccuracy,
      'headingAccuracy': headingAccuracy,
      'altitudeAccuracy': altitudeAccuracy,
    };
  }

  factory RiderLocation.fromJson(Map<String, dynamic> json) {
    DateTime parsedTimestamp;
    final rawTimestamp = json['timestamp'];
    if (rawTimestamp is int) {
      parsedTimestamp = DateTime.fromMillisecondsSinceEpoch(rawTimestamp);
    } else if (rawTimestamp is String) {
      parsedTimestamp = DateTime.tryParse(rawTimestamp) ?? DateTime.now();
    } else {
      parsedTimestamp = DateTime.now();
    }

    return RiderLocation(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      riderId: json['riderId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['riderId']?.toString() ?? '',
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      timestamp: parsedTimestamp,
      speed: (json['speed'] ?? json['speedKmh'] as num?)?.toDouble() ?? 0.0,
      heading: (json['heading'] as num?)?.toDouble() ?? 0.0,
      altitude: (json['altitude'] as num?)?.toDouble() ?? 0.0,
      speedAccuracy: (json['speedAccuracy'] as num?)?.toDouble() ?? 0.0,
      headingAccuracy: (json['headingAccuracy'] as num?)?.toDouble() ?? 0.0,
      altitudeAccuracy: (json['altitudeAccuracy'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  String toString() {
    return '''RiderLocation(latitude: $latitude, longitude: $longitude, riderId: $riderId, userId: $userId, accuracy: $accuracy, timestamp: $timestamp, speed: $speed, heading: $heading, altitude: $altitude, speedAccuracy: $speedAccuracy, headingAccuracy: $headingAccuracy, altitudeAccuracy: $altitudeAccuracy)''';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RiderLocation &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.riderId == riderId &&
        other.userId == userId &&
        other.accuracy == accuracy &&
        other.timestamp == timestamp &&
        other.speed == speed &&
        other.heading == heading &&
        other.altitude == altitude &&
        other.speedAccuracy == speedAccuracy &&
        other.headingAccuracy == headingAccuracy &&
        other.altitudeAccuracy == altitudeAccuracy;
  }

  @override
  int get hashCode {
    return latitude.hashCode ^
        longitude.hashCode ^
        riderId.hashCode ^
        userId.hashCode ^
        accuracy.hashCode ^
        timestamp.hashCode ^
        speed.hashCode ^
        heading.hashCode ^
        altitude.hashCode ^
        speedAccuracy.hashCode ^
        headingAccuracy.hashCode ^
        altitudeAccuracy.hashCode;
  }
}
