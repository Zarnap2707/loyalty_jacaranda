import 'dart:convert';
import 'package:http/http.dart' as http;
import '../shared/constants.dart';

class ShopListApi {
  static Future<List<Map<String, dynamic>>> fetchShops(String token) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/shops/list'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-group-token': AppConfig.groupToken,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['shops']);
      } else {
        print('Shop List Error: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Network Error: $e');
      return [];
    }
  }
}
