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

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      // Ensure endpoint starts with /
      final path = endpoint.startsWith('/') ? endpoint : '/$endpoint';
      final url = Uri.parse('$baseUrl$path');

      print('API Request: POST $url');
      print('Request Body: ${json.encode(body)}');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      // Try to decode response
      Map<String, dynamic> data;

      try {
        data = json.decode(response.body) as Map<String, dynamic>;
      } catch (e) {
        // If response is not JSON
        data = {
          'message': response.body.isNotEmpty
              ? response.body
              : 'Server mengembalikan response kosong',
        };
      }

      // Set success based on status code
      data['success'] =
          response.statusCode == 200 || response.statusCode == 201;

      // If status code indicates error but no message, add one
      if (!data['success'] && data['message'] == null) {
        data['message'] = 'Request gagal dengan status ${response.statusCode}';
      }

      return data;
    } on http.ClientException catch (e) {
      print('Network error: $e');
      return {
        'success': false,
        'message':
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      };
    } on FormatException catch (e) {
      print('JSON parsing error: $e');
      return {
        'success': false,
        'message': 'Format response dari server tidak valid',
      };
    } catch (e) {
      print('Unexpected error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }
}
