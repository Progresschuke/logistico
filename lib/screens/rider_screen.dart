// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:logistico/provider/gps_simulator.dart';
// import 'package:logistico/widgets/delivery_map_background.dart';
// import 'package:logistico/widgets/eta_card.dart';
// import '../models/delivery.dart';
// import '../widgets/delivery_info_card.dart';
// import '../widgets/delivery_map.dart';
// import '../widgets/delivery_status.dart';
// import '../widgets/rider_info_card.dart';

// /// Screen for tracking delivery from the rider's perspective / active order view.
// class RiderScreen extends StatefulWidget {
//   final DeliveryModel delivery;
//   final RiderLocationSimulator simulator;

//   const RiderScreen({
//     super.key,
//     this.delivery = DeliveryModel.riderSample,
//     required this.simulator,
//   });

//   @override
//   State<RiderScreen> createState() => _RiderScreenState();
// }

// class _RiderScreenState extends State<RiderScreen> {
//   late DeliveryModel _delivery;

//   @override
//   void initState() {
//     super.initState();
//     _delivery = widget.delivery;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               // ── App Bar Header ──────────────────────────────────────
//               _buildAppBar(context),
//               // ── Map + Simulation controls ───────────────────────────
//               Expanded(child: DeliveryMapp(simulator: widget.simulator)),

//               // ── Step Progress Indicator ────────────────────────────
//               DeliveryStatusStepper(
//                 steps: kRiderSteps,
//                 currentStep: _delivery.currentStep,
//               ),
//             ],
//             //     // ── Interactive Animated Map ───────────────────────────
//             //     Expanded(
//             //       child: DeliveryMap(
//             //         mapStyle: MapStyle.city,
//             //         topLeftOverlay: DeliveryEtaCard(
//             //           minutes: _delivery.estimatedMinutes,
//             //           distanceKm: _delivery.distanceKm,
//             //         ),
//             //         topRightOverlay: _buildDestinationBadge(),
//             //         showLocationButton: true,
//             //         onLocationTap: () {
//             //           ScaffoldMessenger.of(context).showSnackBar(
//             //             const SnackBar(
//             //               content: Text('Centered on your current location'),
//             //               duration: Duration(seconds: 1),
//             //             ),
//             //           );
//             //         },
//             //       ),
//             //     ),

//             //     // ── Step Progress Indicator ────────────────────────────
//             //     DeliveryStatusStepper(
//             //       steps: kRiderSteps,
//             //       currentStep: _delivery.currentStep,
//             //     ),

//             //     // ── Bottom Rider Status & Call Bar ─────────────────────
//             //     RiderStatusBar(
//             //       delivery: _delivery,
//             //       onCall: () {
//             //         ScaffoldMessenger.of(context).showSnackBar(
//             //           SnackBar(
//             //             content: Text('Calling rider ${_delivery.riderName}...'),
//             //             duration: const Duration(seconds: 2),
//             //           ),
//             //         );
//             //       },
//             //     ),
//             //   ],
//             // ),
//           ),

//           Positioned(
//             top: 125,
//             left: 10,
//             child: CustomerEtaCard(simulator: widget.simulator),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAppBar(BuildContext context) {
//     return Container(
//       color: const Color(0xFF1A6B4A),
//       padding: EdgeInsets.only(
//         top: MediaQuery.of(context).padding.top + 8,
//         left: 16,
//         right: 16,
//         bottom: 14,
//       ),
//       child: Row(
//         children: [
//           // Back button
//           GestureDetector(
//             onTap: () {
//               if (Navigator.canPop(context)) {
//                 Navigator.pop(context);
//               }
//             },
//             child: const Icon(
//               Icons.arrow_back_rounded,
//               color: Colors.white,
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: 12),

//           // Store avatar
//           Container(
//             width: 42,
//             height: 42,
//             decoration: BoxDecoration(
//               color: const Color(0xFF23845C),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: const Icon(
//               Icons.storefront_rounded,
//               color: Colors.white,
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: 12),

//           // Store name and order ID
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Row(
//                   children: [
//                     Flexible(
//                       child: Text(
//                         _delivery.storeName,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 15,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     if (_delivery.storeVerified) ...[
//                       const SizedBox(width: 6),
//                       const Icon(
//                         Icons.check_circle,
//                         color: Color(0xFF4CAF50),
//                         size: 16,
//                       ),
//                     ],
//                   ],
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   'Order #${_delivery.orderId}',
//                   style: const TextStyle(
//                     color: Color(0xFFB2DFC7),
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Share button
//           IconButton(
//             icon: const Icon(
//               Icons.share_outlined,
//               color: Colors.white,
//               size: 22,
//             ),
//             onPressed: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Order link copied to clipboard')),
//               );
//             },
//           ),

//           // More options
//           IconButton(
//             icon: const Icon(
//               Icons.more_vert_rounded,
//               color: Colors.white,
//               size: 22,
//             ),
//             onPressed: () {},
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDestinationBadge() {
//     return Container(
//       width: 44,
//       height: 44,
//       decoration: BoxDecoration(
//         color: const Color(0xFF1A6B4A),
//         shape: BoxShape.circle,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.2),
//             blurRadius: 8,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: const Icon(Icons.home_rounded, color: Colors.white, size: 22),
//     );
//   }
// }

//-----------Using GPS for tracking-------------//

import 'package:flutter/material.dart';
import 'package:logistico/widgets/delivery_map_background.dart';
import '../models/delivery.dart';
import '../widgets/delivery_status.dart';

/// Screen for tracking delivery from the rider's perspective / active order view.
class RiderScreen extends StatefulWidget {
  final DeliveryModel delivery;

  const RiderScreen({super.key, this.delivery = DeliveryModel.riderSample});

  @override
  State<RiderScreen> createState() => _RiderScreenState();
}

class _RiderScreenState extends State<RiderScreen> {
  late DeliveryModel _delivery;

  @override
  void initState() {
    super.initState();
    _delivery = widget.delivery;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // ── App Bar Header ──────────────────────────────────────
              _buildAppBar(context),

              // ── Map + Simulation controls ───────────────────────────
              const Expanded(child: DeliveryMapp()),

              // ── Step Progress Indicator ────────────────────────────
              DeliveryStatusStepper(
                steps: kRiderSteps,
                currentStep: _delivery.currentStep,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: const Color(0xFF1A6B4A),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 14,
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Store avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF23845C),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Store name and order ID
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _delivery.storeName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_delivery.storeVerified) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF4CAF50),
                        size: 16,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Order #${_delivery.orderId}',
                  style: const TextStyle(
                    color: Color(0xFFB2DFC7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Share button
          IconButton(
            icon: const Icon(
              Icons.share_outlined,
              color: Colors.white,
              size: 22,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order link copied to clipboard')),
              );
            },
          ),

          // More options
          IconButton(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: Colors.white,
              size: 22,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
