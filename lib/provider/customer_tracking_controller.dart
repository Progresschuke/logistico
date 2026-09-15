import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logistico/models/rider_location.dart';
import 'package:logistico/services/routing_api_services.dart';
import 'package:logistico/services/web_socket_services.dart';

class CustomerTrackingController {
  CustomerTrackingController({
    required this.socketService,
    required this.expectedRiderId,
    required this.routeService,
  });

  final LocationWebSocketService socketService;
  final String expectedRiderId;
  final RoutingApiService routeService;

  final ValueNotifier<LatLng?> riderPosition = ValueNotifier<LatLng?>(null);

  final ValueNotifier<double> riderSpeedKmh = ValueNotifier<double>(0);

  final ValueNotifier<double> riderHeading = ValueNotifier<double>(0);

  final ValueNotifier<List<LatLng>> plannedRoute = ValueNotifier<List<LatLng>>(
    [],
  );

  StreamSubscription<Map<String, dynamic>>? _messageSubscription;

  Future<void> startListening() async {
    await socketService.connect();

    await _messageSubscription?.cancel();

    _messageSubscription = socketService.messages.listen((message) {
      if (message['type'] != 'rider_location') {
        return;
      }

      final riderId = message['riderId'];

      if (riderId != expectedRiderId) {
        return;
      }

      final location = RiderLocation.fromJson(message);

      print(location);
      riderPosition.value = LatLng(location.latitude, location.longitude);

      riderSpeedKmh.value = location.speed;
      riderHeading.value = location.heading;
    });
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

  Future<void> dispose() async {
    await _messageSubscription?.cancel();

    riderPosition.dispose();
    riderSpeedKmh.dispose();
    riderHeading.dispose();
  }
}
