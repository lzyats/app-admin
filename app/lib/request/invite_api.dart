import 'dart:convert';
import 'dart:typed_data';

import 'package:myapp/request/http_client.dart';
import 'package:myapp/request/ruoyi_endpoints.dart';

class InviteApi {
  const InviteApi._();

  static Future<Uint8List> fetchInviteQrImage(String content, {int size = 360}) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      'content': content,
      'size': size,
    };
    final response = await HttpClient.post(
      RuoYiEndpoints.inviteQr,
      data: payload,
      encrypt: true,
      retry: true,
    );

    final dynamic raw = response.data;
    if (raw is Map<String, dynamic>) {
      return _decodeBase64Image(raw['qrImageBase64'] ?? (raw['data'] is Map ? raw['data']['qrImageBase64'] : null));
    }
    if (raw is Map) {
      final dynamic nested = raw['data'];
      if (nested is Map) {
        return _decodeBase64Image(nested['qrImageBase64']);
      }
      return _decodeBase64Image(raw['qrImageBase64']);
    }
    throw StateError('invite qr image response invalid');
  }

  static Uint8List _decodeBase64Image(dynamic value) {
    final String base64Text = (value ?? '').toString().trim();
    if (base64Text.isEmpty) {
      throw StateError('invite qr image empty');
    }
    return Uint8List.fromList(base64Decode(base64Text));
  }
}
