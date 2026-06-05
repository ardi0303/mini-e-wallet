import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mini_e_wallet/src/core/config/api_config.dart';
import 'package:mini_e_wallet/src/pages/transfer/models/transfer_recipient.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransferApiService {
  const TransferApiService();

  Future<List<TransferRecipient>> fetchRecipients() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/recipients'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    final payload = _decodeBody(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = payload['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(TransferRecipient.fromJson)
            .toList();
      }

      return [];
    }

    throw TransferException(
      payload['message'] as String? ?? 'Gagal memuat daftar penerima.',
    );
  }

  Future<TransferResult> submitTransfer({
    required int recipientUserId,
    required int amount,
  }) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/transfers'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'recipient_user_id': recipientUserId,
        'amount': amount,
      }),
    );

    final payload = _decodeBody(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final wallet =
          payload['wallet'] as Map<String, dynamic>? ?? <String, dynamic>{};

      return TransferResult(
        message: payload['message'] as String? ?? 'Transfer berhasil diproses.',
        updatedBalance: (wallet['balance'] as num?)?.toInt() ?? 0,
      );
    }

    final errors = payload['errors'];
    if (errors is Map<String, dynamic>) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty) {
          throw TransferException(value.first.toString());
        }
        if (value is String && value.isNotEmpty) {
          throw TransferException(value);
        }
      }
    }

    throw TransferException(
      payload['message'] as String? ?? 'Transfer gagal diproses.',
    );
  }

  Future<String> _getToken() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw const TransferException('Token login tidak ditemukan.');
    }

    return token;
  }

  Map<String, dynamic> _decodeBody(String body) {
    if (body.isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return <String, dynamic>{};
  }
}

class TransferResult {
  const TransferResult({required this.message, required this.updatedBalance});

  final String message;
  final int updatedBalance;
}

class TransferException implements Exception {
  const TransferException(this.message);

  final String message;

  @override
  String toString() => message;
}
