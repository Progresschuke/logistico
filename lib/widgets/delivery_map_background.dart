// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:logistico/provider/gps_simulator.dart';

// class DeliveryMapp extends StatefulWidget {
//   const DeliveryMapp({super.key, required this.simulator});

//   final RiderLocationSimulator simulator;

//   @override
//   State<DeliveryMapp> createState() => _DeliveryMappState();
// }

// class _DeliveryMappState extends State<DeliveryMapp> {
//   GoogleMapController? _mapController;

//   // Fixed customer location.
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
//     final initialPos =
//         widget.simulator.riderPosition.value ??
//         (routes.isNotEmpty ? routes.first : customerLocation);

//     return Column(
//       children: [
//         Expanded(
//           child: ValueListenableBuilder<LatLng?>(
//             valueListenable: widget.simulator.riderPosition,
//             builder: (context, riderPosition, _) {
//               return GoogleMap(
//                 initialCameraPosition: CameraPosition(
//                   target: initialPos,
//                   zoom: 14.5,
//                 ),
//                 markers: {
//                   if (riderPosition != null) ...{
//                     Marker(
//                       markerId: const MarkerId('rider_marker'),
//                       position: riderPosition,
//                       icon: BitmapDescriptor.defaultMarkerWithHue(
//                         BitmapDescriptor.hueGreen,
//                       ),
//                       infoWindow: const InfoWindow(
//                         title: 'Rider',
//                         snippet: 'Your current location',
//                       ),
//                     ),
//                   },
//                   const Marker(
//                     markerId: MarkerId('customer_marker'),
//                     position: customerLocation,
//                     icon: BitmapDescriptor.defaultMarker,
//                     infoWindow: InfoWindow(
//                       title: 'Customer',
//                       snippet: 'Delivery destination',
//                     ),
//                   ),
//                 },
//                 polylines: {
//                   if (widget.simulator.currentIndex < routes.length - 1)
//                     Polyline(
//                       polylineId: const PolylineId('delivery_route'),
//                       points: routes.sublist(widget.simulator.currentIndex),
//                       color: const Color(0xFF1A6B4A),
//                       startCap: Cap.roundCap,
//                       endCap: Cap.roundCap,
//                       width: 4,
//                     ),
//                 },
//                 onMapCreated: (controller) {
//                   _mapController = controller;
//                 },
//                 myLocationButtonEnabled: false,
//                 zoomControlsEnabled: true,
//               );
//             },
//           ),
//         ),

//         // Simulation controls
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withValues(alpha: 0.08),
//                 blurRadius: 10,
//                 offset: const Offset(0, -3),
//               ),
//             ],
//           ),
//           child: ValueListenableBuilder<bool>(
//             valueListenable: widget.simulator.isMoving,
//             builder: (context, isMoving, _) {
//               return Row(
//                 children: [
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: isMoving
//                             ? const Color(0xFFE87C3E)
//                             : const Color(0xFF1A6B4A),
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       onPressed: () {
//                         if (isMoving) {
//                           widget.simulator.pause();
//                         } else {
//                           widget.simulator.start();
//                         }
//                       },
//                       icon: Icon(
//                         isMoving
//                             ? Icons.pause_rounded
//                             : Icons.play_arrow_rounded,
//                       ),
//                       label: Text(
//                         isMoving ? 'Pause Simulation' : 'Start Simulation',
//                         style: const TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: OutlinedButton.icon(
//                       style: OutlinedButton.styleFrom(
//                         foregroundColor: const Color(0xFF444444),
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         side: const BorderSide(color: Color(0xFFCCCCCC)),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       onPressed: () {
//                         widget.simulator.reset();
//                         if (routes.isNotEmpty) {
//                           _mapController?.animateCamera(
//                             CameraUpdate.newLatLng(routes.first),
//                           );
//                         }
//                       },
//                       icon: const Icon(Icons.replay_rounded, size: 20),
//                       label: const Text(
//                         'Reset',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }

//--------Using GPS--------
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:logistico/provider/rider_tracking_controller.dart';

// class DeliveryMapp extends StatefulWidget {
//   const DeliveryMapp({super.key, required this.riderTrackingController});

//   final RiderTrackingController riderTrackingController;

//   @override
//   State<DeliveryMapp> createState() => _DeliveryMappState();
// }

// class _DeliveryMappState extends State<DeliveryMapp> {
//   GoogleMapController? _mapController;

//   // Fixed customer location.
//   static const LatLng customerLocation = LatLng(6.594300, 3.340440);

//   @override
//   void initState() {
//     super.initState();
//     widget.riderTrackingController.currentPosition.addListener(
//       _onLocationChanged,
//     );
//   }

//   void _onLocationChanged() {
//     final position = widget.riderTrackingController.currentPosition.value;
//     if (position == null || !mounted) return;
//     final riderLatLng = LatLng(position.latitude, position.longitude);
//     _mapController?.animateCamera(CameraUpdate.newLatLng(riderLatLng));
//     setState(() {});
//   }

//   @override
//   void dispose() {
//     widget.riderTrackingController.currentPosition.removeListener(
//       _onLocationChanged,
//     );
//     _mapController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final routes = widget.simulator.route;
//     final initialPos =
//         widget.simulator.riderPosition.value ??
//         (routes.isNotEmpty ? routes.first : customerLocation);

//     return Column(
//       children: [
//         Expanded(
//           child: ValueListenableBuilder<LatLng?>(
//             valueListenable: widget.simulator.riderPosition,
//             builder: (context, riderPosition, _) {
//               return GoogleMap(
//                 initialCameraPosition: CameraPosition(
//                   target: initialPos,
//                   zoom: 14.5,
//                 ),
//                 markers: {
//                   if (riderPosition != null) ...{
//                     Marker(
//                       markerId: const MarkerId('rider_marker'),
//                       position: riderPosition,
//                       icon: BitmapDescriptor.defaultMarkerWithHue(
//                         BitmapDescriptor.hueGreen,
//                       ),
//                       infoWindow: const InfoWindow(
//                         title: 'Rider',
//                         snippet: 'Your current location',
//                       ),
//                     ),
//                   },
//                   const Marker(
//                     markerId: MarkerId('customer_marker'),
//                     position: customerLocation,
//                     icon: BitmapDescriptor.defaultMarker,
//                     infoWindow: InfoWindow(
//                       title: 'Customer',
//                       snippet: 'Delivery destination',
//                     ),
//                   ),
//                 },
//                 polylines: {
//                   if (widget.simulator.currentIndex < routes.length - 1)
//                     Polyline(
//                       polylineId: const PolylineId('delivery_route'),
//                       points: routes.sublist(widget.simulator.currentIndex),
//                       color: const Color(0xFF1A6B4A),
//                       startCap: Cap.roundCap,
//                       endCap: Cap.roundCap,
//                       width: 4,
//                     ),
//                 },
//                 onMapCreated: (controller) {
//                   _mapController = controller;
//                 },
//                 myLocationButtonEnabled: false,
//                 zoomControlsEnabled: true,
//               );
//             },
//           ),
//         ),

//         // Simulation controls
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withValues(alpha: 0.08),
//                 blurRadius: 10,
//                 offset: const Offset(0, -3),
//               ),
//             ],
//           ),
//           child: ValueListenableBuilder<bool>(
//             valueListenable: widget.simulator.isMoving,
//             builder: (context, isMoving, _) {
//               return Row(
//                 children: [
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: isMoving
//                             ? const Color(0xFFE87C3E)
//                             : const Color(0xFF1A6B4A),
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       onPressed: () {
//                         if (isMoving) {
//                           widget.simulator.pause();
//                         } else {
//                           widget.simulator.start();
//                         }
//                       },
//                       icon: Icon(
//                         isMoving
//                             ? Icons.pause_rounded
//                             : Icons.play_arrow_rounded,
//                       ),
//                       label: Text(
//                         isMoving ? 'Pause Simulation' : 'Start Simulation',
//                         style: const TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: OutlinedButton.icon(
//                       style: OutlinedButton.styleFrom(
//                         foregroundColor: const Color(0xFF444444),
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         side: const BorderSide(color: Color(0xFFCCCCCC)),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       onPressed: () {
//                         widget.simulator.reset();
//                         if (routes.isNotEmpty) {
//                           _mapController?.animateCamera(
//                             CameraUpdate.newLatLng(routes.first),
//                           );
//                         }
//                       },
//                       icon: const Icon(Icons.replay_rounded, size: 20),
//                       label: const Text(
//                         'Reset',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logistico/provider/rider_tracking_controller.dart';
import 'package:logistico/services/phone_location_services.dart';
import 'package:logistico/services/routing_api_services.dart';
import 'package:logistico/services/web_socket_services.dart';

class DeliveryMapp extends StatefulWidget {
  const DeliveryMapp({super.key});

  @override
  State<DeliveryMapp> createState() => _DeliveryMappState();
}

class _DeliveryMappState extends State<DeliveryMapp> {
  late final RiderTrackingController controller;

  GoogleMapController? _mapController;

  final LatLng pickupLocation = const LatLng(37.785834, -122.406417);

  final LatLng destinationLocation = const LatLng(37.781394, -122.413181);

  @override
  void initState() {
    super.initState();

    controller = RiderTrackingController(
      riderId: 'rider_123',
      locationService: PhoneLocationService(),
      socketService: LocationWebSocketService(
        socketUrl: LocationWebSocketService.defaultLocalSocketUrl,
      ),
      routeService: RoutingApiService(
        googleApiKey: dotenv.env['GOOGLE_MAPS_DIRECTIONS_API_KEY'] ?? '',
      ),
    );

    _loadInitialRoute();
  }

  Future<void> _loadInitialRoute() async {
    try {
      await controller.getPLannedRoute(
        origin: pickupLocation,
        destination: destinationLocation,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not load route: $error')));
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rider Tracking')),
      body: Stack(
        children: [
          ValueListenableBuilder<List<LatLng>>(
            valueListenable: controller.plannedRoute,
            builder: (context, routePoints, child) {
              return ValueListenableBuilder<Position?>(
                valueListenable: controller.currentPosition,
                builder: (context, position, child) {
                  final markers = <Marker>{
                    Marker(
                      markerId: const MarkerId('pickup'),
                      position: pickupLocation,
                      infoWindow: const InfoWindow(title: 'Pickup'),
                    ),
                    Marker(
                      markerId: const MarkerId('destination'),
                      position: destinationLocation,
                      infoWindow: const InfoWindow(title: 'Destination'),
                    ),
                  };

                  if (position != null) {
                    markers.add(
                      Marker(
                        markerId: const MarkerId('rider'),
                        position: LatLng(position.latitude, position.longitude),
                        rotation: position.heading,
                        infoWindow: const InfoWindow(title: 'Rider'),
                      ),
                    );
                  }

                  final polylines = <Polyline>{};

                  if (routePoints.isNotEmpty) {
                    polylines.add(
                      Polyline(
                        polylineId: const PolylineId('planned_route'),
                        points: routePoints,
                        color: Colors.blue,
                        width: 6,
                      ),
                    );
                  }

                  return GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: pickupLocation,
                      zoom: 13,
                    ),
                    markers: markers,
                    polylines: polylines,
                    myLocationEnabled: false,
                    onMapCreated: (mapController) {
                      _mapController = mapController;
                    },
                  );
                },
              );
            },
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ValueListenableBuilder<bool>(
                  valueListenable: controller.isTracking,
                  builder: (context, isTracking, child) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isTracking
                              ? 'Tracking is active'
                              : 'Tracking is stopped',
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isTracking
                                ? controller.stopTracking
                                : controller.startTracking,
                            child: Text(
                              isTracking ? 'Stop Tracking' : 'Start Tracking',
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
