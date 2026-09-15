import 'package:flutter/material.dart';
import '../models/delivery.dart';
import 'delivery_status.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  RiderStatusBar — bottom bar for the rider screen
// ─────────────────────────────────────────────────────────────────────────────

/// Displays the rider avatar, current delivery status message, and an animated
/// call button. Used at the bottom of the **rider** screen.
class RiderStatusBar extends StatefulWidget {
  final DeliveryModel delivery;
  final VoidCallback? onCall;

  const RiderStatusBar({super.key, required this.delivery, this.onCall});

  @override
  State<RiderStatusBar> createState() => _RiderStatusBarState();
}

class _RiderStatusBarState extends State<RiderStatusBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFF0F0F0))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rider avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF1A6B4A), width: 2.5),
              color: const Color(0xFFE8F5EE),
            ),
            child: const Icon(
              Icons.sports_motorsports_rounded,
              color: Color(0xFF1A6B4A),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),

          // Status text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.delivery.statusMessage,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Your order is on the way to you',
                  style: TextStyle(fontSize: 12, color: Color(0xFF8A8A8A)),
                ),
              ],
            ),
          ),

          // Pulsing call button
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) => Transform.scale(
              scale: _pulse.value,
              child: GestureDetector(
                onTap: widget.onCall,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A6B4A),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A6B4A).withValues(alpha: 0.40),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.call_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  CustomerDeliveryPanel — bottom panel for the customer tracking screen
// ─────────────────────────────────────────────────────────────────────────────

/// Dark rounded header (rider info) + white body (ETA + tracking bar + message).
/// Used at the bottom of the **customer tracking** screen.
class CustomerDeliveryPanel extends StatelessWidget {
  final DeliveryModel delivery;

  const CustomerDeliveryPanel({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Dark header ──────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          decoration: const BoxDecoration(
            color: Color(0xFF1C1C1C),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Row(
            children: [
              // Rider avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2E2E2E),
                  border: Border.all(color: const Color(0xFF3A3A3A), width: 2),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFFCCCCCC),
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),

              // Name + star rating
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    delivery.riderName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFFFC107), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        delivery.riderRating.toStringAsFixed(1),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(),

              // Chat icon button
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Color(0xFFE87C3E),
                  size: 20,
                ),
              ),
            ],
          ),
        ),

        // ── White body ───────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Estimated delivery time',
                style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
              ),
              const SizedBox(height: 4),
              Text(
                '${delivery.etaStart} - ${delivery.etaEnd}',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              TrackingStatusBar(currentStep: delivery.currentStep),
              const SizedBox(height: 12),
              Text(
                delivery.statusMessage,
                style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
