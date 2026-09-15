import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class LocationWebSocketService {
  LocationWebSocketService({required this.socketUrl});

  final String socketUrl;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  bool _isConnected = false;

  bool get isConnected => _isConnected;

  /// Helper to get appropriate default local socket URL by platform
  static String get defaultLocalSocketUrl {
    if (kIsWeb) return 'ws://localhost:8080';
    if (Platform.isAndroid) return 'ws://10.0.2.2:8080';
    return 'ws://127.0.0.1:8080'; // iOS Simulator & macOS
  }

  Future<void> connect() async {
    if (_channel != null) return;

    if (socketUrl.trim().isEmpty) {
      debugPrint('[LocationWebSocketService] No socketUrl provided; operating in standalone mode.');
      _isConnected = false;
      return;
    }

    try {
      final uri = Uri.parse(socketUrl);
      if (uri.scheme != 'ws' && uri.scheme != 'wss') {
        debugPrint(
          '[LocationWebSocketService] Invalid socket scheme "${uri.scheme}". Only ws:// and wss:// are supported.',
        );
        _isConnected = false;
        return;
      }

      final channel = WebSocketChannel.connect(uri);

      // Wait for handshake with a timeout so unreachable servers fail gracefully
      await channel.ready.timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          throw TimeoutException('WebSocket connection timed out for $socketUrl');
        },
      );

      _channel = channel;
      _isConnected = true;

      _subscription = channel.stream.listen(
        (message) {
          try {
            final decoded = jsonDecode(message as String);

            if (decoded is Map<String, dynamic>) {
              _messageController.add(decoded);
            }
          } catch (error) {
            _messageController.addError(error);
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('[LocationWebSocketService] Socket stream error: $error');
          _isConnected = false;
          _channel = null;
        },
        onDone: () {
          debugPrint('[LocationWebSocketService] Socket closed');
          _isConnected = false;
          _channel = null;
        },
        cancelOnError: false,
      );
    } catch (error) {
      _isConnected = false;
      _channel = null;
      debugPrint('[LocationWebSocketService] Could not connect to $socketUrl: $error');
    }
  }

  void send(Map<String, dynamic> message) {
    final channel = _channel;

    if (channel == null || !_isConnected) {
      return;
    }

    try {
      channel.sink.add(jsonEncode(message));
    } catch (e) {
      debugPrint('[LocationWebSocketService] Send error: $e');
    }
  }

  void sendLocation(Map<String, dynamic> location) {
    send({'type': 'rider_location', ...location});
  }

  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;

    try {
      await _channel?.sink.close();
    } catch (_) {}

    _channel = null;
    _isConnected = false;
  }

  Future<void> dispose() async {
    await disconnect();
    await _messageController.close();
  }
}
