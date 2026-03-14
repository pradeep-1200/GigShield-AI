import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://gigshield-ai.onrender.com";

  static String _handleError(dynamic error) {
    if (error is TimeoutException) {
      return 'Backend is starting up...\nPlease wait ~30s and try again.';
    } else if (error is SocketException) {
      return 'No internet connection or backend unreachable.';
    } else if (error is FormatException) {
      return 'Server response error (Invalid Data Format).';
    }
    String msg = error.toString().replaceAll('Exception: ', '');
    return msg.isNotEmpty ? msg : 'Unknown error occurred.';
  }

  static Future<Map<String, dynamic>> predictRisk(Map<String, dynamic> data) async {
    try {
      print('API Call: $baseUrl/predict-risk');
      final response = await http.post(
        Uri.parse('$baseUrl/predict-risk'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['error'] ?? errorData['message'] ?? 'Failed to predict risk');
        } catch (_) {
          throw Exception('Failed to predict risk');
        }
      }
    } catch (e) {
      print('API Error: $e');
      throw Exception(_handleError(e));
    }
  }

  static Future<Map<String, dynamic>> calculatePremium(Map<String, dynamic> data) async {
    try {
      print('API Call: $baseUrl/calculate-premium');
      final response = await http.post(
        Uri.parse('$baseUrl/calculate-premium'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));
      print('Response Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['error'] ?? errorData['message'] ?? 'Failed to calculate premium');
        } catch (_) {
          throw Exception('Failed to calculate premium');
        }
      }
    } catch (e) {
      print('API Error: $e');
      throw Exception(_handleError(e));
    }
  }
  
  static Future<Map<String, dynamic>> monitorWeather(String city, {bool forceDemo = false}) async {
    try {
      final url = '$baseUrl/monitor-weather?city=$city&force_demo=$forceDemo';
      print('API Call: $url');
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 30));
      print('Response Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['error'] ?? errorData['message'] ?? 'Failed to monitor weather');
        } catch (_) {
          throw Exception('Failed to monitor weather');
        }
      }
    } catch (e) {
      print('API Error: $e');
      throw Exception(_handleError(e));
    }
  }

  static Future<Map<String, dynamic>> triggerClaim(Map<String, dynamic> data) async {
    try {
      print('API Call: $baseUrl/claim-trigger');
      final response = await http.post(
        Uri.parse('$baseUrl/claim-trigger'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));
      print('Response Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['error'] ?? errorData['message'] ?? 'Failed to trigger claim');
        } catch (_) {
          throw Exception('Failed to trigger claim');
        }
      }
    } catch (e) {
      print('API Error: $e');
      throw Exception(_handleError(e));
    }
  }

  static Future<bool> checkHealth() async {
    try {
      print('API Call (Health): $baseUrl/');
      final response = await http.get(Uri.parse('$baseUrl/')).timeout(const Duration(seconds: 30));
      print('Health Status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Health Error: $e');
      return false;
    }
  }
}
