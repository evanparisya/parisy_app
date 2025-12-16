import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class ApiClient {
  static const String baseUrl = 'https://nitroir.pythonanywhere.com';

  late final Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(seconds: 30),
        receiveTimeout: Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  // Helper method to build headers with token
  Map<String, String> _buildHeaders({String? token}) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Helper method to parse response
  Map<String, dynamic> _parseResponse(http.Response response) {
    Map<String, dynamic> data;

    try {
      data = json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      data = {
        'message': response.body.isNotEmpty
            ? response.body
            : 'Server mengembalikan response kosong',
      };
    }

    // Set success based on status code
    data['success'] = response.statusCode == 200 || response.statusCode == 201;

    // If status code indicates error but no message, add one
    if (!data['success'] && data['message'] == null) {
      data['message'] = 'Request gagal dengan status ${response.statusCode}';
    }

    return data;
  }

  // Helper method to handle errors
  Map<String, dynamic> _handleError(dynamic error) {
    if (error is http.ClientException) {
      print('Network error: $error');
      return {
        'success': false,
        'message':
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      };
    } else if (error is FormatException) {
      print('JSON parsing error: $error');
      return {
        'success': false,
        'message': 'Format response dari server tidak valid',
      };
    } else {
      print('Unexpected error: $error');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${error.toString()}',
      };
    }
  }

  // POST request without token
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final path = endpoint.startsWith('/') ? endpoint : '/$endpoint';
      final url = Uri.parse('$baseUrl$path');

      print('API Request: POST $url');
      print('Request Body: ${json.encode(body)}');

      final response = await http.post(
        url,
        headers: _buildHeaders(),
        body: json.encode(body),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      return _parseResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // POST request with token
  Future<Map<String, dynamic>> postWithToken(
    String endpoint,
    Map<String, dynamic> body,
    String token,
  ) async {
    try {
      final path = endpoint.startsWith('/') ? endpoint : '/$endpoint';
      final url = Uri.parse('$baseUrl$path');

      print('API Request: POST $url (with token)');
      print('Request Body: ${json.encode(body)}');

      final response = await http.post(
        url,
        headers: _buildHeaders(token: token),
        body: json.encode(body),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      return _parseResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // GET request with token
  Future<Map<String, dynamic>> getWithToken(
    String endpoint,
    String token,
  ) async {
    try {
      final path = endpoint.startsWith('/') ? endpoint : '/$endpoint';
      final url = Uri.parse('$baseUrl$path');

      print('API Request: GET $url (with token)');

      final response = await http.get(
        url,
        headers: _buildHeaders(token: token),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      return _parseResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // PUT request with token
  Future<Map<String, dynamic>> putWithToken(
    String endpoint,
    Map<String, dynamic> body,
    String token,
  ) async {
    try {
      final path = endpoint.startsWith('/') ? endpoint : '/$endpoint';
      final url = Uri.parse('$baseUrl$path');

      print('API Request: PUT $url (with token)');
      print('Request Body: ${json.encode(body)}');

      final response = await http.put(
        url,
        headers: _buildHeaders(token: token),
        body: json.encode(body),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      return _parseResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // DELETE request with token
  Future<Map<String, dynamic>> deleteWithToken(
    String endpoint,
    String token,
  ) async {
    try {
      final path = endpoint.startsWith('/') ? endpoint : '/$endpoint';
      final url = Uri.parse('$baseUrl$path');

      print('API Request: DELETE $url (with token)');

      final response = await http.delete(
        url,
        headers: _buildHeaders(token: token),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      return _parseResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
}
