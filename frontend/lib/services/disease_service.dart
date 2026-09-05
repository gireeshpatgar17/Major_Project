import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'api_service.dart';

class DiseaseService {
  static Future<Map<String, dynamic>> predictCropDisease(
    XFile imageFile, {
    int farmId = 1,
  }) async {
    final uri = Uri.parse(
      '${ApiService.baseUrl}/disease/predict?farm_id=$farmId',
    );

    final request = http.MultipartRequest('POST', uri);

    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        return data;
      }

      throw Exception('Invalid response from disease prediction API');
    }

    throw Exception(
      'Disease prediction failed: ${response.statusCode}\n${response.body}',
    );
  }

  static Future<List<dynamic>> getDiseaseHistory(int farmId) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/disease/$farmId'),
    );

    if (response.statusCode == 200) {
      return List<dynamic>.from(jsonDecode(response.body));
    }

    throw Exception('Failed to load disease history: ${response.statusCode}');
  }
}
