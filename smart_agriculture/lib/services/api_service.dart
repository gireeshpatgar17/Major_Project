import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.105.6.252:8000';

  // ==========================================================
  // SENSOR DATA
  // ==========================================================

  static Future<Map<String, dynamic>> getSensorData() async {
    final response = await http.get(
      Uri.parse('$baseUrl/sensors/'),
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(
        jsonDecode(response.body),
      );
    } else {
      throw Exception(
        'Failed to load sensor data: ${response.statusCode}',
      );
    }
  }

  // ==========================================================
  // FARM
  // ==========================================================

  static Future<Map<String, dynamic>> getFarm(int farmId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/farms/$farmId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      if (data.isEmpty) {
        throw Exception('Farm not found');
      }

      return Map<String, dynamic>.from(data.first);
    } else {
      throw Exception(
        'Failed to load farm: ${response.statusCode}',
      );
    }
  }

  // ==========================================================
  // IRRIGATION HISTORY
  // ==========================================================

  static Future<List<dynamic>> getIrrigationHistory(
    int farmId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/irrigation/$farmId'),
    );

    if (response.statusCode == 200) {
      return List<dynamic>.from(
        jsonDecode(response.body),
      );
    } else {
      throw Exception(
        'Failed to load irrigation history: ${response.statusCode}',
      );
    }
  }

  // ==========================================================
  // IRRIGATION SUMMARY
  // ==========================================================

  static Future<Map<String, dynamic>> getIrrigationSummary(
    int farmId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/irrigation/$farmId/summary'),
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(
        jsonDecode(response.body),
      );
    } else {
      throw Exception(
        'Failed to load irrigation summary: ${response.statusCode}',
      );
    }
  }

  // ==========================================================
  // DISEASE HISTORY
  // ==========================================================

  static Future<List<dynamic>> getDiseaseHistory(
    int farmId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/disease/$farmId'),
    );

    if (response.statusCode == 200) {
      return List<dynamic>.from(
        jsonDecode(response.body),
      );
    } else {
      throw Exception(
        'Failed to load disease history: ${response.statusCode}',
      );
    }
  }
}