import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class VitalsWsService {
  WebSocketChannel? _channel;

  bool get isConnected => _channel != null;

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }

  /// Connecte au WS et renvoie un Stream de messages (String)
  Stream<String> connect({
    required String host,
    required int port,
    required String deviceId,
    bool secure = false, // false => ws, true => wss
  }) {
    // ✅ Construction safe (pas de Uri.parse string)
    final uri = Uri(
      scheme: secure ? 'wss' : 'ws',
      host: host,
      port: port,
      path: '/sensor-service/ws/vitals',
    );

    _channel = WebSocketChannel.connect(uri);

    // ✅ Subscribe message comme dans ton Postman
    _channel!.sink.add(jsonEncode({
      "action": "subscribe",
      "deviceId": deviceId,
    }));

    return _channel!.stream.map((e) => e.toString());
  }
}
