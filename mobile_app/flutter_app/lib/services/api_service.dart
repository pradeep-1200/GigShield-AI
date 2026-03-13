import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://gigshield-ai.onrender.com";

  static String _handleError(dynamic error) {
    if (error is TimeoutException) {
      return 'Backend unavailable\nPlease try again';
    } else if (error is SocketException) {
      return 'Cannot connect to cloud backend.';
    } else if (error is FormatException) {
      return 'Invalid backend address.';
    }
    return 'Backend unavailable\nPlease try again';
  }

  static Future<Map<String, dynamic>> predictRisk(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/predict-risk'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to predict risk');
      }
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  static Future<Map<String, dynamic>> calculatePremium(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/calculate-premium'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to calculate premium');
      }
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }
  
  static Future<Map<String, dynamic>> monitorWeather(String city, {bool forceDemo = false}) async {
    try {
      final url = '$baseUrl/monitor-weather?city=$city&force_demo=$forceDemo';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to monitor weather');
      }
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  static Future<Map<String, dynamic>> triggerClaim(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/claim-trigger'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to trigger claim');
      }
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/')).timeout(const Duration(seconds: 6));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
