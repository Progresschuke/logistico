import 'package:flutter/material.dart';

/// Floating ETA chip shown on the map in the rider screen.
///
/// Displays estimated time and distance in a white rounded card.
class DeliveryEtaCard extends StatelessWidget {
  final int minutes;
  final double distanceKm;

  const DeliveryEtaCard({
    super.key,
    required this.minutes,
    required this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Clock icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5EE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.access_time_rounded,
              color: Color(0xFF1A6B4A),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Estimated delivery',
                style: TextStyle(fontSize: 10, color: Color(0xFF9E9E9E)),
              ),
              Row(
                children: [
                  Text(
                    '$minutes min',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '|',
                      style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 18),
                    ),
                  ),
                  Text(
                    '${distanceKm.toStringAsFixed(1)} km away',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4A4A4A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
