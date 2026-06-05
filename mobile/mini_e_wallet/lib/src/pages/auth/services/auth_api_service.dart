import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mini_e_wallet/src/core/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthApiService {
  const AuthApiService();

  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login'),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    final payload = _decodeBody(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final token = payload['token'] as String?;
      final user = payload['user'] as Map<String, dynamic>?;

      if (token == null || user == null) {
        throw const AuthException('Response login tidak lengkap.');
      }

      final preferences = await SharedPreferences.getInstance();
      await preferences.setString('auth_token', token);
      await preferences.setString(
        'auth_user_email',
        user['email'] as String? ?? '',
      );
      await preferences.setString(
        'auth_user_name',
        user['name'] as String? ?? '',
      );

      return LoginResult(
        message: payload['message'] as String? ?? 'Login berhasil.',
        token: token,
        userName: user['name'] as String? ?? '',
      );
    }

    final errors = payload['errors'];
    if (errors is Map<String, dynamic>) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty) {
          throw AuthException(value.first.toString());
        }
        if (value is String && value.isNotEmpty) {
          throw AuthException(value);
        }
      }
    }

    throw AuthException(
      payload['message'] as String? ?? 'Login gagal. Silakan coba lagi.',
    );
  }

  Future<void> logout() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('auth_token');

    if (token != null && token.isNotEmpty) {
      try {
        await http.post(
          Uri.parse('${ApiConfig.baseUrl}/auth/logout'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      } catch (_) {}
    }

    await preferences.remove('auth_token');
    await preferences.remove('auth_user_email');
    await preferences.remove('auth_user_name');
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

class LoginResult {
  const LoginResult({
    required this.message,
    required this.token,
    required this.userName,
  });

  final String message;
  final String token;
  final String userName;
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
