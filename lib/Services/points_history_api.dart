import 'dart:convert';
import 'package:http/http.dart' as http;
import '../shared/constants.dart';
import 'session_manager.dart';

class PointsHistoryApi {
  static Future<Map<String, dynamic>> fetchHistoryWithMessage() async {
    final token = await SessionManager.getToken();
    final url = Uri.parse('${AppConfig.baseUrl}/points/history');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'x-group-token': AppConfig.groupToken,
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': List<Map<String, dynamic>>.from(data['history']),
        };
      } else {
        return {'success': false, 'message': data['message'] ?? 'Error occurred'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}

