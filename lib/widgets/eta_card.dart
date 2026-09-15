import 'package:flutter/material.dart';
import 'package:logistico/provider/gps_simulator.dart';

class EtaCard extends StatelessWidget {
  const EtaCard({
    super.key,
    required this.etaMinutes,
    required this.hasArrived,
  });

  final int? etaMinutes;
  final bool hasArrived;

  @override
  Widget build(BuildContext context) {
    final String etaText;

    if (hasArrived) {
      etaText = 'Arrived';
    } else if (etaMinutes == null) {
      etaText = 'Calculating...';
    } else {
      etaText = '$etaMinutes min away';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.access_time, size: 30),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estimated arrival',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  etaText,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerEtaCard extends StatelessWidget {
  final RiderLocationSimulator simulator;

  const CustomerEtaCard({super.key, required this.simulator});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your delivery is on the way',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.access_time),

                const SizedBox(width: 8),

                ValueListenableBuilder<String>(
                  valueListenable: simulator.etaText,
                  builder: (context, etaText, child) {
                    return Text(
                      etaText.contains("Arrived")
                          ? "Arrived"
                          : 'Arriving in $etaText',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),

            ValueListenableBuilder<double>(
              valueListenable: simulator.remainingDistanceMeters,
              builder: (context, distance, child) {
                return Text(
                  '${(distance / 1000).toStringAsFixed(2)} km from destination',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
