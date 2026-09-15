import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Data
// ─────────────────────────────────────────────────────────────────────────────

/// A single step used by [DeliveryStatusStepper].
class DeliveryStatusStep {
  final String label;
  final IconData icon;
  const DeliveryStatusStep({required this.label, required this.icon});
}

/// Default steps for the rider tracking screen.
const List<DeliveryStatusStep> kRiderSteps = [
  DeliveryStatusStep(label: 'Order\nConfirmed', icon: Icons.check),
  DeliveryStatusStep(label: 'Preparing', icon: Icons.check),
  DeliveryStatusStep(label: 'Out for\nDelivery', icon: Icons.electric_moped),
  DeliveryStatusStep(label: 'Delivered', icon: Icons.inventory_2_outlined),
];

// ─────────────────────────────────────────────────────────────────────────────
//  DeliveryStatusStepper — circular badge stepper (rider screen)
// ─────────────────────────────────────────────────────────────────────────────

/// Circular-badge order stepper with animated pulse on the active step.
/// Used in the **rider** screen.
class DeliveryStatusStepper extends StatefulWidget {
  final List<DeliveryStatusStep> steps;
  final int currentStep;

  const DeliveryStatusStepper({
    super.key,
    required this.steps,
    required this.currentStep,
  });

  @override
  State<DeliveryStatusStepper> createState() => _DeliveryStatusStepperState();
}

class _DeliveryStatusStepperState extends State<DeliveryStatusStepper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Row(
        children: List.generate(widget.steps.length, (i) {
          final isCompleted = i < widget.currentStep;
          final isActive = i == widget.currentStep;
          final isLast = i == widget.steps.length - 1;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      // Badge
                      AnimatedBuilder(
                        animation: _pulse,
                        builder: (_, __) => Transform.scale(
                          scale: isActive ? _pulse.value : 1.0,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: (isCompleted || isActive)
                                  ? const Color(0xFF1A6B4A)
                                  : const Color(0xFFE0E0E0),
                              shape: BoxShape.circle,
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF1A6B4A).withValues(alpha: 0.35),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Icon(
                              widget.steps[i].icon,
                              color: (isCompleted || isActive)
                                  ? Colors.white
                                  : const Color(0xFFAAAAAA),
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Label
                      Text(
                        widget.steps[i].label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: (isCompleted || isActive)
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: (isCompleted || isActive)
                              ? const Color(0xFF1A6B4A)
                              : const Color(0xFFAAAAAA),
                        ),
                      ),
                    ],
                  ),
                ),
                // Connector line
                if (!isLast)
                  Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.only(bottom: 22),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: i < widget.currentStep
                            ? const Color(0xFF1A6B4A)
                            : const Color(0xFFE0E0E0),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TrackingStatusBar — minimal icon row (customer tracking screen)
// ─────────────────────────────────────────────────────────────────────────────

/// Minimal four-icon status row with connecting lines.
/// Used inside [CustomerDeliveryPanel] in the **tracking** screen.
class TrackingStatusBar extends StatelessWidget {
  final int currentStep;

  static const List<IconData> _icons = [
    Icons.receipt_long_rounded,
    Icons.soup_kitchen_rounded,
    Icons.shopping_bag_outlined,
    Icons.location_on_outlined,
  ];

  const TrackingStatusBar({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFFE87C3E);
    const doneColor = Color(0xFF999999);
    const pendingColor = Color(0xFFCCCCCC);
    const lineActive = Color(0xFFE87C3E);
    const linePending = Color(0xFFE0E0E0);

    // Build alternating: Icon, Line(Expanded), Icon, Line, Icon, Line, Icon
    return Row(
      children: List.generate(_icons.length * 2 - 1, (i) {
        if (i.isEven) {
          final idx = i ~/ 2;
          final isActive = idx == currentStep;
          final isDone = idx < currentStep;
          return Icon(
            _icons[idx],
            size: 24,
            color: isActive ? activeColor : isDone ? doneColor : pendingColor,
          );
        } else {
          final lineIdx = i ~/ 2;
          return Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              color: lineIdx < currentStep ? lineActive : linePending,
            ),
          );
        }
      }),
    );
  }
}
