// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:logistico/provider/gps_simulator.dart';

// class TrackingBackground extends StatefulWidget {
//   const TrackingBackground({super.key, required this.simulator});

//   final RiderLocationSimulator simulator;

//   @override
//   State<TrackingBackground> createState() => _TrackingBackgroundState();
// }

// class _TrackingBackgroundState extends State<TrackingBackground> {
//   GoogleMapController? _mapController;

//   // Customer's delivery destination.
//   static const LatLng customerLocation = LatLng(6.594300, 3.340440);

//   @override
//   void initState() {
//     super.initState();
//     widget.simulator.riderPosition.addListener(_onLocationChanged);
//   }

//   void _onLocationChanged() {
//     final position = widget.simulator.riderPosition.value;
//     if (position == null || !mounted) return;
//     _mapController?.animateCamera(CameraUpdate.newLatLng(position));
//   }

//   @override
//   void dispose() {
//     widget.simulator.riderPosition.removeListener(_onLocationChanged);
//     _mapController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final routes = widget.simulator.route;
//     final initialPos = widget.simulator.riderPosition.value ?? customerLocation;

//     return ValueListenableBuilder<LatLng?>(
//       valueListenable: widget.simulator.riderPosition,
//       builder: (context, riderPosition, _) {
//         return GoogleMap(
//           onMapCreated: (controller) {
//             _mapController = controller;
//           },
//           initialCameraPosition: CameraPosition(target: initialPos, zoom: 14.5),
//           markers: {
//             if (riderPosition != null) ...{
//               Marker(
//                 markerId: const MarkerId('rider_marker'),
//                 position: riderPosition,
//                 icon: BitmapDescriptor.defaultMarkerWithHue(
//                   BitmapDescriptor.hueOrange,
//                 ),
//                 infoWindow: const InfoWindow(
//                   title: 'Rider',
//                   snippet: 'Your delivery rider is on the way',
//                 ),
//               ),
//             },
//             const Marker(
//               markerId: MarkerId('customer_marker'),
//               position: customerLocation,
//               icon: BitmapDescriptor.defaultMarker,
//               infoWindow: InfoWindow(
//                 title: 'Customer',
//                 snippet: 'Delivery destination',
//               ),
//             ),
//           },
//           polylines: {
//             if (widget.simulator.currentIndex < routes.length - 1)
//               Polyline(
//                 polylineId: const PolylineId('delivery_route'),
//                 points: widget.simulator.currentIndex <= 0
//                     ? []
//                     : routes.sublist(widget.simulator.currentIndex),
//                 color: const Color(0xFFE87C3E),
//                 width: 5,
//                 startCap: Cap.roundCap,
//                 endCap: Cap.roundCap,
//               ),
//           },
//           myLocationButtonEnabled: false,
//           zoomControlsEnabled: false,
//         );
//       },
//     );
//   }
// }

//------Using WebSocket------//
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logistico/provider/customer_tracking_controller.dart';
import 'package:logistico/services/routing_api_services.dart';
import 'package:logistico/services/web_socket_services.dart';

class TrackingBackground extends StatefulWidget {
  const TrackingBackground({super.key});

  @override
  State<TrackingBackground> createState() => _TrackingBackgroundState();
}

class _TrackingBackgroundState extends State<TrackingBackground> {
  GoogleMapController? _mapController;
  late final CustomerTrackingController controller;

  // Origin (Pickup) & Destination (Customer location)
  static const LatLng pickupLocation = LatLng(37.785834, -122.406417);
  static const LatLng customerLocation = LatLng(37.781394, -122.413181);

  @override
  void initState() {
    super.initState();
    controller = CustomerTrackingController(
      socketService: LocationWebSocketService(
        socketUrl: LocationWebSocketService.defaultLocalSocketUrl,
      ),
      routeService: RoutingApiService(
        googleApiKey: dotenv.env['GOOGLE_MAPS_DIRECTIONS_API_KEY'] ?? '',
      ),
      expectedRiderId: "rider_123",
    );
    controller.riderPosition.addListener(_onLocationChanged);

    _loadInitialRoute();
    controller.startListening();
  }

  Future<void> _loadInitialRoute() async {
    try {
      await controller.getPLannedRoute(
        origin: pickupLocation,
        destination: customerLocation,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not load route: $error')));
    }
  }

  void _onLocationChanged() {
    final position = controller.riderPosition.value;
    if (position == null || !mounted) return;
    _mapController?.animateCamera(CameraUpdate.newLatLng(position));
  }

  @override
  void dispose() {
    controller.riderPosition.removeListener(_onLocationChanged);
    controller.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<LatLng>>(
      valueListenable: controller.plannedRoute,
      builder: (context, routePoints, _) {
        return ValueListenableBuilder<LatLng?>(
          valueListenable: controller.riderPosition,
          builder: (context, riderPosition, _) {
            final markers = <Marker>{
              Marker(
                markerId: const MarkerId('pickup_marker'),
                position: pickupLocation,
                infoWindow: const InfoWindow(
                  title: 'Store / Pickup',
                  snippet: 'Order origin',
                ),
              ),
              const Marker(
                markerId: MarkerId('customer_marker'),
                position: customerLocation,
                infoWindow: InfoWindow(
                  title: 'Delivery Address',
                  snippet: 'Your location',
                ),
              ),
            };

            if (riderPosition != null) {
              markers.add(
                Marker(
                  markerId: const MarkerId('rider_marker'),
                  position: riderPosition,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueOrange,
                  ),
                  rotation: controller.riderHeading.value,
                  infoWindow: InfoWindow(
                    title: 'Rider',
                    snippet:
                        'Speed: ${controller.riderSpeedKmh.value.toStringAsFixed(1)} km/h',
                  ),
                ),
              );
            }

            final polylines = <Polyline>{};
            if (routePoints.isNotEmpty) {
              polylines.add(
                Polyline(
                  polylineId: const PolylineId('delivery_route'),
                  points: routePoints,
                  color: const Color(0xFFE87C3E),
                  width: 5,
                  startCap: Cap.roundCap,
                  endCap: Cap.roundCap,
                ),
              );
            }

            return GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: riderPosition ?? customerLocation,
                zoom: 14.5,
              ),
              markers: markers,
              polylines: polylines,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            );
          },
        );
      },
    );
  }
}
