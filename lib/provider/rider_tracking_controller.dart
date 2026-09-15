import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logistico/models/rider_location.dart';
import 'package:logistico/services/phone_location_services.dart';
import 'package:logistico/services/routing_api_services.dart';
import 'package:logistico/services/web_socket_services.dart';

class RiderTrackingController {
  RiderTrackingController({
    required this.riderId,
    required this.locationService,
    required this.socketService,
    required this.routeService,
  });

  final String riderId;
  final PhoneLocationService locationService;
  final LocationWebSocketService socketService;
  final RoutingApiService routeService;

  final ValueNotifier<Position?> currentPosition = ValueNotifier<Position?>(
    null,
  );

  final ValueNotifier<bool> isTracking = ValueNotifier<bool>(false);

  final ValueNotifier<bool> isSocketConnected = ValueNotifier<bool>(false);

  final ValueNotifier<List<LatLng>> plannedRoute = ValueNotifier<List<LatLng>>(
    [],
  );

  StreamSubscription<Position>? _positionSubscription;

  void _onSocketConnectionChanged() {
    isSocketConnected.value = socketService.isConnected;
  }

  Future<void> startTracking() async {
    socketService.isConnectedNotifier.removeListener(_onSocketConnectionChanged);
    socketService.isConnectedNotifier.addListener(_onSocketConnectionChanged);

    await socketService.connect();

    isSocketConnected.value = socketService.isConnected;

    await locationService.start();

    await _positionSubscription?.cancel();

    _positionSubscription = locationService.positions.listen((position) {
      currentPosition.value = position;

      final location = RiderLocation(
        userId: riderId,
        altitudeAccuracy: position.altitudeAccuracy,
        headingAccuracy: position.headingAccuracy,
        riderId: riderId,
        accuracy: position.accuracy,
        speed: position.speed * 3.6,
        heading: position.heading,
        timestamp: position.timestamp,
        latitude: position.latitude,
        longitude: position.longitude,
        altitude: position.altitude,
        speedAccuracy: position.speedAccuracy,
      );

      socketService.send(location.toJson());
    });

    isTracking.value = true;
  }

  Future<void> getPLannedRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final route = await routeService.getRoute(
      origin: origin,
      destination: destination,
    );
    plannedRoute.value = route;
  }

  Future<void> stopTracking() async {
    socketService.isConnectedNotifier.removeListener(_onSocketConnectionChanged);
    await _positionSubscription?.cancel();
    _positionSubscription = null;

    await locationService.stop();

    isTracking.value = false;
  }

  Future<void> dispose() async {
    await stopTracking();
    await socketService.dispose();

    currentPosition.dispose();
    isTracking.dispose();
    isSocketConnected.dispose();
  }
}
