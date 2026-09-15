import 'dart:async';

import 'package:geolocator/geolocator.dart';

class PhoneLocationService {
  StreamSubscription<Position>? _positionSubscription;

  final StreamController<Position> _positionController =
      StreamController<Position>.broadcast();

  Stream<Position> get positions => _positionController.stream;

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

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
    );

    _positionSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
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
