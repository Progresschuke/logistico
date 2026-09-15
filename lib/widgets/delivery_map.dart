import 'dart:math' as math;
import 'package:flutter/material.dart';

/// The visual style of the map background + route.
enum MapStyle {
  /// City grid map with green route — used in the rider screen.
  city,

  /// Coastal map with red + blue split route — used in the customer tracking screen.
  coastal,
}

// ─────────────────────────────────────────────────────────────────────────────
//  DeliveryMap — reusable animated map widget
// ─────────────────────────────────────────────────────────────────────────────

/// A self-contained, animated delivery map. Manages its own animation controller.
///
/// Accepts optional overlay widgets that are placed at the top-left and top-right
/// of the map (e.g., ETA card, home/back button). [overlayTopOffset] can be used
/// to push overlays below the system status bar when the map fills the full screen.
class DeliveryMap extends StatefulWidget {
  final MapStyle mapStyle;
  final Widget? topLeftOverlay;
  final Widget? topRightOverlay;
  final bool showLocationButton;
  final VoidCallback? onLocationTap;

  /// Distance from the top edge at which overlays are placed. Default is 12.
  /// Pass `MediaQuery.of(context).padding.top + 12` when the map is full-screen.
  final double overlayTopOffset;

  const DeliveryMap({
    super.key,
    required this.mapStyle,
    this.topLeftOverlay,
    this.topRightOverlay,
    this.showLocationButton = true,
    this.onLocationTap,
    this.overlayTopOffset = 12,
  });

  @override
  State<DeliveryMap> createState() => _DeliveryMapState();
}

class _DeliveryMapState extends State<DeliveryMap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.0, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = widget.overlayTopOffset;

    return Stack(
      children: [
        // ── Map background ──────────────────────────────────────
        Positioned.fill(
          child: CustomPaint(
            painter: widget.mapStyle == MapStyle.city
                ? _CityMapPainter()
                : _CoastalMapPainter(),
          ),
        ),

        // ── Animated route + rider ──────────────────────────────
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => CustomPaint(
              painter: widget.mapStyle == MapStyle.city
                  ? _CityRoutePainter(progress: _anim.value)
                  : _CoastalRoutePainter(progress: _anim.value),
            ),
          ),
        ),

        // ── Top-left overlay ────────────────────────────────────
        if (widget.topLeftOverlay != null)
          Positioned(top: top, left: 16, child: widget.topLeftOverlay!),

        // ── Top-right overlay ───────────────────────────────────
        if (widget.topRightOverlay != null)
          Positioned(top: top, right: 16, child: widget.topRightOverlay!),

        // ── Current-location button ─────────────────────────────
        if (widget.showLocationButton)
          Positioned(
            bottom: 20,
            right: 16,
            child: GestureDetector(
              onTap: widget.onLocationTap,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.my_location_rounded,
                  color: Color(0xFF1A6B4A),
                  size: 22,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  City Map Painter
// ─────────────────────────────────────────────────────────────────────────────

class _CityMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Base
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFFEDF2EC),
    );

    final roadPaint = Paint()..color = Colors.white;

    // Horizontal roads
    for (double y = 0; y < h; y += h / 6) {
      canvas.drawRect(Rect.fromLTWH(0, y + (h / 6) * 0.4, w, 10), roadPaint);
    }
    // Vertical roads
    for (double x = 0; x < w; x += w / 5) {
      canvas.drawRect(Rect.fromLTWH(x + (w / 5) * 0.5, 0, 10, h), roadPaint);
    }

    // City blocks
    final blockPaint = Paint()..color = const Color(0xFFD6E4D6);
    for (final r in [
      Rect.fromLTWH(10, 20, w * 0.3, h * 0.12),
      Rect.fromLTWH(w * 0.55, 20, w * 0.38, h * 0.10),
      Rect.fromLTWH(10, h * 0.20, w * 0.22, h * 0.14),
      Rect.fromLTWH(w * 0.35, h * 0.18, w * 0.28, h * 0.12),
      Rect.fromLTWH(w * 0.68, h * 0.20, w * 0.28, h * 0.16),
      Rect.fromLTWH(10, h * 0.42, w * 0.38, h * 0.12),
      Rect.fromLTWH(w * 0.50, h * 0.42, w * 0.45, h * 0.10),
      Rect.fromLTWH(10, h * 0.62, w * 0.25, h * 0.18),
      Rect.fromLTWH(w * 0.38, h * 0.62, w * 0.22, h * 0.15),
      Rect.fromLTWH(w * 0.65, h * 0.60, w * 0.30, h * 0.18),
      Rect.fromLTWH(10, h * 0.84, w * 0.42, h * 0.14),
      Rect.fromLTWH(w * 0.55, h * 0.84, w * 0.42, h * 0.14),
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(4)),
        blockPaint,
      );
    }

    // River
    final riverPath = Path()
      ..moveTo(w * 0.62, 0)
      ..lineTo(w * 0.78, 0)
      ..lineTo(w, h * 0.40)
      ..lineTo(w, h * 0.55)
      ..lineTo(w * 0.78, h * 0.55)
      ..lineTo(w * 0.62, 0)
      ..close();
    canvas.drawPath(riverPath, Paint()..color = const Color(0xFFB8D4E8));

    // Park
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.06, h * 0.42, w * 0.25, h * 0.18),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFFA8CBA8),
    );

    _label(canvas, 'Shivaji Park', w * 0.09, h * 0.48, const Color(0xFF4A7A5A), 10);
    _label(canvas, 'City Mall', w * 0.58, h * 0.55, const Color(0xFF3A7AB8), 10);
    _label(canvas, 'MG Road', w * 0.38, h * 0.38, const Color(0xFF888888), 9);
  }

  void _label(Canvas canvas, String text, double x, double y, Color color, double size) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: size, fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Coastal Map Painter
// ─────────────────────────────────────────────────────────────────────────────

class _CoastalMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Land base
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFFEDE8DC),
    );

    // Ocean water — irregular coastal path
    final waterPath = Path()
      ..moveTo(0, 0)
      ..lineTo(w * 0.46, 0)
      ..cubicTo(w * 0.38, h * 0.10, w * 0.30, h * 0.22, w * 0.24, h * 0.36)
      ..cubicTo(w * 0.18, h * 0.50, w * 0.14, h * 0.64, w * 0.12, h * 0.82)
      ..lineTo(w * 0.12, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(waterPath, Paint()..color = const Color(0xFF62BFDC));

    // Coastline edge stroke
    canvas.drawPath(
      waterPath,
      Paint()
        ..color = const Color(0xFF4AAFC8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Elevated hill terrain
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.68, h * 0.60),
        width: w * 0.52,
        height: h * 0.32,
      ),
      Paint()..color = const Color(0xFFD9D4C7),
    );

    // Roads
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Coastal road
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.52, h * 0.02)
        ..quadraticBezierTo(w * 0.40, h * 0.22, w * 0.30, h * 0.38)
        ..quadraticBezierTo(w * 0.22, h * 0.50, w * 0.20, h * 0.58)
        ..quadraticBezierTo(w * 0.24, h * 0.68, w * 0.30, h * 0.75),
      roadPaint,
    );
    canvas.drawLine(Offset(w * 0.26, h * 0.36), Offset(w * 0.80, h * 0.30), roadPaint);
    canvas.drawLine(Offset(w * 0.22, h * 0.52), Offset(w * 0.72, h * 0.50), roadPaint);
    canvas.drawLine(Offset(w * 0.48, h * 0.02), Offset(w * 0.92, h * 0.08), roadPaint);

    // Labels
    _label(canvas, 'Tamarin', w * 0.44, h * 0.36, const Color(0xFF333333), 13);
    _label(canvas, 'La Préneuse', w * 0.22, h * 0.65, const Color(0xFF333333), 11);
    _label(canvas, 'Moustachio Bistro', w * 0.20, h * 0.44, const Color(0xFF555555), 8);
    _label(canvas, 'Le Lataniers Bleue', w * 0.17, h * 0.55, const Color(0xFF555555), 8);
    _label(canvas, 'Tourelle du Tamarin', w * 0.50, h * 0.60, const Color(0xFF666666), 8);
    _label(canvas, 'Tamarina Golf\n& Spa Hotel', w * 0.54, h * 0.04, const Color(0xFF555555), 8);
    _label(canvas, 'Big W', w * 0.80, h * 0.14, const Color(0xFF555555), 10);
    _label(canvas, 'Casa Pizza', w * 0.62, h * 0.24, const Color(0xFF555555), 9);
    _label(canvas, 'Tav', w * 0.46, h * 0.12, const Color(0xFF555555), 9);

    // A3 road sign
    final a3Rect = Rect.fromLTWH(w * 0.80, h * 0.21, 22, 14);
    canvas.drawRect(a3Rect, Paint()..color = Colors.white);
    canvas.drawRect(
      a3Rect,
      Paint()
        ..color = const Color(0xFF4A80B4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    _label(canvas, 'A3', w * 0.806, h * 0.213, const Color(0xFF4A80B4), 9);
  }

  void _label(Canvas canvas, String text, double x, double y, Color color, double size) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: size, fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
//  City Route Painter  (green animated route)
// ─────────────────────────────────────────────────────────────────────────────

class _CityRoutePainter extends CustomPainter {
  final double progress;
  const _CityRoutePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final points = [
      Offset(w * 0.82, h * 0.08), // destination (top-right)
      Offset(w * 0.75, h * 0.22),
      Offset(w * 0.60, h * 0.30),
      Offset(w * 0.52, h * 0.42),
      Offset(w * 0.45, h * 0.55), // rider current position
    ];

    final path = _buildPath(points);

    // Shadow trail
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF1A6B4A).withValues(alpha: 0.35)
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    // Main route
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF1A6B4A)
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );

    // Destination pin
    canvas.drawCircle(points.first, 8, Paint()..color = const Color(0xFF1A6B4A));
    canvas.drawCircle(
      points.first,
      5,
      Paint()..color = const Color(0xFF7FE5B2),
    );

    // Rider position — oscillates back and forth along the route
    final riderT = 1.0 - progress; // reverse: 0 = bottom, 1 = top
    final totalSegs = points.length - 1;
    final pos = riderT * totalSegs;
    final segIdx = pos.floor().clamp(0, totalSegs - 1);
    final segT = pos - segIdx;
    final p0 = points[segIdx];
    final p1 = points[(segIdx + 1).clamp(0, points.length - 1)];
    final riderPos = Offset.lerp(p0, p1, segT)!;
    final angle = math.atan2(p1.dy - p0.dy, p1.dx - p0.dx) - math.pi / 2;

    // Glow
    canvas.drawCircle(
      riderPos + const Offset(0, 8),
      28,
      Paint()
        ..color = const Color(0xFF1A6B4A).withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );

    canvas.save();
    canvas.translate(riderPos.dx, riderPos.dy);
    canvas.rotate(angle);
    _drawRiderIcon(canvas, const Color(0xFF1A6B4A), const Color(0xFF155A3E));
    canvas.restore();
  }

  Path _buildPath(List<Offset> points) {
    final path = Path();
    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        path.moveTo(points[i].dx, points[i].dy);
      } else {
        final prev = points[i - 1];
        final curr = points[i];
        final mid = Offset((prev.dx + curr.dx) / 2, (prev.dy + curr.dy) / 2);
        path.quadraticBezierTo(prev.dx, prev.dy, mid.dx, mid.dy);
      }
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant _CityRoutePainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Coastal Route Painter  (red dashed + blue route, shop bag + drop pin)
// ─────────────────────────────────────────────────────────────────────────────

class _CoastalRoutePainter extends CustomPainter {
  final double progress;
  const _CoastalRoutePainter({required this.progress});

  static const int _splitIdx = 4;

  List<Offset> _waypoints(double w, double h) => [
        Offset(w * 0.56, h * 0.12), // 0: Store (shopping bag)
        Offset(w * 0.44, h * 0.22), // 1
        Offset(w * 0.32, h * 0.33), // 2
        Offset(w * 0.24, h * 0.44), // 3
        Offset(w * 0.22, h * 0.54), // 4: Drop pin (red / blue junction)
        Offset(w * 0.28, h * 0.63), // 5
        Offset(w * 0.32, h * 0.71), // 6: Destination
      ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final pts = _waypoints(w, h);

    final redPts = pts.sublist(0, _splitIdx + 1);
    final bluePts = pts.sublist(_splitIdx);

    // ── Red dashed route (store → junction) ──
    _drawDashed(canvas, _buildPath(redPts), const Color(0xFFE53935), 4.0);

    // ── Blue route (junction → destination) ──
    canvas.drawPath(
      _buildPath(bluePts),
      Paint()
        ..color = const Color(0xFF2196F3)
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );

    // ── Shopping bag at store ──
    _drawShoppingBag(canvas, pts[0]);

    // ── Red drop pin at junction ──
    _drawDropPin(canvas, pts[_splitIdx], const Color(0xFFE53935));

    // ── Animated rider along blue section ──
    final riderPos = _interpolate(bluePts, progress);
    final angle = _angle(bluePts, progress);

    canvas.drawCircle(
      riderPos + const Offset(0, 6),
      24,
      Paint()
        ..color = const Color(0xFF1A6B4A).withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    canvas.save();
    canvas.translate(riderPos.dx, riderPos.dy);
    canvas.rotate(angle);
    _drawRiderIcon(canvas, const Color(0xFF1A6B4A), const Color(0xFF155A3E));
    canvas.restore();
  }

  Path _buildPath(List<Offset> pts) {
    final path = Path();
    path.moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) {
      final prev = pts[i - 1];
      final curr = pts[i];
      final mid = Offset((prev.dx + curr.dx) / 2, (prev.dy + curr.dy) / 2);
      path.quadraticBezierTo(prev.dx, prev.dy, mid.dx, mid.dy);
    }
    path.lineTo(pts.last.dx, pts.last.dy);
    return path;
  }

  void _drawDashed(Canvas canvas, Path path, Color color, double width) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final metrics = path.computeMetrics();
    for (final m in metrics) {
      double d = 0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, d + 8), paint);
        d += 16;
      }
    }
  }

  Offset _interpolate(List<Offset> pts, double t) {
    final segs = pts.length - 1;
    final pos = t * segs;
    final idx = pos.floor().clamp(0, segs - 1);
    return Offset.lerp(pts[idx], pts[(idx + 1).clamp(0, pts.length - 1)], pos - idx)!;
  }

  double _angle(List<Offset> pts, double t) {
    final segs = pts.length - 1;
    final pos = t * segs;
    final idx = pos.floor().clamp(0, segs - 1);
    final p0 = pts[idx];
    final p1 = pts[(idx + 1).clamp(0, pts.length - 1)];
    return math.atan2(p1.dy - p0.dy, p1.dx - p0.dx) - math.pi / 2;
  }

  void _drawDropPin(Canvas canvas, Offset pos, Color color) {
    final paint = Paint()..color = color;
    canvas.drawCircle(pos, 12, paint);
    canvas.drawPath(
      Path()
        ..moveTo(pos.dx - 7, pos.dy + 8)
        ..lineTo(pos.dx + 7, pos.dy + 8)
        ..lineTo(pos.dx, pos.dy + 20)
        ..close(),
      paint,
    );
    canvas.drawCircle(pos, 4.5, Paint()..color = Colors.white);
  }

  void _drawShoppingBag(Canvas canvas, Offset pos) {
    const bagColor = Color(0xFFD4882A);
    const darkBag = Color(0xFFB5721C);

    // Bag body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: pos + const Offset(0, 7), width: 26, height: 20),
        const Radius.circular(3),
      ),
      Paint()..color = bagColor,
    );
    // Inner highlight
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: pos + const Offset(0, 7), width: 22, height: 14),
        const Radius.circular(2),
      ),
      Paint()..color = darkBag,
    );
    // Handle
    canvas.drawPath(
      Path()
        ..moveTo(pos.dx - 6, pos.dy - 4)
        ..cubicTo(
          pos.dx - 6,
          pos.dy - 14,
          pos.dx + 6,
          pos.dy - 14,
          pos.dx + 6,
          pos.dy - 4,
        ),
      Paint()
        ..color = bagColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _CoastalRoutePainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Shared rider icon painter (top-level — accessible to both route painters)
// ─────────────────────────────────────────────────────────────────────────────

void _drawRiderIcon(Canvas canvas, Color primary, Color dark) {
  // Delivery box
  canvas.drawRRect(
    RRect.fromRectAndRadius(const Rect.fromLTWH(-12, -28, 24, 18), const Radius.circular(4)),
    Paint()..color = dark,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(const Rect.fromLTWH(-11, -27, 22, 16), const Radius.circular(3)),
    Paint()..color = primary,
  );

  // Helmet
  canvas.drawCircle(const Offset(0, -34), 9, Paint()..color = primary);
  canvas.drawCircle(const Offset(0, -34), 7, Paint()..color = dark);
  canvas.drawPath(
    Path()
      ..moveTo(-5, -36)
      ..lineTo(5, -36)
      ..lineTo(5, -32)
      ..lineTo(-5, -32)
      ..close(),
    Paint()..color = const Color(0xFF7FE5B2),
  );

  // Scooter body
  canvas.drawPath(
    Path()
      ..moveTo(-16, -6)
      ..lineTo(16, -6)
      ..lineTo(18, 6)
      ..lineTo(-18, 6)
      ..close(),
    Paint()..color = primary,
  );

  // Wheels
  for (final dx in [-14.0, 14.0]) {
    canvas.drawCircle(Offset(dx, 10), 8, Paint()..color = const Color(0xFF0F3D2A));
    canvas.drawCircle(Offset(dx, 10), 4, Paint()..color = primary);
  }
}
