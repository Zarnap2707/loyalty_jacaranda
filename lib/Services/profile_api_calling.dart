import 'dart:convert';
import 'package:http/http.dart' as http;
import '../shared/constants.dart';

class ProfileApi {
  static Future<Map<String, dynamic>?> getProfile(String token) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-group-token': AppConfig.groupToken,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print('Network Error: $e');
      return null;
    }
  }
}
