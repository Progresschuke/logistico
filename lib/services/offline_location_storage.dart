import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class OfflineLocationStorage {
  OfflineLocationStorage({
    this.storageKey = 'pending_rider_locations',
    this.maxQueueSize = 1000,
  });

  final String storageKey;
  final int maxQueueSize;

  /// Save a location to the local queue.
  Future<void> saveLocation(Map<String, dynamic> location) async {
    final prefs = await SharedPreferences.getInstance();

    final existingLocations = await getPendingLocations();

    existingLocations.add(location);

    // Prevent unlimited storage growth.
    final startIndex = existingLocations.length > maxQueueSize
        ? existingLocations.length - maxQueueSize
        : 0;

    final limitedLocations = existingLocations.sublist(startIndex);

    await prefs.setString(storageKey, jsonEncode(limitedLocations));
  }

  /// Read all locations waiting to be sent.
  Future<List<Map<String, dynamic>>> getPendingLocations() async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(storageKey);

    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded is! List) {
        return [];
      }

      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Remove the first [count] locations after
  /// the server has acknowledged them.
  Future<void> removeFirst(int count) async {
    if (count <= 0) return;

    final prefs = await SharedPreferences.getInstance();

    final locations = await getPendingLocations();

    if (locations.isEmpty) return;

    final remaining = locations.skip(count).toList();

    if (remaining.isEmpty) {
      await prefs.remove(storageKey);
    } else {
      await prefs.setString(storageKey, jsonEncode(remaining));
    }
  }

  /// Remove all pending locations.
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(storageKey);
  }

  /// Number of pending locations.
  Future<int> count() async {
    final locations = await getPendingLocations();

    return locations.length;
  }
}
