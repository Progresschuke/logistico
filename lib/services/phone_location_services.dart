import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class PhoneLocationService {
  StreamSubscription<Position>? _positionSubscription;

  final StreamController<Position> _positionController =
      StreamController<Position>.broadcast();

  Stream<Position> get positions => _positionController.stream;
  LocationSettings get _locationSettings {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,

        // Rider must move at least 5 metres
        // before another location is produced.
        distanceFilter: 5,

        // Desired update interval.
        intervalDuration: Duration(seconds: 5),

        foregroundNotificationConfig: ForegroundNotificationConfig(
          notificationTitle: 'Logistico is tracking your location',

          notificationText: 'Your location is being shared with the customer.',

          notificationChannelName: 'Rider Location',

          enableWakeLock: true,

          setOngoing: true,
        ),
      );
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,

        distanceFilter: 5,

        activityType: ActivityType.automotiveNavigation,

        // Important for background tracking.
        allowBackgroundLocationUpdates: true,

        // For a delivery rider, we don't want
        // Core Location automatically pausing
        // while the rider is moving.
        pauseLocationUpdatesAutomatically: false,

        // Shows the iOS background location indicator.
        showBackgroundLocationIndicator: true,
      );
    }

    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );
  }

  Future<bool> requestPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return false;
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<void> start() async {
    final hasPermission = await requestPermission();

    if (!hasPermission) {
      throw Exception('Location permission was not granted');
    }

    await _positionSubscription?.cancel();

    _positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: _locationSettings,
        ).listen(
          (position) {
            print(position);
            _positionController.add(position);
          },
          onError: (Object error, StackTrace stackTrace) {
            _positionController.addError(error);
          },
        );
  }

  Future<void> stop() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  Future<void> dispose() async {
    await stop();
    await _positionController.close();
  }
}
