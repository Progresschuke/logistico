// import 'package:flutter/material.dart';
// import 'package:logistico/provider/gps_simulator.dart';
// import 'package:logistico/widgets/eta_card.dart';
// import 'package:logistico/widgets/tracking_background.dart';
// import '../models/delivery.dart';
// import '../widgets/rider_info_card.dart';

// /// Screen for customer delivery tracking with live Google Maps and delivery details panel.
// class TrackingScreen extends StatefulWidget {
//   final DeliveryModel delivery;
//   final RiderLocationSimulator simulator;

//   const TrackingScreen({
//     super.key,
//     this.delivery = DeliveryModel.trackingSample,
//     required this.simulator,
//   });

//   @override
//   State<TrackingScreen> createState() => _TrackingScreenState();
// }

// class _TrackingScreenState extends State<TrackingScreen> {
//   late DeliveryModel _delivery;

//   @override
//   void initState() {
//     super.initState();
//     _delivery = widget.delivery;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final topPadding = MediaQuery.of(context).padding.top;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F8FA),
//       body: Stack(
//         children: [
//           // ── Google Map Background ────────────────────────────────
//           Positioned.fill(
//             child: TrackingBackground(simulator: widget.simulator),
//           ),

//           // ── Top-left Back Button ─────────────────────────────────
//           Positioned(
//             top: topPadding + 12,
//             left: 16,
//             child: _buildBackButton(context),
//           ),
//           Positioned(
//             top: 125,
//             left: 10,
//             child: CustomerEtaCard(simulator: widget.simulator),
//           ),

//           // ── Bottom Customer Delivery Panel ──────────────────────
//           Positioned(
//             left: 16,
//             right: 16,
//             bottom: MediaQuery.of(context).padding.bottom + 16,
//             child: Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(24),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withValues(alpha: 0.18),
//                     blurRadius: 20,
//                     offset: const Offset(0, 8),
//                   ),
//                 ],
//               ),
//               clipBehavior: Clip.antiAlias,
//               child: CustomerDeliveryPanel(delivery: _delivery),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBackButton(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         if (Navigator.canPop(context)) {
//           Navigator.pop(context);
//         }
//       },
//       child: Container(
//         width: 44,
//         height: 44,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(alpha: 0.12),
//               blurRadius: 10,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: const Icon(Icons.arrow_back, color: Color(0xFF222222), size: 20),
//       ),
//     );
//   }
// }

//------Using WebSocket------//

import 'package:flutter/material.dart';
import 'package:logistico/widgets/tracking_background.dart';
import '../models/delivery.dart';
import '../widgets/rider_info_card.dart';

/// Screen for customer delivery tracking with live Google Maps and delivery details panel.
class TrackingScreen extends StatefulWidget {
  final DeliveryModel delivery;

  const TrackingScreen({
    super.key,
    this.delivery = DeliveryModel.trackingSample,
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  late DeliveryModel _delivery;

  @override
  void initState() {
    super.initState();
    _delivery = widget.delivery;
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Stack(
        children: [
          // ── Google Map Background ────────────────────────────────
          const Positioned.fill(child: TrackingBackground()),

          // ── Top-left Back Button ─────────────────────────────────
          Positioned(
            top: topPadding + 12,
            left: 16,
            child: _buildBackButton(context),
          ),
          // Positioned(
          //   top: 125,
          //   left: 10,
          //   child: CustomerEtaCard(simulator: widget.simulator),
          // ),

          // ── Bottom Customer Delivery Panel ──────────────────────
          Positioned(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: CustomerDeliveryPanel(delivery: _delivery),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(Icons.arrow_back, color: Color(0xFF222222), size: 20),
      ),
    );
  }
}
