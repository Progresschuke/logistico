// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// /// Central singleton/controller class for simulating rider movement along a route.
// class RiderLocationSimulator {
//   final List<LatLng> route;

//   /// Current position of the rider along the route.
//   final ValueNotifier<LatLng?> riderPosition;

//   /// Whether the simulation is actively moving.
//   final ValueNotifier<bool> isMoving = ValueNotifier<bool>(false);

//   Timer? _timer;
//   int _currentIndex = 0;

//   RiderLocationSimulator({required this.route})
//       : riderPosition = ValueNotifier<LatLng?>(
//           route.isNotEmpty ? route.first : null,
//         );

//   int get currentIndex => _currentIndex;
//   bool get isRunning => _timer != null;

//   /// Starts or resumes the simulation.
//   void start() {
//     if (route.isEmpty) return;
//     if (_timer != null) return;

//     // If at the end, restart from the beginning
//     if (_currentIndex >= route.length - 1) {
//       _currentIndex = 0;
//     }

//     riderPosition.value = route[_currentIndex];
//     isMoving.value = true;

//     _timer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
//       _moveToNextPoint();
//     });
//   }

//   /// Pauses the simulation at the current point.
//   void pause() {
//     _timer?.cancel();
//     _timer = null;
//     isMoving.value = false;
//   }

//   /// Toggles between start and pause.
//   void toggle() {
//     if (isMoving.value) {
//       pause();
//     } else {
//       start();
//     }
//   }

//   void _moveToNextPoint() {
//     if (_currentIndex >= route.length - 1) {
//       pause();
//       return;
//     }

//     _currentIndex++;
//     riderPosition.value = route[_currentIndex];
//   }

//   /// Stops and pauses the simulation.
//   void stop() {
//     pause();
//   }

//   /// Resets the rider back to the first point of the route.
//   void reset() {
//     pause();
//     _currentIndex = 0;
//     if (route.isNotEmpty) {
//       riderPosition.value = route.first;
//     }
//   }

//   void dispose() {
//     stop();
//     riderPosition.dispose();
//     isMoving.dispose();
//   }
// }

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RiderLocationSimulator {
  final List<LatLng> route;

  /// Simulated rider speed in meters per second.
  final double riderSpeedMetersPerSecond;

  /// Current rider position.
  final ValueNotifier<LatLng?> riderPosition;

  /// Whether rider is actively moving.
  final ValueNotifier<bool> isMoving = ValueNotifier<bool>(false);

  /// Remaining distance to destination in meters.
  final ValueNotifier<double> remainingDistanceMeters = ValueNotifier<double>(
    0,
  );

  /// Remaining estimated travel time.
  final ValueNotifier<Duration> eta = ValueNotifier<Duration>(Duration.zero);

  /// Formatted ETA text.
  final ValueNotifier<String> etaText = ValueNotifier<String>('Arrived');

  Timer? _timer;

  int _currentIndex = 0;

  late final List<double> _segmentDistances;

  late final List<double> _remainingDistances;

  RiderLocationSimulator({
    required this.route,
    this.riderSpeedMetersPerSecond = 8.33,
  }) : riderPosition = ValueNotifier<LatLng?>(
         route.isNotEmpty ? route.first : null,
       ) {
    _segmentDistances = _calculateSegmentDistances();

    _remainingDistances = _calculateRemainingDistances();

    _updateEta();
  }

  int get currentIndex => _currentIndex;

  bool get isRunning => _timer != null;

  LatLng? get destination => route.isNotEmpty ? route.last : null;

  // ----------------------------------------------------------
  // MOVEMENT
  // ----------------------------------------------------------

  void start() {
    if (route.isEmpty) return;

    if (_timer != null) return;

    if (_currentIndex >= route.length - 1) {
      _currentIndex = 0;
    }

    riderPosition.value = route[_currentIndex];

    isMoving.value = true;

    _updateEta();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _moveToNextPoint();
    });
  }

  void pause() {
    _timer?.cancel();

    _timer = null;

    isMoving.value = false;

    _updateEta();
  }

  void toggle() {
    if (isMoving.value) {
      pause();
    } else {
      start();
    }
  }

  void _moveToNextPoint() {
    if (_currentIndex >= route.length - 1) {
      pause();
      return;
    }

    _currentIndex++;

    riderPosition.value = route[_currentIndex];

    _updateEta();
  }

  void stop() {
    pause();
  }

  void reset() {
    pause();

    _currentIndex = 0;

    if (route.isNotEmpty) {
      riderPosition.value = route.first;
    }

    _updateEta();
  }

  // ----------------------------------------------------------
  // DISTANCE CALCULATION USING GEOLOCATOR
  // ----------------------------------------------------------

  /// Calculates distance between every consecutive
  /// route point using Geolocator.
  List<double> _calculateSegmentDistances() {
    final distances = <double>[];

    for (int i = 0; i < route.length - 1; i++) {
      distances.add(
        Geolocator.distanceBetween(
          route[i].latitude,
          route[i].longitude,
          route[i + 1].latitude,
          route[i + 1].longitude,
        ),
      );
    }

    return distances;
  }

  /// Calculates total remaining distance from
  /// every route index to the destination.
  List<double> _calculateRemainingDistances() {
    final remaining = List<double>.filled(route.length, 0);

    double total = 0;

    for (int i = route.length - 2; i >= 0; i--) {
      total += _segmentDistances[i];

      remaining[i] = total;
    }

    return remaining;
  }

  // ----------------------------------------------------------
  // ETA CALCULATION
  // ----------------------------------------------------------

  void _updateEta() {
    if (route.isEmpty) {
      remainingDistanceMeters.value = 0;

      eta.value = Duration.zero;

      etaText.value = 'Arrived';

      return;
    }

    final remainingMeters = _remainingDistances[_currentIndex];

    remainingDistanceMeters.value = remainingMeters;

    if (remainingMeters <= 0) {
      eta.value = Duration.zero;

      etaText.value = 'Arrived';

      return;
    }

    if (riderSpeedMetersPerSecond <= 0) {
      eta.value = Duration.zero;

      etaText.value = 'Calculating...';

      return;
    }

    final seconds = remainingMeters / riderSpeedMetersPerSecond;

    final duration = Duration(seconds: seconds.ceil());

    eta.value = duration;

    etaText.value = _formatDuration(duration);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;

    final seconds = duration.inSeconds % 60;

    if (minutes <= 0) {
      return '$seconds sec';
    }

    if (minutes < 60) {
      return '$minutes min';
    }

    final hours = minutes ~/ 60;

    final remainingMinutes = minutes % 60;

    return '${hours}h ${remainingMinutes}min';
  }

  // ----------------------------------------------------------
  // DISPOSE
  // ----------------------------------------------------------

  void dispose() {
    stop();

    riderPosition.dispose();

    isMoving.dispose();

    remainingDistanceMeters.dispose();

    eta.dispose();

    etaText.dispose();
  }
}
