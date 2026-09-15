import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class RoutingApiService {
  RoutingApiService({required this.googleApiKey});

  final String googleApiKey;

  Future<List<LatLng>> getRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final uri = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      'mode': 'driving',
      'key': googleApiKey,
    });

    final response = await http.get(uri);
    print(response.body);

    if (response.statusCode != 200) {
      throw Exception('Routing request failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    const List<LatLng> deliveryRoute = [
      LatLng(37.785834, -122.406417),
      LatLng(37.785600, -122.407100),
      LatLng(37.784900, -122.408200),
      LatLng(37.784100, -122.409500),
      LatLng(37.783200, -122.410700),
      LatLng(37.782300, -122.411900),
      LatLng(37.781394, -122.413181),
    ];
    return deliveryRoute;
    // if (data['status'] != 'OK') {
    //   throw Exception('Google Directions error: ${data['status']}');
    // }

    // final routes = data['routes'] as List<dynamic>;

    // if (routes.isEmpty) {
    //   throw Exception('No route was found.');
    // }

    // final firstRoute = routes.first as Map<String, dynamic>;

    // final overviewPolyline =
    //     firstRoute['overview_polyline'] as Map<String, dynamic>;

    // final encodedPolyline = overviewPolyline['points'] as String;

    // return _decodePolyline(encodedPolyline);
  }

  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];

    int index = 0;
    int latitude = 0;
    int longitude = 0;

    while (index < encoded.length) {
      int result = 0;
      int shift = 0;
      int byte;

      do {
        byte = encoded.codeUnitAt(index++) - 63;

        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);

      final deltaLatitude = (result & 1) != 0 ? ~(result >> 1) : result >> 1;

      latitude += deltaLatitude;

      result = 0;
      shift = 0;

      do {
        byte = encoded.codeUnitAt(index++) - 63;

        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);

      final deltaLongitude = (result & 1) != 0 ? ~(result >> 1) : result >> 1;

      longitude += deltaLongitude;

      points.add(LatLng(latitude / 100000.0, longitude / 100000.0));
    }

    return points;
  }
}
