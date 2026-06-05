import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mini_e_wallet/src/core/config/api_config.dart';
import 'package:mini_e_wallet/src/pages/home/models/dashboard_summary.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardApiService {
  const DashboardApiService();

  Future<DashboardSummary> fetchSummary() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw const DashboardException('Token login tidak ditemukan.');
    }

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/dashboard'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    final payload = _decodeBody(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return DashboardSummary.fromJson(payload);
    }

    throw DashboardException(
      payload['message'] as String? ?? 'Gagal memuat dashboard.',
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

class DashboardException implements Exception {
  const DashboardException(this.message);

  final String message;

  @override
  String toString() => message;
}
