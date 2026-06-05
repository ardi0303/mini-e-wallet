import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mini_e_wallet/src/core/config/api_config.dart';
import 'package:mini_e_wallet/src/pages/history/models/history_transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryApiService {
  const HistoryApiService();

  Future<HistoryPageData> fetchTransactions({
    int page = 1,
    String sort = 'desc',
    int perPage = 10,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw const HistoryException('Token login tidak ditemukan.');
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/transactions').replace(
      queryParameters: {'page': '$page', 'sort': sort, 'per_page': '$perPage'},
    );

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    final payload = _decodeBody(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return HistoryPageData.fromJson(payload);
    }

    throw HistoryException(
      payload['message'] as String? ?? 'Gagal memuat riwayat transaksi.',
    );
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

class HistoryException implements Exception {
  const HistoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
