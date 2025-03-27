import 'dart:convert';
import 'package:http/http.dart' as http;
import '../shared/constants.dart';
import 'session_manager.dart';

class UpdateProfileApi {
  static Future<bool> updateProfile(String name, String email, String token) async {
    final Map<String, dynamic> body = {'name': name, 'email': email};

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/auth/updateprofile'),
        headers: {
          'Content-Type': 'application/json',
          'x-group-token': AppConfig.groupToken,
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('Profile Updated: ${response.body}');
        return true;
      } else {
        print('Error: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Network Error: $e');
      return false;
    }
  }
}
