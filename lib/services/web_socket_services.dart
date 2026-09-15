// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:web_socket_channel/io.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';

// class LocationWebSocketService {
//   LocationWebSocketService({
//     required this.socketUrl,
//     this.pingInterval = const Duration(seconds: 5),
//     this.reconnectInterval = const Duration(seconds: 3),
//   });

//   final String socketUrl;
//   final Duration pingInterval;
//   final Duration reconnectInterval;

//   WebSocketChannel? _channel;
//   StreamSubscription? _subscription;
//   Timer? _reconnectTimer;

//   bool _shouldReconnect = false;
//   bool _isConnecting = false;

//   final StreamController<Map<String, dynamic>> _messageController =
//       StreamController<Map<String, dynamic>>.broadcast();

//   final ValueNotifier<bool> isConnectedNotifier = ValueNotifier<bool>(false);

//   Stream<Map<String, dynamic>> get messages => _messageController.stream;

//   bool get isConnected => isConnectedNotifier.value;

//   /// Helper to get appropriate default local socket URL by platform
//   static String get defaultLocalSocketUrl {
//     if (kIsWeb) return 'ws://localhost:8080';
//     if (Platform.isAndroid) return 'ws://10.0.2.2:8080';
//     return 'ws://127.0.0.1:8080'; // iOS Simulator & macOS
//   }

//   Future<void> connect() async {
//     _shouldReconnect = true;
//     _reconnectTimer?.cancel();
//     _reconnectTimer = null;

//     if (_channel != null || _isConnecting) return;

//     if (socketUrl.trim().isEmpty) {
//       debugPrint('[LocationWebSocketService] No socketUrl provided; operating in standalone mode.');
//       isConnectedNotifier.value = false;
//       return;
//     }

//     _isConnecting = true;

//     try {
//       final uri = Uri.parse(socketUrl);
//       if (uri.scheme != 'ws' && uri.scheme != 'wss') {
//         debugPrint(
//           '[LocationWebSocketService] Invalid socket scheme "${uri.scheme}". Only ws:// and wss:// are supported.',
//         );
//         isConnectedNotifier.value = false;
//         _isConnecting = false;
//         return;
//       }

//       WebSocketChannel channel;
//       if (kIsWeb) {
//         channel = WebSocketChannel.connect(uri);
//       } else {
//         channel = IOWebSocketChannel.connect(
//           uri,
//           pingInterval: pingInterval,
//         );
//       }

//       // Wait for handshake with a timeout so unreachable servers fail gracefully
//       await channel.ready.timeout(
//         const Duration(seconds: 4),
//         onTimeout: () {
//           throw TimeoutException('WebSocket connection timed out for $socketUrl');
//         },
//       );

//       _channel = channel;
//       isConnectedNotifier.value = true;
//       _isConnecting = false;
//       debugPrint('[LocationWebSocketService] Connected to $socketUrl (pingInterval: ${pingInterval.inSeconds}s)');

//       _subscription = channel.stream.listen(
//         (message) {
//           try {
//             final decoded = jsonDecode(message as String);

//             if (decoded is Map<String, dynamic>) {
//               _messageController.add(decoded);
//             }
//           } catch (error) {
//             _messageController.addError(error);
//           }
//         },
//         onError: (Object error, StackTrace stackTrace) {
//           debugPrint('[LocationWebSocketService] Socket stream error: $error');
//           _handleDisconnection();
//         },
//         onDone: () {
//           debugPrint('[LocationWebSocketService] Socket closed. Reconnect requested: $_shouldReconnect');
//           _handleDisconnection();
//         },
//         cancelOnError: false,
//       );
//     } catch (error) {
//       _isConnecting = false;
//       debugPrint('[LocationWebSocketService] Could not connect to $socketUrl: $error');
//       _handleDisconnection();
//     }
//   }

//   void _handleDisconnection() {
//     isConnectedNotifier.value = false;
//     _cleanupChannel();

//     if (_shouldReconnect) {
//       _scheduleReconnect();
//     }
//   }

//   void _scheduleReconnect() {
//     _reconnectTimer?.cancel();
//     _reconnectTimer = Timer(reconnectInterval, () {
//       if (_shouldReconnect && _channel == null && !_isConnecting) {
//         debugPrint('[LocationWebSocketService] Attempting auto-reconnect...');
//         connect();
//       }
//     });
//   }

//   void send(Map<String, dynamic> message) {
//     final channel = _channel;

//     if (channel == null || !isConnected) {
//       return;
//     }

//     try {
//       channel.sink.add(jsonEncode(message));
//     } catch (e) {
//       debugPrint('[LocationWebSocketService] Send error: $e');
//     }
//   }

//   void sendLocation(Map<String, dynamic> location) {
//     send({'type': 'rider_location', ...location});
//   }

//   void _cleanupChannel() {
//     _subscription?.cancel();
//     _subscription = null;

//     try {
//       _channel?.sink.close();
//     } catch (_) {}

//     _channel = null;
//   }

//   Future<void> disconnect() async {
//     _shouldReconnect = false;
//     _reconnectTimer?.cancel();
//     _reconnectTimer = null;

//     _cleanupChannel();
//     isConnectedNotifier.value = false;
//   }

//   Future<void> dispose() async {
//     await disconnect();
//     await _messageController.close();
//     isConnectedNotifier.dispose();
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'offline_location_storage.dart';

class LocationWebSocketService {
  LocationWebSocketService({
    required this.socketUrl,
    this.pingInterval = const Duration(seconds: 5),
    this.reconnectInterval = const Duration(seconds: 3),
    OfflineLocationStorage? locationStorage,
  }) : _locationStorage = locationStorage ?? OfflineLocationStorage();

  final String socketUrl;

  final Duration pingInterval;
  final Duration reconnectInterval;

  final OfflineLocationStorage _locationStorage;

  WebSocketChannel? _channel;

  StreamSubscription? _subscription;

  Timer? _reconnectTimer;

  bool _shouldReconnect = false;

  bool _isConnecting = false;

  bool _isSyncing = false;

  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  final ValueNotifier<bool> isConnectedNotifier = ValueNotifier<bool>(false);

  final ValueNotifier<int> pendingLocationCount = ValueNotifier<int>(0);

  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  bool get isConnected => isConnectedNotifier.value;

  static String get defaultLocalSocketUrl {
    if (kIsWeb) return 'ws://localhost:8080';

    if (Platform.isAndroid) {
      return 'ws://10.0.2.2:8080';
    }

    return 'ws://127.0.0.1:8080';
  }

  // --------------------------------------------------
  // CONNECT
  // --------------------------------------------------

  Future<void> connect() async {
    _shouldReconnect = true;

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    if (_channel != null || _isConnecting) {
      return;
    }

    if (socketUrl.trim().isEmpty) {
      debugPrint('[WebSocket] No socket URL provided.');

      isConnectedNotifier.value = false;

      return;
    }

    _isConnecting = true;

    try {
      final uri = Uri.parse(socketUrl);

      if (uri.scheme != 'ws' && uri.scheme != 'wss') {
        throw ArgumentError('Only ws:// and wss:// are supported.');
      }

      late final WebSocketChannel channel;

      if (kIsWeb) {
        channel = WebSocketChannel.connect(uri);
      } else {
        channel = IOWebSocketChannel.connect(uri, pingInterval: pingInterval);
      }

      await channel.ready.timeout(
        const Duration(seconds: 4),
        onTimeout: () {
          throw TimeoutException('WebSocket connection timed out.');
        },
      );

      _channel = channel;

      isConnectedNotifier.value = true;

      _isConnecting = false;

      debugPrint('[WebSocket] Connected.');

      // Listen for incoming messages.
      _subscription = channel.stream.listen(
        _handleIncomingMessage,
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('[WebSocket] Stream error: $error');

          _handleDisconnection();
        },
        onDone: () {
          debugPrint('[WebSocket] Socket closed.');

          _handleDisconnection();
        },
        cancelOnError: false,
      );

      // Automatically upload offline locations
      // as soon as the connection is restored.
      await syncPendingLocations();
    } catch (error) {
      _isConnecting = false;

      debugPrint('[WebSocket] Connection failed: $error');

      _handleDisconnection();
    }
  }

  // --------------------------------------------------
  // INCOMING MESSAGES
  // --------------------------------------------------

  void _handleIncomingMessage(dynamic message) {
    try {
      final decoded = jsonDecode(message as String);

      if (decoded is Map<String, dynamic>) {
        _messageController.add(decoded);
      }
    } catch (error) {
      _messageController.addError(error);
    }
  }

  // --------------------------------------------------
  // DISCONNECTION
  // --------------------------------------------------

  void _handleDisconnection() {
    isConnectedNotifier.value = false;

    _cleanupChannel();

    if (_shouldReconnect) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();

    _reconnectTimer = Timer(reconnectInterval, () {
      if (_shouldReconnect && _channel == null && !_isConnecting) {
        debugPrint('[WebSocket] Attempting reconnect...');

        connect();
      }
    });
  }

  // --------------------------------------------------
  // SEND NORMAL MESSAGE
  // --------------------------------------------------

  void send(Map<String, dynamic> message) {
    final channel = _channel;

    if (channel == null || !isConnected) {
      return;
    }

    try {
      channel.sink.add(jsonEncode(message));
    } catch (error) {
      debugPrint('[WebSocket] Send error: $error');

      _handleDisconnection();
    }
  }

  // --------------------------------------------------
  // SEND RIDER LOCATION
  // --------------------------------------------------

  Future<void> sendLocation(Map<String, dynamic> location) async {
    final message = {'type': 'rider_location', ...location};

    // If WebSocket is unavailable, save locally.
    if (_channel == null || !isConnected) {
      await _saveOfflineLocation(message);

      return;
    }

    try {
      _channel!.sink.add(jsonEncode(message));

      debugPrint('[WebSocket] Location sent.');
    } catch (error) {
      debugPrint('[WebSocket] Location send failed: $error');

      // Save the location if sending fails.
      await _saveOfflineLocation(message);

      _handleDisconnection();
    }
  }

  // --------------------------------------------------
  // SAVE OFFLINE LOCATION
  // --------------------------------------------------

  Future<void> _saveOfflineLocation(Map<String, dynamic> location) async {
    await _locationStorage.saveLocation(location);

    await _updatePendingCount();

    debugPrint('[WebSocket] Location saved offline.');
  }

  // --------------------------------------------------
  // SYNC PENDING LOCATIONS
  // --------------------------------------------------

  Future<void> syncPendingLocations() async {
    if (_isSyncing) return;

    if (_channel == null || !isConnected) {
      return;
    }

    _isSyncing = true;

    try {
      final pendingLocations = await _locationStorage.getPendingLocations();

      if (pendingLocations.isEmpty) {
        return;
      }

      debugPrint(
        '[WebSocket] Syncing '
        '${pendingLocations.length} locations...',
      );

      for (final location in pendingLocations) {
        if (_channel == null || !isConnected) {
          break;
        }

        _channel!.sink.add(jsonEncode(location));

        // IMPORTANT:
        // This demo waits briefly between messages.
        // Production should wait for server ACK.
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }

      // Do NOT delete the queue here in production.
      // Deletion should happen after server ACK.
    } catch (error) {
      debugPrint('[WebSocket] Offline sync failed: $error');
    } finally {
      _isSyncing = false;

      await _updatePendingCount();
    }
  }

  // --------------------------------------------------
  // PENDING COUNT
  // --------------------------------------------------

  Future<void> _updatePendingCount() async {
    pendingLocationCount.value = await _locationStorage.count();
  }

  // --------------------------------------------------
  // CLEANUP
  // --------------------------------------------------

  void _cleanupChannel() {
    _subscription?.cancel();

    _subscription = null;

    try {
      _channel?.sink.close();
    } catch (_) {}

    _channel = null;
  }

  // --------------------------------------------------
  // DISCONNECT
  // --------------------------------------------------

  Future<void> disconnect() async {
    _shouldReconnect = false;

    _reconnectTimer?.cancel();

    _reconnectTimer = null;

    _cleanupChannel();

    isConnectedNotifier.value = false;
  }

  // --------------------------------------------------
  // DISPOSE
  // --------------------------------------------------

  Future<void> dispose() async {
    await disconnect();

    await _messageController.close();

    isConnectedNotifier.dispose();

    pendingLocationCount.dispose();
  }
}
